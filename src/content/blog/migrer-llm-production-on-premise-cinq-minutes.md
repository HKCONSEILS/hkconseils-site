---
title: "Migrer un LLM de production en moins de 5 minutes"
description: "Cinq jours après sa sortie, un modèle de 27 milliards de paramètres remplaçait celui qui sert un assistant en production, sur du matériel auto-hébergé. La méthode de dé-risquage, l'arbitrage qui nous a fait renoncer à 50 % de débit, et les mesures qu'il a fallu jeter."
pubDate: 2026-08-23
tags: ["llm", "mlops", "gpu", "souveraineté"]
---

Mi-août 2026, Alibaba publie Qwen3.8-27B. Cinq jours plus tard, ce modèle remplaçait celui qui sert un assistant conversationnel en pilote chez un client du secteur santé, sur une infrastructure entièrement auto-hébergée. Fenêtre d'indisponibilité : moins de cinq minutes.

Cinq jours, ce n'est pas un exploit de vitesse. C'est le résultat d'un travail de reconnaissance qui a commencé par établir **où était réellement le risque**, et la réponse a orienté tout le reste.

*Modèle publié à la mi-août 2026. Reconnaissance amont le 17 août, validation isolée les 17 et 18 août, bascule de production le 19 août 2026 à 03 h 45. Les mesures sont celles relevées pendant la campagne.*

## Le fait qui a tout structuré : il n'y avait rien de nouveau dans les noyaux

La première question posée au dossier n'était pas « ce modèle est-il meilleur » mais « qu'est-ce qui, dans notre chaîne, ne sait pas encore le faire tourner ».

Réponse : rien. Qwen3.8 **n'introduit aucune architecture nouvelle**. C'est la même famille hybride que la génération précédente, connue du moteur d'inférence open source depuis février 2026, et l'opération de calcul spécifique à son mécanisme d'attention linéaire y a été fusionnée en mars. Nous cherchions un jalon « le moteur rattrape le modèle » : ce jalon n'existait pas.

Cela explique le support immédiat constaté le jour de la sortie. Et surtout, **cela déplace le risque des noyaux de calcul vers l'outillage de service** : le gabarit de conversation, le décodage spéculatif, la répartition sur plusieurs GPU. C'est là que l'effort a été mis, et c'est pour ça que la fenêtre a duré quatre minutes.

## Pourquoi migrer, chiffres à l'appui

Le modèle est dense, 27 milliards de paramètres, multimodal texte et vision, sous licence Apache 2.0, bâti sur une attention hybride mêlant attention linéaire et attention classique compressée. Conséquence directe pour un déploiement local : le cache de contexte cesse d'être le goulot d'étranglement mémoire, et le débit ne s'effondre plus quand les conversations s'allongent.

Or c'était exactement le point faible de notre production. Sur nos deux références internes du modèle précédent, mesurées sur le même matériel, le débit tombait de 30,6 à 18,7 tokens par seconde entre une requête courte et une requête profonde. Pour un assistant qui traite des dossiers longs, c'est la différence entre fluide et pénible.

## Un modèle de cinq jours ne se déploie pas, il s'instruit

Un modèle publié depuis moins d'une semaine, c'est un écosystème instable. Au moment de la reconnaissance initiale : **quatorze anomalies déclarées en 72 heures** sur le moteur d'inférence, des quantifications susceptibles d'être republiées sans préavis, et un gabarit de conversation truffé de cas d'erreur non gérés.

La réponse n'est pas d'attendre six mois. C'est de figer, puis de prouver.

**Reconnaissance formelle avant tout geste.** Inventaire des artefacts avec empreintes SHA-256, audit des anomalies amont, et choix d'un commit précis du moteur d'inférence, épinglé et justifié. Le critère du choix mérite d'être explicité : nous avons retenu le dernier point de version contenant **tout** ce dont le modèle a besoin, et **antérieur** à deux refontes internes du serveur vieilles de moins de 48 heures. Épingler la dernière version disponible aurait embarqué deux chantiers non éprouvés sans aucun bénéfice.

**Validation complète sur un GPU secondaire**, sans toucher à la production : gabarit de conversation assaini, appels d'outils, vision, et un test d'endurance avec relevé mémoire horaire.

**Re-reconnaissance la veille de la bascule.** Entre-temps, la branche principale du moteur avait avancé de **55 commits et 9 versions**. Verdict : **zéro correctif utile à notre configuration**, aucun touchant la famille de modèles concernée. Épinglage confirmé. On ne bascule pas sur un socle qu'on n'a pas re-vérifié, et confirmer un épinglage est un résultat au même titre que le changer.

## Le gabarit officiel en comptait neuf, pas cinq

