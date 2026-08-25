---
title: "Ce que l'agent a refusé de faire, à 3 h du matin"
description: "Un agent IA a construit et prouvé ma haute disponibilité pendant que je dormais, puis s'est arrêté net avant la bascule. Le protocole qui rend ça possible, les trois fois où il m'a contredit, et la faute qu'il a commise cette nuit-là."
pubDate: 2026-08-22
tags: ["agents", "sre", "iac", "sécurité"]
---

3 h 32 du matin. Les quatre règles DNS qui portent l'ensemble de mes services internes basculent vers une adresse IP virtuelle. Le front web de ma production vient de passer en haute disponibilité.

Tout ce qui a rendu ce geste possible, le serveur jumeau, ses vingt-deux certificats, l'exercice de bascule chronométré, a été construit et prouvé quelques heures plus tôt par un agent IA, sans surveillance, pendant que je dormais.

Le geste lui-même, non. Il m'a attendu.

Cette distinction n'est pas un effet de récit, c'est la règle centrale du protocole que je décris ici. Et ce que cette nuit m'a le plus appris, ce n'est pas ce que l'agent a fait. C'est ce qu'il a refusé de faire, et les trois fois où il m'a contredit avant d'exécuter.

*Opération conduite dans la nuit du 18 au 19 août 2026. Toutes les mesures citées sont celles relevées pendant l'exécution, et non des ordres de grandeur reconstitués.*

## Le principe : l'humain décide, l'agent exécute, le protocole encadre

Je suis consultant en IA générative souveraine et mon infrastructure de production tourne sur quatre serveurs auto-hébergés. Je ne tape presque plus une ligne de commande moi-même : un agent IA exécute, un comité d'experts IA spécifie les opérations, et mon rôle tient en trois verbes. Décider, arbitrer, valider.

Un agent qui exécute sans cadre, c'est un stagiaire brillant avec les droits root et aucune peur de mourir. Le cadre tient en cinq règles. Chacune est née d'un incident réel, aucune d'un principe abstrait.

**1. Le runbook s'exécute à froid.** Chaque opération est spécifiée dans un document autoporteur : contexte, commandes exactes, critères d'acceptation, plan de retour arrière écrit avant l'action. Aucun « comme on a dit », aucun contexte implicite. Si l'agent doit deviner, c'est la spécification qui est fausse, pas l'agent qui est limité.

**2. Les vérifications sont des machines, pas des phrases.** Chaque étape se termine par une porte de contrôle : un test automatique qui interroge le système vivant, jamais un fichier de configuration, jamais une documentation. Si la porte échoue, tout s'arrête. Une consigne du type « vérifier que le service répond » ne vaut rien ; un code de retour qui interrompt le script vaut tout.

Le corollaire s'est appris à nos dépens, cette nuit-là précisément. J'avais écrit une porte sous cette forme :

```bash
code=$(curl -s -o /dev/null -w '%{http_code}' "$URL" || echo 000)
[ "$code" = "200" ] || { echo ABORT; exit 1; }
```

Elle est fausse. Quand `curl` échoue, il a déjà écrit `000` sur sa sortie, et le `|| echo 000` en ajoute un second : la variable vaut `000000`, la comparaison échoue, mais dans d'autres branches du même script la concaténation produisait au contraire une valeur qui passait. **Une porte permissive est plus dangereuse qu'une porte absente, parce qu'elle fabrique de la confiance.** Celle-ci aurait laissé passer un port mort.

**3. On construit et on prouve la nuit ; on ne bascule jamais la nuit.** L'agent avait le droit de créer le serveur jumeau, d'émettre ses certificats, de couper le maître et de chronométrer la reprise sur une adresse que rien ne référençait encore. La bascule du trafic réel, elle, exigeait ma présence. La frontière est simple à énoncer et structurante en pratique : tout ce qui est réversible en secondes se fait sans moi, tout ce qui touche le trafic de production attend un humain réveillé.

**4. Une phase qui bloque devient PENDING, jamais une improvisation.** Cette nuit-là, une phase a échoué sur une clé d'API externe en lecture seule. L'agent n'a pas contourné, n'a pas cherché l'identifiant ailleurs, n'a pas dégradé l'objectif pour faire quand même. Il a documenté la cause exacte, laissé un script prêt à l'emploi et il est passé à la phase suivante, les phases étant indépendantes par construction. Au réveil, il me manquait une action de deux minutes, pas un débogage de trois heures.

**5. Le rapport est obligatoire, déviations comprises.** Chaque exécution produit un compte rendu : ce qui a été fait, ce qui a dévié du plan et pourquoi, ce qui a échoué, et le plus précieux, ce que l'agent a refusé de faire.

## Les trois fois où il a contredit sa propre spécification

Le plus révélateur n'est pas que l'agent ait suivi les runbooks. C'est qu'il les ait contredits, avant exécution, en vérifiant chaque prémisse sur le système réel.

