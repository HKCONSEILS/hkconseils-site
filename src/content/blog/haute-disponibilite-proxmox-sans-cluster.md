---
title: "Haute disponibilité Proxmox sans cluster"
description: "Quatre nœuds autonomes, du stockage local, des GPU épinglés, et pourtant des services qui survivent à la perte d'un serveur. Sans corosync, sans quorum, sans Ceph. Les mesures, les pièges d'exploitation, et ce qui n'est pas encore en place."
pubDate: 2026-08-21
tags: ["proxmox", "haute disponibilité", "sre", "keepalived"]
---

Quand une infrastructure Proxmox grossit, le réflexe est d'assembler un cluster corosync. C'est parfois la bonne réponse. Sur un parc comme le mien, quatre nœuds autonomes, stockage 100 % local, conteneurs LXC, GPU passés en direct à des charges d'inférence, c'est la mauvaise, et il vaut la peine d'expliquer pourquoi avant de montrer l'alternative.

*Dispositif construit dans la nuit du 18 au 19 août 2026, bascule du trafic le 19 août au matin, corrections de dérive le soir du même jour. Les mesures sont celles relevées pendant ces opérations.*

## Le réflexe cluster, et pourquoi il est souvent faux

Un cluster apporte essentiellement de la mobilité : migration de machines virtuelles, groupes de haute disponibilité, bascule automatique. Mais chacun de ces bénéfices exige un prérequis que ce type de parc ne remplit pas.

La migration à chaud exige du stockage partagé, Ceph ou réplication ZFS des deux côtés. Les conteneurs ne migrent de toute façon qu'à froid. Et un conteneur qui tient un GPU par son identifiant matériel n'a aucun sens ailleurs que sur son hôte.

Restent les coûts, eux bien réels. Le quorum, d'abord : trois nœuds dont un en maintenance et un qui redémarre, et toute la flotte passe en lecture seule. Un réseau dédié à faible latence, ensuite. Et un système de fichiers de configuration répliqué qui transforme un incident corosync en incident global.

En résumé : tous les inconvénients, pour des bénéfices que la topologie neutralise.

La bonne question n'est pas « comment rendre mes hyperviseurs mobiles » mais « quels services doivent survivre à la perte d'un nœud, et comment ». La haute disponibilité se construit alors une couche au-dessus, service par service.

## Étape zéro : cartographier ce qui meurt avec chaque nœud

Avant toute solution, un inventaire brutal : pour chaque nœud, la liste de ce qui s'éteint avec lui.

Chez moi, le résultat était sans appel. Un seul nœud concentrait le DNS du réseau, le reverse proxy de tous les services et la passerelle d'inférence. Avec une ironie que je n'avais pas vue venir : **la stratégie de secours dans le cloud pour l'inférence passait par cette même passerelle, donc par ce même nœud.** Le plan de secours dépendait de la survie de ce qu'il était censé secourir.

De cet inventaire sort un classement honnête.

- **Tier A, doit survivre** : résolution DNS, front HTTP, passerelle d'inférence, chaîne d'alerte.
- **Tier B, quelques heures d'indisponibilité acceptables** : gestionnaire de mots de passe (les clients gardent un cache local chiffré), outils d'administration.
- **Tier C, différable** : sauvegardes, inférence GPU locale, dont le secours est le repli cloud du tier A.

## Couche 1, le DNS : la redondance la moins chère, et celle que je n'ai pas encore

Le DNS sait faire de la haute disponibilité depuis quarante ans : deux résolveurs sur deux nœuds, annoncés tous les deux par le DHCP. Aucun logiciel exotique. C'est la couche au meilleur rapport bénéfice sur effort.

C'est aussi celle qui n'est pas en place chez moi au moment où j'écris. Je la mentionne en premier parce que **l'ordre des couches n'est pas décoratif** : tant qu'elle manque, la couche 2 ci-dessous ne protège pas de ce qu'on croit, et j'y reviens en fin d'article.

## Couche 2, le front HTTP : un jumeau exact et une adresse virtuelle

Le cœur du dispositif : deux instances du reverse proxy sur deux nœuds physiques distincts, et une adresse IP virtuelle portée par keepalived en VRRP. Le maître détient l'adresse ; s'il meurt, le second la reprend.

Mesuré chez moi, en coupant le maître pour de vrai :

