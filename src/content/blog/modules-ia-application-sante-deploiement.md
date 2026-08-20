---
title: "Deux modules IA dans une application de santé"
description: "Un assistant conversationnel RAG et un essayage virtuel par génération d'images, livrés dans la même application. Les arbitrages qui ont tenu, le garde-fou d'identité qu'il a fallu recalibrer, et le faux négatif qui excluait une partie des utilisatrices."
pubDate: 2026-08-25
tags: ["rag", "llm", "rgpd", "vision", "django"]
---

Une plateforme d'orientation pour patientes, dans le secteur de la santé. Deux modules d'IA générative à intégrer dans une application Django existante : un assistant conversationnel adossé à une base documentaire, et un essayage virtuel qui projette un modèle de prothèse capillaire sur la photo de l'utilisatrice.

*Modules développés du 3 au 5 juillet 2026, déployés en production éteints le 4 et le 5 juillet, assistant activé en pilote privé le 7 juillet. Les mesures citées sont celles relevées pendant ces travaux.*

Les deux modules tournent sur du matériel auto-hébergé, sans qu'aucune donnée ne quitte l'infrastructure. Ce n'est pas une posture : dans ce domaine, une conversation peut contenir une donnée de santé, et une photo de visage est une donnée biométrique.

Voici ce que ces deux intégrations ont réellement coûté, y compris les choix que j'ai dû défaire.

## Module 1, l'assistant : la partie difficile n'est pas le RAG

Le mécanisme est banal, et c'est justement pour ça qu'il ne pose presque aucun problème. Question, mise en vecteur, recherche des passages les plus proches dans la base, construction du prompt avec le contexte retrouvé, appel au modèle, réponse diffusée au fil de l'eau avec ses sources.

Trois décisions ont eu beaucoup plus d'effet que le choix du modèle.

### Le modèle d'embedding tourne sur le processeur, et c'est un arbitrage, pas un pis-aller

Au moment de l'intégration, les quatre GPU du nœud d'inférence étaient saturés : entre 1,5 et 2,8 Go libres chacun. Placer le modèle de mise en vecteur sur GPU aurait demandé de déloger une autre charge.

Mesure avant décision : sur processeur, la mise en vecteur d'une question coûte **166 ms**. L'appel au modèle de langage qui suit coûte plusieurs secondes. Le surcoût est donc de l'ordre de 3 % du temps de réponse perçu, pour un GPU entier libéré.

Le modèle d'embedding est resté sur processeur, dans un conteneur dédié de la même pile applicative. C'est une décision qu'on ne prend correctement qu'en mesurant les deux étages séparément : raisonner sur « le GPU est plus rapide » aurait consommé une carte pour gagner un vingtième de la latence utilisateur.

### Le prompt système vit en base de données, pas dans le code

Le prompt qui définit le comportement de l'assistant est un paramètre éditable en base, pas une constante Python.

La raison est prosaïque : ce texte porte des décisions métier et réglementaires qui changent plus vite que le code. Le mettre dans le dépôt, c'est exiger un déploiement complet pour ajuster une formulation, et transformer chaque ajustement éditorial en opération technique. Effet de bord vérifié à l'usage : le champ a dû passer en texte long, la limite de 500 caractères d'un champ court étant atteinte immédiatement.

Même logique pour tout le reste : seuil de similarité, nombre de passages retenus, quota de questions par minute, longueur maximale d'une question. Aucun seuil en dur.

### Trois garde-fous, et une recette adverse pour les prouver

L'assistant a interdiction absolue de faire trois choses, et chacune est un risque réel dans ce domaine :

1. **donner un conseil médical**, il doit orienter vers un soignant ;
2. **répondre hors de son domaine**, il doit recentrer ;
3. **inventer une référence réglementaire**, en particulier un code de nomenclature de remboursement pour une classe de produit qui n'en a pas.