**Le paquet qui n'existe pas.** Le runbook prescrivait d'installer le proxy web depuis le dépôt de la distribution. Vérification faite sur le vivant, la production n'utilise aucun paquet : c'est un binaire compilé sur mesure, avec un module d'émission de certificats que la version standard ne contient pas. Un paquet officiel aurait produit « la même version », incapable de lire la configuration existante. La méthode a été amendée avant exécution : transfert du binaire de production par tube direct entre les deux machines, sans fichier temporaire nulle part, et vérification que l'empreinte SHA-256 est identique de part et d'autre.

**La connexion qui ne passe pas.** Le runbook prescrivait une forme d'accès SSH classique vers un serveur qui n'accepte qu'une clé précise. Sans la porte d'ouverture qui teste l'accès avant de commencer, la phase entière échouait en son milieu.

**La règle DNS qui était quatre.** Le runbook demandait de basculer « la » règle DNS vers la nouvelle adresse. La configuration vivante en comptait quatre, et le runbook interdisait explicitement de toucher aux autres. En le suivant à la lettre, une partie des services serait restée épinglée sur l'ancien serveur, hors haute disponibilité, **et aucune porte de contrôle prévue ne l'aurait vu** : elles ne testaient que des noms couverts par la règle principale. Nous aurions déclaré une bascule réussie à moitié faite.

De cette découverte sont nées deux portes que le runbook n'avait pas. Une porte de témoin, qui interroge un nom jamais déclaré pour tester la règle générique elle-même. Et une porte d'exhaustivité, qui vérifie qu'il ne reste **aucune** règle pointant sur l'ancienne adresse. Vérifier qu'une liste est traitée, c'est bien. Vérifier qu'il n'en reste rien ailleurs, c'est la seule preuve.

> Un agent qui exécute vos ordres est utile. Un agent qui vérifie vos prémisses avant de les exécuter est précieux. Le second ne s'obtient qu'en l'exigeant dans le protocole, et en acceptant qu'il vous contredise.

## Ce qu'il a refusé de faire

Au milieu de la nuit, un moniteur de supervision affiche un service d'inférence en panne. Consigne implicite, réflexe humain comme machine : le redémarrer.

L'agent a refusé, et il a d'abord regardé.

Le journal du service disait `Stopping...` puis `status=0/SUCCESS` : un arrêt délibéré, pas une panne. La place avait été prise par un autre processus, démarré à la seconde même de cet arrêt, et qui tournait depuis plus de dix heures. Surtout, le redémarrage demandé aurait tenté de charger un modèle de 27 Go dans 13,5 Gio de mémoire GPU disponible, en écrasant au passage un test d'endurance de dix heures et deux autres charges qui partagent ces cartes.

Le service, en réalité, était vert. Ce qui était rouge, c'était la sonde : elle interrogeait un port abandonné lors d'une migration antérieure. **Moniteur rouge, service vert.** Le réflexe de chercher pourquoi avant d'agir valait ici plus que l'action elle-même, et la correction a consisté à repointer la sonde après avoir vérifié que le nouveau port répondait et que l'ancien était bien mort.

## L'incident, parce qu'il y en a toujours un

La transparence a un prix d'entrée. Cette nuit-là, l'agent a aussi commis une vraie faute.

En inspectant un fichier de secrets pour n'en afficher que les noms de clés, son expression régulière de masquage ne couvrait pas les entrées de liste YAML, de la forme `      - password: ...`. Le mot de passe d'administration du résolveur DNS s'est affiché en clair dans la sortie de commande, donc dans la transcription de session.

La portée a été établie immédiatement, parce que c'est la première question : le journal de conversation uniquement. Ni dépôt Git, où le coffre est chiffré, ni journal serveur.

Ce qui compte, c'est la suite. Rotation le jour même, dans le bon ordre : le nouveau secret est déposé au coffre **avant** d'être appliqué, pour que l'échec de l'application ne le perde pas. Le nouveau mot de passe est vérifié contre son propre hachage avant toute écriture. Il est transmis par l'entrée standard et jamais en argument de commande, pour ne pas fuiter une seconde fois par la liste des processus. Coupure DNS mesurée pendant le redémarrage, avec une sonde toutes les 50 ms : 311 ms.

Puis le contrôle qui compte vraiment. Il ne suffit pas que le nouveau fonctionne, il faut que l'ancien soit mort :

| Sonde | Résultat |
|---|---|
| Ancien mot de passe, celui qui a fuité | HTTP 401, refusé |
| Nouveau mot de passe, relu depuis le coffre | HTTP 200, accepté |
| Témoin, mot de passe inventé | HTTP 401, la sonde discrimine |

Le troisième test existe pour prouver que la vérification discrimine au lieu de tout accepter. Sans lui, deux 401 ne prouvent rien.

La leçon est devenue une règle : **on ne masque jamais un secret par recherche de motif.** Un motif de liste, une indentation inattendue, et la valeur passe. La méthode fiable est de parcourir la structure de données et de n'afficher que les types et les longueurs.

## La règle 2 a fini par devenir une machine