Le gabarit de conversation, ce petit programme qui transforme une liste de messages en une chaîne de caractères pour le modèle, est la pièce la plus sous-estimée d'un déploiement local. Celui du modèle contient des levées d'exception : des cas où il refuse de produire une sortie, ce qui remonte à l'application sous forme d'erreur 400 sans explication utilisable.

Notre spécification, écrite d'après la lecture de la documentation, en annonçait cinq. Le comptage sur le fichier réel en a trouvé **neuf**. Quatre cas d'erreur nous seraient tombés dessus en production sans que rien ne les ait anticipés.

Le gabarit assaini les neutralise toutes, avec un contrôle de disparition (zéro occurrence après traitement) et une porte de validation qui envoie trois cas volontairement empoisonnés et exige un HTTP 200. Effet de bord utile : un rôle de message annoncé par le distributeur mais non géré par le gabarit officiel ne provoque plus d'erreur, il est replié sur un rôle valide.

**Un second piège, plus sournois.** Avec le raisonnement actif par défaut et une allocation de sortie serrée, deux complétions de test sur trois renvoyaient un contenu **vide**, avec uniquement le bloc de réflexion. HTTP 200, aucune erreur, aucun message. Il faut soit une allocation généreuse, soit un plafond explicite sur le budget de réflexion. Un modèle à raisonnement qui renvoie du vide sans se plaindre est un mode de défaillance à connaître avant de le découvrir en production.

## Le soak a été refait quatre fois, et c'est la meilleure partie de l'histoire

Le test d'endurance, ou *soak*, est censé prouver qu'un service tient dans la durée. Le nôtre a été remis à zéro trois fois, et chaque remise à zéro dit quelque chose.

**Version 1** exerçait le décodage spéculatif. Mais la décision produit venait d'écarter le décodage spéculatif de la production : le soak validait une configuration qu'on ne déploierait pas.

**Version 2** l'a retiré, et a surtout changé la sonde : elle envoie désormais **quatre requêtes simultanées** et n'inscrit un succès que si les quatre créneaux répondent. Une sonde séquentielle ne teste aucune file d'attente. Elle aurait validé pendant 24 heures exactement ce que la décision produit venait de mettre au centre, sans jamais l'exercer une seule fois.

**Version 3** a ajouté la vision, qui venait d'être arbitrée.

**Version 4** a ajouté une image dans la sonde horaire elle-même. La version 3 était textuelle : elle aurait inscrit des succès pendant 24 heures sur une configuration qui sort de son budget mémoire dès qu'une image arrive. **Un test d'endurance qui valide tout sauf le mode de défaillance connu ne vaut pas grand-chose.**

Chaque remise à zéro a été décidée tôt, quand elle coûtait encore une heure et pas vingt. Le résultat final : treize relevés espacés d'une heure, chacun incluant un traitement d'image, avec une empreinte mémoire **stable à l'octet près**. Écourté à dix heures sur les 24 prévues, sur décision, pour rendre plus tôt le GPU à un autre chantier. Le signal était net et vingt-quatre heures auraient dit la même chose plus longtemps.

## L'arbitrage contre-intuitif : renoncer à 50 % de débit

Le modèle embarque une tête de prédiction multi-tokens, une forme de décodage spéculatif. Nos mesures sur corpus réel sont sans ambiguïté : **+46 % à +62 %** de débit de génération en flux unique, selon la profondeur et le nombre de tokens spéculés.

Nous l'avons écarté de la production. Trois raisons, dont deux que le chiffre de tête masque.

**Ce n'est pas la bonne métrique.** Un assistant qui sert plusieurs utilisateurs simultanés n'a pas besoin de vitesse sur un flux unique, il a besoin de créneaux parallèles pour absorber la file d'attente.

**Le gain n'est pas net.** Le décodage spéculatif coûte **7 à 11 % de prefill**. Sur une charge à prompt long et génération courte, ce qui est exactement le profil d'un assistant documentaire, le bilan est bien moins favorable qu'il n'y paraît.

**C'est un budget mémoire à trois variables.** La tête spéculative consomme **1 854 Mio** de VRAM. Sur la carte de validation, contexte long et gain spéculatif **s'excluaient** : les deux ensemble dépassaient la carte, et le contexte long seul échouait déjà la porte de contrôle de 101 Mio. Contexte, créneaux parallèles, spéculation : on n'en prend que deux.

> Un benchmark ne dit jamais quoi faire. Il donne le prix exact de chaque option, et c'est le contexte produit qui tranche.

Épilogue involontaire : deux jours après la décision, **quatre des onze nouvelles anomalies** déclarées en amont concernaient le décodage spéculatif. Une décision de capacité s'est révélée être aussi une décision de stabilité.

## La fenêtre de bascule, minute par minute

Les deux GPU portaient la pile vivante. Aucun service parallèle n'était physiquement possible, donc une fenêtre de maintenance assumée, et non une bascule à chaud de plaquette commerciale.