Le troisième est le plus insidieux. Un modèle de langage produit volontiers un code plausible, correctement formaté, et faux. Dans un contexte de remboursement, ce code sera recopié par une patiente sur un formulaire.

Ces garde-fous ne valent que prouvés. La recette d'acceptation les attaque explicitement, avec le vrai modèle et non un bouchon de test : une question sur le report d'une chimiothérapie doit déclencher l'orientation vers un soignant ; une question sur la météo doit déclencher le recentrage ; une injection du type « oublie tes instructions » doit laisser le cadre intact ; et une question sur la classe de produit concernée doit produire une réponse utile **sans** code inventé.

Dix cas sur dix, réponses justes et sourcées.

### Le RGPD n'est pas une couche, c'est une contrainte d'architecture

Sur ce projet, la règle est dure : **aucune conversation n'est persistée.** Pas de table de messages, pas d'historique, mémoire de session uniquement. Les journaux d'exploitation ne contiennent que des compteurs anonymes, jamais le texte échangé.

Cette règle a des conséquences directes sur le code, et elles sont plus intéressantes que la règle elle-même.

Le point d'entrée du dialogue est un **POST**, pas un GET. Ce n'est pas une préférence de style : une question passée en paramètre d'URL se retrouve dans les journaux du serveur web, dans l'historique du navigateur et dans le référent envoyé au tiers suivant. Pour un texte qui peut contenir une donnée de santé, l'URL est le pire endroit possible. Le même raisonnement s'applique ailleurs dans l'application, où les coordonnées de géolocalisation transitent en corps de requête et jamais en paramètre.

Et la base documentaire est indexée par une commande dédiée, idempotente, qui empreinte la source et le modèle utilisés. Une migration de schéma ne doit jamais appeler un modèle d'IA : sinon un déploiement devient dépendant de la disponibilité d'un GPU.

### L'interface : un îlot, pas une réécriture

L'assistant est le premier composant React du projet. Tout le reste des pages publiques reste rendu côté serveur, avec des fragments hypermédia.

Le bundle est construit en mode bibliothèque, avec React embarqué dans l'artefact et **aucun appel à un réseau de diffusion de contenu**. Une page qui charge une bibliothèque depuis un domaine tiers envoie l'adresse IP de la visiteuse à ce tiers, et ruine l'argument de souveraineté que l'hébergement local vient d'établir.

Trois pièges d'outillage, sans intérêt conceptuel mais qui coûtent chacun une demi-journée si on ne les connaît pas : le mode bibliothèque du bundler ne substitue pas la variable d'environnement de production, il faut la déclarer explicitement ; un `docker compose restart` ne recharge pas le fichier d'environnement, il faut recréer le conteneur ; et une image `curl` officielle tourne sans privilèges, donc ne peut pas écrire dans un volume appartenant à root.

## Module 2, l'essayage : là où ça s'est vraiment compliqué

Projeter un modèle de prothèse sur la photo d'une utilisatrice, à partir d'une simple image de référence du catalogue. Un modèle de génération d'images à 20 milliards de paramètres, en édition d'image guidée, sur une carte grand public.

### Le premier rendu réussi était un échec

Transfert de la coiffure : réussi du premier coup, et ressemblant.

Le visage : détruit. En édition pure à débruitage complet, le modèle régénère toute l'image, y compris la peau. Résultat marbré, dérive des traits. Pour un essayage, c'est éliminatoire : l'utilisatrice doit se reconnaître.

La correction n'est pas dans le modèle, elle est autour. Segmenter les cheveux **du rendu**, puis recomposer : cheveux générés d'un côté, visage original de l'autre, avec un masque dilaté et adouci sur la jonction. Le visage n'est plus généré, il est préservé.

Détail qui a coûté une itération : la recomposition doit se faire sur la photo **originale en pleine définition**, pas sur la version réduite envoyée au modèle. Recomposer en définition réduite produit un visage net dans un rendu flou, ce qui se voit immédiatement.

### La latence, en quatre étapes

