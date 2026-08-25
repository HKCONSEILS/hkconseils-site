---
title: "OpenClaw : ce que deux phases sur sept ont appris"
description: "Une plateforme multi-agents auto-hébergée, planifiée en sept phases, dont deux sont livrées. Ce qui tourne vraiment en continu, comment les garde-fous sont devenus vérifiables, et l'affirmation que nous avons dû retirer parce qu'elle n'était pas prouvable."
pubDate: 2026-08-24
tags: ["agents", "architecture", "on-premise", "observabilité"]
---

Il y a deux façons de parler d'une plateforme d'agents en cours de construction. La première consiste à décrire la cible et à laisser croire qu'elle est atteinte. La seconde consiste à dire ce qui tourne, ce qui ne tourne pas encore, et ce qui a été appris entre les deux. Cet article prend la seconde, parce que c'est la seule qui serve à quelqu'un qui envisage la même chose.

*État arrêté au 22 août 2026, à partir du plan directeur du projet et des rapports d'exécution de la même semaine. Les chiffres cités sont ceux relevés à cette date.*

## Où en est réellement le projet

OpenClaw est notre plateforme multi-agents auto-hébergée. Son plan directeur découpe la construction en sept phases : fondations et infrastructure, mémoire et observabilité, orchestration et sécurité, monétisation, intelligence et optimisation, passage à l'échelle, et enfin un agent opérateur supervisé, explicitement classé en recherche interne tant que la phase précédente n'est pas validée.

**Deux de ces sept phases sont livrées** : les fondations, et la mémoire et observabilité. Les itérations se poursuivent sur les suivantes, par passes datées. Ce n'est pas un produit fini, et le dire n'est pas de la modestie : c'est la condition pour que les chiffres qui suivent aient une valeur.

Ce découpage a lui-même une leçon. Placer la monétisation en phase quatre, après l'orchestration et la sécurité, est un choix qui coûte cher en trésorerie et qui se défend mal en réunion. Il se défend très bien la première fois qu'un agent fait une chose qu'on ne lui avait pas demandée.

## Ce qui tourne en continu, et comment on le sait

La partie la plus instructive n'est pas la plus spectaculaire. C'est l'agent de veille technologique, un service modeste qui tourne sans interruption.

Son fonctionnement tient en peu de lignes. Des minuteurs système déclenchent **quatre collectes par jour**, à minuit, six heures, midi et dix-huit heures. Une **synthèse est poussée trois fois par semaine**, les lundi, mercredi et vendredi au matin. Il surveille onze dépôts de code alignés sur le plan directeur, plus les registres de paquets correspondants, et classe ce qu'il trouve par criticité.

Deux détails de conception méritent d'être copiés.

Le premier : le jeton d'accès est **en lecture seule et à portée restreinte**. Un agent de veille n'a aucune raison de pouvoir écrire, et lui en donner la possibilité par commodité est le genre de raccourci qu'on paie une seule fois, très cher.

Le second, plus subtil : l'agent **surveille son propre jeton**. À chaque collecte, il vérifie que le jeton est toujours valide et reconnu, et alerte s'il ne l'est pas. Sans ce contrôle, un jeton expiré produit exactement ce qu'un service en bonne santé produit : rien du tout. Le tableau de bord reste vert, les collectes tournent, et la veille est morte depuis trois semaines. C'est une variante d'un piège que nous avons rencontré ailleurs, sous une autre forme, et qui revient toujours à la même question : ce contrôle vaut-il par ce qu'il exerce, ou par ce qu'il affiche.

## Les garde-fous, et l'affirmation qu'il a fallu retirer

Le second bloc mature de la plateforme est un pipeline de décision financière en papier, construit sur une bibliothèque d'orchestration déterministe. Sa structure est classique et elle est le bon exemple : des analystes travaillent en parallèle sur des angles distincts, fondamental, sentiment, actualité, technique ; leurs sorties alimentent un débat contradictoire entre deux positions opposées ; un agent décideur tranche ; puis trois perspectives de risque, agressive, neutre et conservatrice, examinent la décision avant un arbitrage final de portefeuille.

Au-dessus de cette chaîne, un composant que nous appelons l'enforcer. Il tient en deux cent vingt et une lignes et il fait une seule chose : refuser les décisions qui violent des règles. Interdiction de la vente à découvert, stop-loss et take-profit obligatoires, plafond de perte, taille de position maximale, trésorerie résiduelle minimale, seuil de confiance minimal, avec des valeurs durcies sur les instruments les plus volatils.