| Étape | Mesure |
|---|---|
| Reprise de l'adresse par le second nœud | 3 222 ms |
| Requête sur l'adresse virtuelle pendant la bascule | HTTP 200 |
| Retour de l'adresse au maître après redémarrage | 6 755 ms |
| Requête après retour | HTTP 200 |

Le retour est plus lent que la bascule. C'est le délai de préemption du maître avec un intervalle d'annonce d'une seconde, comportement normal de VRRP, et sans conséquence puisque le service reste servi pendant tout l'intervalle.

### La règle du jumeau, et sa définition stricte

Le mot important est *jumeau*, et il ne veut pas dire ce qu'on croit :

```
jumeau = même artefact (empreinte) + même lanceur + mêmes paramètres
jumeau != même numéro de version obtenu autrement
```

Mon proxy de production est un binaire compilé sur mesure, avec un module DNS pour l'émission de certificats. Le jumeau reçoit ce binaire, copié par tube direct entre les deux machines et vérifié par empreinte SHA-256 : **l'empreinte est l'épinglage**. J'ai vu la tentation inverse de près, puisque le runbook initial prescrivait d'installer le paquet de la distribution : il aurait produit « la même version », incapable de lire la configuration existante.

Même chose pour la passerelle d'inférence, dont la production tourne en conteneur Docker. Le runbook prescrivait une installation par gestionnaire de paquets Python, à la même version. La production n'utilise pas ce mode : c'est une image épinglée par empreinte. Une installation « équivalente » aurait produit un artefact différent sous le même numéro de version, soit exactement l'inverse de ce qu'un jumeau doit être.

### Un jumeau se désynchronise en heures, pas en mois

C'est le point que je n'avais pas anticipé. Le jour même de la construction, un service d'authentification a été ajouté sur le nœud maître seul. **Écart apparu en moins de douze heures.** Une bascule de l'adresse virtuelle aurait rendu ce service injoignable, et accessoirement supprimé la protection d'accès à sa console d'administration.

La réponse structurelle serait de faire générer les deux configurations par le même rôle d'automatisation. Je ne l'ai pas : mon rôle de reverse proxy pilote la couche publique en périphérie, pas le proxy interne, et mon inventaire d'automatisation ne connaît même pas encore les deux conteneurs du couple. C'est un chantier, pas un acquis.

Ce que j'ai mis en place à la place, dans l'intervalle, est plus modeste et plus honnête : un invariant vérifié deux fois par jour sur la cible vivante, qui compare les empreintes SHA-256 des deux configurations et alerte dès qu'elles divergent. Validé par témoin inverse, c'est-à-dire en introduisant volontairement une divergence pour vérifier que l'alerte part, puis en vérifiant le retour au vert après restauration.

Autrement dit : je n'ai pas encore empêché la dérive, je l'ai rendue impossible à ignorer. Les deux ne se valent pas, et il vaut mieux le dire que le laisser croire.

### Deux pièges d'exploitation

**Le quota de l'autorité de certification.** Émettre d'un coup les vingt-deux certificats du jumeau consomme le quota hebdomadaire du domaine, quota partagé avec les renouvellements de production. Il faut compter avant d'émettre : dans mon cas, vingt-deux certificats au magasin mais deux seulement émis sous sept jours, soit 24 sur 50. L'émission a pris 90 secondes et n'a rien mis en danger, mais c'est une vérification faite avant, pas un constat fait après.

**La supervision devient contre-intuitive.** Avec une adresse virtuelle, la sonde qui traverse la chaîne complète reste verte quand une seule instance meurt. C'est le but. Il faut donc des sondes par instance, en direct sur chaque nœud, pour voir que la redondance est dégradée avant que la seconde instance ne tombe aussi.

Et là, un piège que j'ai découvert en essayant : la sonde HTTP par instance ne marche pas. Interroger `https://<ip-du-noeud>/` avec un en-tête `Host` ne suffit pas, parce que le nom présenté dans l'en-tête n'est pas celui présenté dans la négociation TLS. Le proxy refuse, la requête retourne un code nul des deux côtés, et la sonde a l'air de dire que les deux instances sont mortes. Seule l'option de résolution forcée de `curl` fonctionne, et mon outil de supervision ne sait pas la produire.