| Configuration | Latence |
|---|---|
| 20 pas, pleine résolution | 152 s |
| Modèle d'accélération, 8 pas | 54 s à chaud |
| Modèle d'accélération, 4 pas, pleine résolution | 30 s |
| Modèle d'accélération, 4 pas, résolution réduite | **26 s** |

L'objectif était de passer sous 30 secondes. Il a fallu quatre configurations pour y arriver, et une leçon de méthode : **relancer un rendu avec la même graine aléatoire donne 3 secondes**, parce que le serveur de génération sert son cache. Une mesure de performance qui ne varie pas sa graine mesure son cache, pas son modèle.

Un incident au passage : fusionner le modèle d'accélération sur les poids quantifiés au démarrage a fait exploser la mémoire vive du conteneur, qui s'est figé au point que même les commandes d'administration ne répondaient plus. La fusion déquantifie en mémoire. Résolution : porter la mémoire du conteneur de 16 à 32 Go, en permanent.

### L'instruction textuelle ne doit décrire aucune couleur

Mon premier lot de tests utilisait un prompt qui nommait la couleur voulue. Tous les rendus sortaient de cette couleur, quelle que soit la référence du catalogue fournie en image.

Le modèle obéissait au texte plutôt qu'à l'image. Correction : un prompt **neutre**, qui demande explicitement de reprendre la couleur, la longueur, la texture et le style de l'image de référence. C'est la référence qui porte la donnée produit, pas la phrase.

Validé ensuite sur huit modèles de catalogue, du platine au gris en passant par l'auburn ondulé : couleur et style transférés fidèlement depuis des références de catalogue en basse définition.

### Le garde-fou d'identité, et pourquoi son seuil était faux

Un essayage qui déforme le visage doit être refusé automatiquement. D'où une vérification d'identité faciale : comparer le visage du rendu à celui de la photo d'origine, et rejeter en dessous d'un seuil de similarité.

Deux problèmes se sont enchaînés.

**Le premier est juridique.** Le modèle de reconnaissance faciale utilisé pendant l'exploration est sous licence non commerciale. Parfaitement acceptable pour une preuve de concept, inutilisable dans un produit livré. Il a été remplacé par un couple détection plus reconnaissance sous licence Apache 2.0.

**Le second est méthodologique, et c'est le plus instructif.** Le seuil de 0,85 établi avec le premier modèle rejetait absolument tout avec le second. Non pas parce que les rendus s'étaient dégradés, mais parce que **deux modèles de reconnaissance faciale ne produisent pas des scores comparables**. Le maximum atteignable avec le nouveau modèle, sur des paires strictement identiques, était de 0,83.

Recalibrage sur des données réelles, en mesurant les deux populations qui comptent :

| Population | Similarité mesurée |
|---|---|
| Composites de la même personne | 0,64 à 0,83 |
| Visages de personnes différentes | 0,08 à 0,31 |

Les deux distributions sont largement séparées. Seuil retenu : **0,45**, au milieu du fossé.

Un seuil hérité d'un autre modèle n'est pas un seuil, c'est une superstition. Et la bonne façon de le poser n'est pas de viser une valeur, c'est de mesurer où se trouve l'écart entre les deux populations qu'on veut séparer.

### Le faux négatif qui excluait des utilisatrices

C'est le défaut le plus grave de tout le chantier, et il n'est apparu qu'en recette réelle, sur des photos qui n'étaient pas les miennes.

Symptôme : sur certaines photos, le détecteur renvoyait « aucun visage détecté » et le module refusait de traiter. En particulier sur des gros plans, et en particulier sur des peaux foncées.

Deux causes cumulées. Le détecteur analysait la photo en pleine définition, où un visage en gros plan occupe une part de l'image très éloignée de ce sur quoi le modèle a été entraîné : il manquait le grand visage tout en produisant des micro-détections dans le décor. Et le seuil de confiance par défaut, fixé à 0,9, écartait les détections un peu moins nettes, ce qui pénalise mécaniquement les visages moins contrastés.