La règle, écrite avant d'ouvrir : **toute porte de contrôle qui échoue déclenche un retour arrière, jamais un débogage à chaud.** La fenêtre se referme dans un état qui fonctionne, ou elle ne se referme pas.

```
03:45:18  arrêt de l'ancien modèle   -> les deux GPU libérés en 0 s
03:45:23  démarrage du nouveau       -> prêt en 5 s (cache de page chaud)
   ...    portes de contrôle
~03:49    bascule du routage API
```

Le budget mémoire a été **mesuré sous charge réelle, jamais estimé depuis la taille du fichier** :

| Étape | VRAM, maximum des deux cartes |
|---|---|
| Au chargement | 20 141 Mio |
| Après la première image | 20 391 Mio |
| Pic sous charge, une requête longue et trois courtes | 20 391 Mio |

Porte franchie au premier échelon : pic à 20 391 Mio pour un seuil de sécurité fixé à 23 540, soit **4 173 Mio de marge**, avec un contexte de 393 216 tokens réparti en quatre créneaux et la vision active.

La ligne intéressante est la deuxième. La vision ajoute une **marche constante** et non un coût proportionnel : +250 Mio ici, sur une carte de 24 Go en 8 bits, contre +284 Mio mesurés en validation sur une carte différente et une quantification différente. C'est la partie du comportement qui se transpose d'une topologie à l'autre ; les valeurs absolues, non. Savoir ce qu'un benchmark autorise à généraliser vaut autant que le benchmark.

Parmi les autres portes de ces quelques minutes : la sortie JSON stricte, précisément le cas que l'ancien modèle ratait ; la vision de bout en bout à travers la passerelle d'API et pas seulement contre le serveur d'inférence ; et un test d'identité, le modèle devant assumer le rôle défini par l'application sans dériver ni nier sa propre existence.

## Deux gestes d'exploitation qui n'ont l'air de rien

**L'inversion des démarrages automatiques a été avancée.** Le plan la plaçait après le test d'endurance. Elle a été faite tout de suite, parce que l'asymétrie du risque le commandait : un redémarrage du serveur aurait relancé l'ancien modèle sur son port pendant que la passerelle d'API interroge le nouveau. Ce n'est pas un retour à l'ancien, c'est une panne franche. Un rollback partiel est pire que pas de rollback.

**Le fichier de configuration de la passerelle a été écrit en place, jamais par renommage.** Il est monté depuis l'hôte dans le conteneur : un outil qui écrit par fichier temporaire puis renommage change l'inode, et le conteneur continue de lire l'ancien contenu sans que rien ne le signale. L'inode a été relevé avant et après chacune des deux éditions, et l'empreinte côté hôte comparée à l'empreinte relue **depuis l'intérieur du conteneur**.

Même logique pour la publication des 30 Go de poids dans le conteneur d'inférence : lien physique plutôt que copie, inodes partagés vérifiés, empreintes relues depuis le conteneur, **zéro octet consommé**.

## Les résultats, mesurés

Les baselines du nouveau modèle, mesurées sur la configuration de production :

| Profondeur du prompt | Prefill | Temps au premier token | Génération |
|---|---|---|---|
| ~15 tokens | 77,3 t/s | ~0,2 s | 30,22 t/s |
| 4 379 tokens | 2 404,9 t/s | ~1,8 s | 30,01 t/s |
| 53 868 tokens | 1 992,0 t/s | ~27 s | 27,08 t/s |

La comparaison qui compte est celle de la **pente**, pas celle de deux nombres pris à des profondeurs différentes. L'ancien modèle tombait de 30,6 à 18,7 tokens par seconde entre requête courte et requête profonde. Le nouveau passe de 30,2 à 27,1 entre 15 et 53 868 tokens. **La dégradation en profondeur est nettement moindre**, ce qui était précisément l'objectif de la migration.

Une réserve de procédure, que je préfère écrire : ces baselines ont été prises **après** la fenêtre et non pendant, contrairement à ce que le plan prévoyait. Sans conséquence ici, le service étant stable, mais l'ordre n'a pas été respecté.

Le reste :

| Indicateur | Avant | Après |
|---|---|---|
| Réponses vides sur notre suite de non-régression | 4 / 10 | 1 / 10 |
| Sortie JSON stricte | échec | succès |
| Marge mémoire en production | | 4,1 Go |
| Indisponibilité pendant la bascule | | moins de 5 minutes |
| Retour arrière | | cible sous 10 minutes, actifs vérifiés et gelés 30 jours |

La dernière ligne mérite sa formulation exacte. Le retour arrière **n'a pas été exécuté**, donc sa durée n'est pas mesurée : c'est une cible. Ce qui a été fait, et qui est vérifiable, c'est que ses actifs sont présents et gelés pour trente jours, poids de l'ancien modèle, ancien jeu binaire, archive de sauvegarde, instantané. Écrire « testé » là où on n'a que « préparé » est le genre de raccourci qu'un lecteur technique vérifiera.