Sa propriété centrale tient dans un commentaire de son propre code : **les règles sont des constantes, le modèle ne peut pas les modifier par une invite**. C'est la différence entre un garde-fou et une consigne. Une consigne écrite dans un prompt est une suggestion adressée à un système probabiliste. Une constante dans le code est une contrainte. Dix-neuf tests fonctionnels le vérifient à chaque exécution.

Et voici la partie qui compte vraiment.

Notre argumentaire portait la formule « zéro violation depuis avril ». Elle était **invérifiable**, et nous l'avons retirée. L'enforcer validait bien chaque décision, mais **ne conservait aucune trace de ses verdicts**. Une absence de trace n'est pas une preuve d'absence de violation. C'est une phrase inconfortable à écrire dans un dossier, et c'est la seule honnête.

Ce qui restait démontrable, en revanche, l'était sur pièces : un journal applicatif couvrant le 9 avril au 22 août, plus de cinquante-sept mille lignes, contenant un refus d'exécution explicite et daté ; et un coupe-circuit tenant trois stratégies en pause, avec pour chacune son horodatage de reprise. L'enforcement fonctionnait. Il ne se documentait pas.

## Rendre la preuve possible, sans toucher à la règle

La correction a été instrumentée le 22 août 2026. L'enforcer écrit désormais **une ligne par décision** dans un journal structuré : horodatage, instrument, action proposée par le modèle, verdict, règles violées nommément, et un contexte chiffré tronqué.

Trois propriétés ont été vérifiées par des tests dédiés, et c'est la troisième qui est la plus importante :

1. un verdict d'autorisation produit une ligne conforme ;
2. un verdict de blocage **nomme** la règle violée, plutôt que de signaler un refus générique ;
3. **une panne d'écriture du journal ne modifie ni le verdict ni les violations.**

Le troisième point est la règle de conception à retenir de tout ce chantier. La traçabilité ne doit jamais pouvoir dégrader ce qu'elle trace. Un journal qui, en tombant, ferait passer une décision interdite serait pire que pas de journal du tout : il transformerait un incident de stockage en incident métier.

L'instrumentation est purement additive. Aucune règle métier n'a été touchée, et les dix-neuf tests préexistants passent inchangés.

Deux limites sont énoncées avec le dispositif, parce qu'elles font partie du résultat. Le journal démarre le 22 août 2026 : il ne dit **rien** de la période d'avril à août, pour laquelle seuls valent le journal applicatif et l'état du coupe-circuit. Et les lignes produites pendant la validation technique ont été écartées dans un fichier séparé, pour ne jamais être comptées comme des décisions réelles.

## Un cas pratique, sur un autre agent

La question qui vient naturellement est : jusqu'où peut-on laisser un agent agir seul. Nous l'avons éprouvée sur un terrain différent, celui de l'infrastructure, avec un agent qui a construit et prouvé un dispositif de haute disponibilité pendant une nuit entière, puis s'est arrêté net avant la bascule parce que le protocole le lui imposait. Le récit détaillé, y compris la faute qu'il a commise cette nuit-là, est dans [un article dédié](/blog/agent-ia-operations-infrastructure-protocole/).

Les deux chantiers convergent sur le même principe. Ce qui rend un agent utilisable n'est pas la qualité de ses instructions, c'est l'existence, en dehors de lui, de contraintes qu'il ne peut pas contourner et de traces qu'il ne peut pas effacer.

## Ce que je retiens

Trois choses, dans l'ordre où elles se sont imposées.

**L'ordre des phases est un choix de risque, pas un choix de planning.** Traiter l'orchestration et la sécurité avant la monétisation retarde le revenu et rend le reste défendable.

**Un contrôle sans journal n'est pas un contrôle prouvable.** Il fonctionne peut-être parfaitement, mais on ne peut rien en dire, et dans un dossier ou face à un client, ne rien pouvoir en dire équivaut à ne rien avoir.

**Le vrai risque des agents autonomes n'est pas qu'ils se trompent, c'est qu'ils se trompent en silence.** Le jeton de veille expiré et l'enforcer sans journal sont le même défaut sous deux formes : un système qui a l'air d'aller bien parce que rien ne remonte.

Cette plateforme est mise en regard de deux autres runtimes d'agents, évalués sur le même matériel, dans [le comparatif des trois architectures](/blog/agents-ia-on-premise-trois-architectures/).