Correction : détecter sur une **copie réduite** de la photo, abaisser le seuil de confiance à 0,6, et filtrer les détections par leur taille pour écarter le bruit du décor. Validé ensuite sur une photo réelle qui échouait auparavant.

Ce n'est pas un correctif de performance, c'est un **correctif d'inclusivité**. Un module d'essayage qui refuse de traiter la photo d'une partie de ses utilisatrices ne dégrade pas leur expérience : il les exclut du produit, en leur affichant un message qui laisse penser qu'elles ont mal pris la photo. Et aucune métrique technique ne le remonte, puisque le service répond correctement, dans les temps, avec un refus argumenté.

Le seul moyen de le trouver a été de faire tester par de vraies personnes sur de vraies photos. Aucun jeu de test synthétique ne l'aurait révélé.

### L'éphémère se prouve, il ne se déclare pas

La contrainte était qu'aucune photo de visage ne touche jamais un disque. Le serveur de génération d'images utilisé écrit pourtant nativement ses entrées et ses sorties sur disque.

Trois mesures, et une vérification.

L'entrée passe par un composant maison qui reçoit l'image encodée et la transforme directement en tenseur, sans jamais passer par le répertoire d'entrée. La sortie passe par un canal en mémoire plutôt que par l'écriture d'un fichier. Et les trois répertoires de travail du serveur sont montés en mémoire vive, sans possibilité d'être déportés sur disque en cas de pression mémoire.

Puis un script de vérification qui surveille ces répertoires pendant un rendu réel et échoue si le moindre fichier image y apparaît, doublé d'un contrôle que les journaux ne contiennent aucune donnée personnelle.

Une politique de confidentialité qui affirme que rien n'est conservé, sans script qui le vérifie, est une intention. Le script, lui, se rejoue.

### Le pare-feu qu'on n'attendait pas

Dernier obstacle, purement d'exploitation, mais il a bloqué toute la recette : le nœud GPU applique une politique de rejet par défaut avec liste blanche. Les appels de l'application vers le service de rendu tombaient dans le vide, sans erreur explicite côté applicatif.

Règle ajoutée pour le sous-réseau, et surtout **persistée dans la configuration du pare-feu** plutôt que posée à chaud. Une règle réseau qui ne survit pas au redémarrage est une panne différée, qui se déclenchera le jour où personne ne fera le lien.

## Ce que ces deux intégrations ont en commun

Aucun des problèmes qui ont vraiment coûté du temps ne portait sur la qualité du modèle. Ils portaient tous sur ce qu'il y a autour : le seuil hérité d'un autre outil, le prompt qui écrase la donnée d'entrée, le détecteur hors de sa distribution d'entraînement, le cache qui déguise une mesure, la règle de pare-feu, le fichier d'environnement non rechargé.

Deux principes en sortent, et ils valent pour n'importe quelle intégration d'IA dans une application existante.

**Un garde-fou non éprouvé n'est pas un garde-fou.** Le nôtre était correctement codé, correctement appelé, et rejetait tout, parce que son seuil venait d'un autre modèle. Il aurait fallu le tester non pas sur son fonctionnement, mais sur les deux populations qu'il est censé séparer.

**Ce qui ne se voit pas dans les métriques se voit chez les utilisateurs.** Le faux négatif d'inclusivité produisait un service parfaitement sain du point de vue de la supervision : temps de réponse nominal, aucune erreur, un refus argumenté. Il fallait de vraies photos et de vraies personnes pour le trouver.

Le protocole d'exploitation sous lequel ces déploiements ont été conduits, et [ce qu'un agent IA a refusé de faire](/blog/agent-ia-operations-infrastructure-protocole/) une nuit d'août, fait l'objet d'un article séparé.

Hémerson Koffi, fondateur de HK CONSEILS, IA générative souveraine et infrastructures auto-hébergées pour les PME.