## Les erreurs qu'on assume

Le rapport de migration contient une section que peu de prestataires écrivent : le journal des mesures invalidées. Deux campagnes de benchmark ont été jetées, un corpus dégénéré gonflant artificiellement les gains, et des profondeurs de contexte comptées en mots au lieu de tokens. Les chiffres ci-dessus sont ceux qui ont survécu à leur propre autopsie.

Mais la classe d'erreur la plus instructive est ailleurs, et elle est systématique.

**Cinq contrôles écrits pendant cette campagne ont échoué sur des objets parfaitement sains.** Une extraction de secret sans extension de fichier. Une chaîne formatée contenant un antislash. Un comptage qui renvoie zéro sous un mode d'arrêt strict. Une lecture de configuration tronquée. Et la plus grave, une sonde de supervision qui a déclaré le service en panne **pendant quatre heures**, alors qu'il était parfaitement sain.

Le motif est constant : **l'erreur porte sur la façon d'extraire ou d'invoquer, jamais sur l'objet vérifié.** Pour la sonde, la cause tient en une ligne : la commande utilisée vit dans un répertoire que le planificateur de tâches ne met pas dans son chemin d'exécution, contrairement au terminal interactif où la sonde avait été validée. La parade, désormais systématique : **rejouer toute porte de contrôle dans le contexte exact où elle vivra**, en environnement vidé, jamais depuis un terminal privilégié. Le journal fautif a été conservé et non effacé, avec un nom qui dit ce qu'il est : c'est lui qui documente la leçon.

Un dernier piège de la même famille, pendant la fenêtre. Toutes les portes de contrôle renvoyaient soudain 400. J'ai d'abord conclu à une panne générale de la passerelle. En réalité, la clé d'authentification lue dans le fichier de configuration était périmée, la vraie venant d'une variable d'environnement. **Aucune porte n'avait échoué : ma sonde s'authentifiait avec une clé morte.**

**Et une sixième erreur, d'une autre nature, plus grave dans un rapport.** J'ai affirmé à plusieurs reprises, puis inscrit en tête des réserves d'un rapport livré, que la supervision pointait encore l'ancien port. C'était faux. L'origine : j'avais constaté que l'interface web de supervision me refusait l'accès, et j'en avais **déduit** l'état des sondes, sans jamais le vérifier alors que la base de données était lisible depuis le début.

La règle qui manquait tient en une phrase : **ne pas déduire l'état d'un système de l'impossibilité de l'interroger.** Un contrôle qui casse se voit ; une inférence non étayée se propage, et celle-ci a traversé trois échanges puis un rapport livré.

## Ce qui manque encore

Le service le plus critique de l'infrastructure n'a qu'une sonde de vivacité, sans sonde de complétion de bout en bout, alors que deux serveurs d'inférence moins critiques en ont une.

Ce n'est pas un détail théorique. La doctrine vient d'un incident où la passerelle d'API a renvoyé HTTP 200 pendant six heures quarante-cinq avec un serveur d'inférence mort derrière elle. Une sonde de vivacité ne prouve pas qu'un modèle sait répondre. La sonde de soak comble ce trou aujourd'hui, mais elle est temporaire et disparaît à la clôture du test d'endurance.

C'est écrit dans le rapport, en réserve ouverte, parce qu'une limite connue et publiée coûte moins cher qu'une limite découverte.

## Le non-événement qui valait une vérification

Quelques heures après la bascule, le distributeur des poids quantifiés a publié une nouvelle version majeure de sa méthode de quantification. Réflexe naturel : faut-il refaire la migration ?

Vérification faite : les deux artefacts en service sont **inchangés au bit près**, et la nouvelle méthode ne porte que sur les quantifications basses, hors du périmètre de ce qui tourne. Aucune action.

Savoir démontrer qu'une publication amont **ne vous concerne pas** vaut autant que savoir migrer. C'est la différence entre suivre une actualité et exploiter un système.

## Ce que cette migration dit de l'IA souveraine en 2026

Un modèle de 27 milliards de paramètres, avec vision et 393 000 tokens de contexte, tient aujourd'hui sur deux GPU grand public, et surclasse son prédécesseur sur tous nos indicateurs. Faire tourner l'IA générative sur son propre matériel, sans que les données quittent l'entreprise, n'est plus un pari technique.

Le pari s'est déplacé. Il n'est plus dans le modèle ni dans le matériel, il est dans la méthode : savoir épingler, savoir mesurer sur sa propre charge, savoir jeter une mesure fausse, et savoir écrire ce qu'on n'a pas encore couvert.

Hémerson Koffi, fondateur de HK CONSEILS, IA générative souveraine et infrastructures auto-hébergées pour les PME.