Une doctrine écrite ne suffit pas. En une seule journée de travail en parallèle, quatre dérives silencieuses sont apparues : un serveur jumeau désynchronisé, une sauvegarde absente depuis cinq semaines, une sonde visant un port mort, des secrets non sauvegardés. Aucune n'a été détectée par un mécanisme, toutes l'ont été à la main, tardivement.

Deux garde-fous en sont sortis, tous deux opposables.

**Un contrôle de dérive**, qui vérifie neuf invariants sur la cible vivante, chacun issu d'une panne réellement survenue et non d'une hypothèse : les deux configurations du couple doivent être identiques au SHA-256, l'adresse virtuelle doit être portée par exactement un nœud, aucune sonde ne doit viser un port fermé, aucune sauvegarde ne doit avoir plus de 48 heures. Trois choix de conception y font toute la différence. Un contrôle qui plante compte comme une dérive et non comme un vert, parce qu'un contrôle muet ne doit jamais ressembler à un contrôle satisfait. Il ne publie que s'il a quelque chose à dire, sur le canal que les gens lisent déjà. Et il a été validé par témoin inverse : une dérive introduite volontairement déclenche bien l'alerte, et le retour au vert est vérifié après restauration.

Ce dernier point est le vrai enseignement de l'affaire de la sauvegarde manquante. Le collecteur écrivait fidèlement `MISSING:` dans son journal **chaque nuit depuis cinq semaines**, parmi quinze autres lignes. Ce n'est pas la détection qui a manqué, c'est la lecture du signal.

**Un refus de commit sur secret non acquitté.** Le balayage anti-secrets existait déjà, sous forme de consigne, et deux commits sont passés sans que les correspondances soient inspectées. Les deux étaient des faux positifs, mais le hasard n'est pas une méthode et un `git push` est irréversible. La règle est devenue un refus : le commit est bloqué tant que chaque correspondance n'est pas acquittée. L'acquittement porte sur l'empreinte de la ligne, donc si la ligne change, il tombe et le commit est de nouveau bloqué. Et le garde-fou **n'affiche jamais la valeur suspecte**, seulement son emplacement et sa longueur : un outil qui recopie le secret dans le terminal le fait fuiter lui-même, ce qui aurait été reproduire l'erreur du matin dans l'outil censé la prévenir.

Sa limite, parce qu'un dispositif dont on ne publie pas la limite n'est pas un dispositif : le chemin des hooks est une configuration locale, non clonée. Un dépôt recloné n'a plus le garde-fou tant que la commande n'est pas rejouée.

## Les chiffres de la nuit

Cinq phases sur six en réussite, une en attente propre.

Un serveur jumeau construit à l'identique, avec une définition stricte du mot : même artefact, vérifié par empreinte SHA-256 identique de part et d'autre, et non « même numéro de version obtenu autrement ».

Vingt-deux certificats émis en 90 secondes, après que l'agent a compté de lui-même le quota restant chez l'autorité de certification. Ce comptage ne figurait dans aucun runbook : il est né de la contrainte « ne pas dégrader la production », le quota étant partagé avec les renouvellements de production. Vingt-deux certificats au magasin mais deux seulement émis sous sept jours, soit 24 sur 50. Marge suffisante. Sans cette vérification, une phase censée être sans impact aurait pu griller le quota de la production.

Un basculement mesuré à 3 222 ms, service servi en HTTP 200 pendant toute la transition. Retour du maître en 6 755 ms, ce qui est le délai de préemption normal du protocole VRRP et non une anomalie, le service restant servi tout du long.

Et un écart de performance entre l'original et son jumeau de 3,2 % et 5,3 % selon les routes, **après** que l'agent a détecté et corrigé un biais dans sa propre première mesure. Cette première série donnait le jumeau une fois et demie plus lent. Le protocole était fautif : les deux machines étaient interrogées successivement avec un prompt identique, si bien que la seconde bénéficiait d'un cache chaud côté serveur. Remesure avec un prompt unique par appel et un ordre alterné, deux passes. L'écart initial était un artefact de mesure, pas une propriété du système.

## Ce que ça change pour une PME

Rien de tout cela n'est spécifique à mon infrastructure. Spécifier avant d'exécuter, vérifier sur le vivant, séparer le réversible de l'irréversible, exiger le rapport : c'est ce qu'on attend d'une équipe d'exploitation senior.

La différence, c'est que l'agent applique ces règles à 3 h du matin, sans fatigue, sans ego, et documente tout, à condition qu'on ait pris le temps de les écrire. Et qu'il s'arrête à la frontière qu'on lui a tracée, y compris quand tout est prêt et qu'il ne reste qu'un geste à faire.

C'est exactement le travail que je fais pour mes clients : non pas brancher une IA, mais construire le protocole qui la rend digne de confiance. L'IA en production est une affaire d'ingénierie de processus, et c'est là que se joue la différence entre un gadget et un levier.

Le dispositif de [haute disponibilité](/blog/haute-disponibilite-proxmox-sans-cluster/) construit cette nuit-là, ses trois couches et ses limites, fait l'objet d'un article séparé.

Hémerson Koffi, fondateur de HK CONSEILS, IA générative souveraine et infrastructures auto-hébergées pour les PME.