J'ai donc posé des sondes TCP sur le port 443, avec leur limite écrite noir sur blanc dans la description de chaque sonde : **elles prouvent que l'instance écoute, pas qu'elle sert correctement.** Un contrôle HTTP complet par instance exigerait deux noms DNS dédiés donnant un nom TLS valide. C'est au backlog, et le dire vaut mieux que laisser croire que la supervision est complète.

Dernier détail de convention, qui évite une collision future : une adresse portée par une adresse virtuelle n'appartient à aucun invité. Si votre plan d'adressage lie les adresses aux identifiants de machines, l'identifiant correspondant doit être gelé explicitement, sinon quelqu'un le réutilisera. J'ai dû corriger dans la foulée un inventaire qui listait encore cette adresse parmi les disponibles : publier la règle tout en laissant l'adresse dans la liste des libres aurait créé une contradiction directement exploitable par la prochaine attribution.

## La bascule elle-même : atomique, et prouvée sur le vivant

Le jour du basculement, la question n'est pas « est-ce que ça va marcher » mais « est-ce que la manœuvre a une fenêtre sans réponse ».

L'API du résolveur DNS expose un point de terminaison de mise à jour de règle. Avant de l'utiliser, je l'ai interrogé pour établir son comportement réel plutôt que de le supposer :

- `POST` et `PATCH` renvoient **405, « only method PUT is allowed »** ;
- un `PUT` sur une cible inexistante renvoie **400, « target rule not found »**.

Le second point est le plus important : il prouve que le point de terminaison valide sa cible. La bascule est donc **atomique par règle**, sans suppression suivie d'un ajout, donc sans fenêtre pendant laquelle un nom ne résout plus. C'est le genre de détail qu'on ne trouve pas dans la documentation et qui se règle en trois requêtes de reconnaissance.

Le rollback a été écrit **avant** le basculement, rendu idempotent, et essayé à blanc pour vérifier qu'il ne trouvait effectivement rien à annuler tant que rien n'avait bougé.

Et le runbook, écrit d'après ma propre mémoire de la configuration, se trompait : il ne basculait qu'une règle sur quatre, et interdisait explicitement de toucher aux autres. En le suivant, une partie des services serait restée épinglée sur l'ancien nœud, hors haute disponibilité, sans qu'aucune porte de contrôle prévue ne le détecte, puisqu'elles ne testaient que des noms couverts par la règle générique.

Deux portes ont été ajoutées. Un **témoin** qui interroge un nom jamais déclaré, pour tester la règle générique elle-même plutôt que ses effets connus. Et une **porte d'exhaustivité** qui vérifie qu'il ne reste aucune règle pointant sur l'ancienne adresse. Vérifier qu'une liste a été traitée est insuffisant ; vérifier qu'il n'en reste rien ailleurs est la seule preuve.

## Savoir innocenter son propre changement

Douze minutes après la bascule, trois moniteurs passent au rouge et un service répond 502. Le réflexe est de rollbacker.

Trois preuves ont montré que le changement était innocent :

1. le 502 est **identique par les trois chemins**, en attaquant directement l'ancien nœud, le nouveau, et l'adresse virtuelle ;
2. le serveur applicatif déclaré derrière ce nom est **injoignable en TCP**, indépendamment de tout proxy ;
3. l'historique de supervision est sans appel : ces trois moniteurs sont en panne depuis la veille, soit **720 relevés consécutifs, zéro succès en douze heures**, quatorze heures avant le basculement. Sur la même fenêtre, les autres moniteurs affichent 720 succès et zéro échec.

Savoir démontrer qu'un incident concomitant n'est pas causé par son propre changement est une compétence d'exploitant, et elle se prépare : sans historique de supervision daté, ces trois preuves n'existaient pas.

## Couche 3, le stateful en pilot light

Pour les services à état du tier B, la redondance active coûte plus qu'elle ne rapporte. La réponse visée est le *pilot light* : les sauvegardes tournent déjà, on automatise leur restauration périodique vers le nœud alternatif, invités laissés éteints, interface réseau désactivée, démarrage automatique coupé. Perte du nœud primaire : on allume, on rebranche, quelques minutes de reprise.

Deux précisions d'honnêteté, parce que cette couche est la moins avancée des trois.

**Ce qui est fait :** la fréquence de sauvegarde du service le plus sensible a été resserrée à deux fois par jour, avec exécution réelle déclenchée et vérifiée **en interrogeant le dépôt de sauvegarde, pas le journal de la tâche**. Et une restauration complète a été réalisée pour de vrai, une fois, chronométrée à 44 secondes pour 3,76 Go.

**Ce qui ne l'est pas :** l'automatisation périodique de cette restauration. Elle est spécifiée, elle n'est pas déployée.

L'argument qui la justifie reste entier, et c'est le meilleur de la couche : chaque restauration périodique est aussi un test de sauvegarde. **Une archive n'est prouvée que par une restauration relue, jamais par un statut de vérification.**

## La console : superviser quatre nœuds sans les clusteriser

Le besoin résiduel, avoir une seule vue sur tout le parc, est précisément ce que Proxmox Datacenter Manager résout : chaque nœud reste autonome, la console s'y connecte par jetons d'API en lecture seule. Aucun quorum, rayon d'impact minimal, une compromission de la console donne une vue et non un pouvoir.

Deux pièges de droits à connaître.

Les permissions effectives d'un jeton avec séparation de privilèges sont l'**intersection** de celles du jeton et de celles de son utilisateur porteur. Il faut poser l'autorisation sur les deux, sous peine d'un symptôme trompeur : des réponses 200 avec des listes vides, qui ressemblent à un succès.

Et le droit accordé doit être vérifié dans les deux sens. Chez moi, la preuve fonctionnelle a consisté à lire l'inventaire des nœuds, qui renvoie 200, **puis à tenter une écriture, qui doit renvoyer 403**. Un jeton en lecture seule qui n'a jamais été testé en écriture n'est pas un jeton en lecture seule, c'est une intention.

## Les limites, dites franchement

Cette architecture couvre la panne du reverse proxy ou du conteneur qui le porte. Elle ne couvre pas la panne du nœud qui héberge le résolveur DNS, parce que la couche 1 n'est pas en place : l'adresse virtuelle basculera bien, mais plus personne ne résoudra les noms. Et le résolveur tourne aujourd'hui sur le même nœud physique que le maître de l'adresse virtuelle, ce qui rend cette limite immédiatement concrète.

Une question reste ouverte, et sa réponse détermine la portée réelle du dispositif : **les clients du réseau ont-ils un résolveur secondaire configuré ?** Tant que je ne l'ai pas vérifié, je ne peux pas affirmer que la couche 2 protège d'une panne de nœud. Je peux seulement affirmer qu'elle protège d'une panne de proxy.

Deux autres réserves, plus petites mais réelles. Les deux keepalived du couple ne sont pas à la même version, `2.3.3` d'un côté, `2.2.8` de l'autre, parce que les deux conteneurs tournent sur des distributions différentes. VRRP est interopérable et la bascule le prouve, mais j'énonce plus haut une règle du jumeau que mon implémentation viole : à harmoniser si l'on veut un jumeau strict. Et j'ai découvert au passage que la configuration du résolveur DNS, qui porte l'ensemble des règles de bascule, n'était **sauvegardée nulle part depuis cinq semaines**, le collecteur interrogeant un chemin périmé depuis une renumérotation.

Enfin, le jour où le parc dépassera cinq nœuds avec un vrai besoin de mobilité et un réseau 10 GbE, le cluster redeviendra une conversation légitime. C'est une porte de réouverture explicite, pas un dogme.

## Ce que je retiens

Le cluster répond à une question de mobilité. La disponibilité, elle, se gagne service par service, et se paye en discipline d'exploitation plutôt qu'en matériel : deux conteneurs, keepalived, des empreintes vérifiées, et des portes de contrôle qui vérifient la disparition de l'ancien état et pas seulement la présence du nouveau.

Le basculement du trafic s'est fait sans interruption de service et le retour arrière tenait en une réécriture DNS. Pour un parc de production modeste, points de démonstration durcis et petite production, c'est à mon sens le bon compromis, à condition d'assumer publiquement ce qui n'est pas encore couvert.

Le protocole sous lequel un agent IA a construit ce dispositif sans surveillance, et [ce qu'il a refusé de faire](/blog/agent-ia-operations-infrastructure-protocole/) cette nuit-là, fait l'objet d'un article séparé.

Hémerson Koffi, HK CONSEILS, IA générative souveraine et infrastructures auto-hébergées pour les PME.
