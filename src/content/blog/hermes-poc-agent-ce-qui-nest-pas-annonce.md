---
title: "Hermes : ce qu'un POC de trois heures a montré"
description: "Neuf critères, huit tenus, un partiel. Et surtout trois comportements qu'aucune fiche produit n'annonce : des paquets installés à chaque démarrage, trois réglages là où la documentation en donne un, et une panne visible uniquement sur le canal qu'on n'avait pas testé."
pubDate: 2026-08-24
tags: ["agents", "poc", "sécurité", "mesure"]
---

Un POC d'agent qui se contente de vérifier que l'agent répond ne mesure presque rien. Celui-ci a été construit pour mesurer autre chose : ce que le produit fait quand on ne le lui demande pas. Neuf critères, chacun avec un seuil écrit avant la mesure, et un environnement volontairement contraint. C'est la contrainte qui a rendu visible l'essentiel.

*POC mené dans la nuit du 22 au 23 août 2026, sur un mini-PC dédié, avec un agent conversationnel open source en version 0.20.5 sous licence MIT, adossé à un modèle servi par notre propre infrastructure. Toutes les valeurs citées sont des mesures de cette nuit-là.*

## Le tableau, sans arrondi

Huit critères tenus, un partiel, aucun échec.

Le service redevient actif **17 secondes** après le démarrage de la machine, pour un seuil fixé à 60. La mémoire persiste : deux faits mémorisés, service redémarré, deux faits restitués. Une tâche planifiée à cinq minutes est bien délivrée sur le canal de messagerie. Aucune compétence ne s'est auto-créée. Un sous-agent a été correctement délégué et a rendu son résultat en 29,2 secondes.

La latence mérite un mot, parce qu'elle illustre une règle de méthode. La première mesure a donné **22,6 secondes**. Elle est inexploitable, et nous l'avons écartée en disant pourquoi : la session contenait encore un message resté sans réponse, et l'agent a traité deux demandes dans ce tour, ce que sa réponse prouve. Reprise après redémarrage complet, sur service froid : **14,0 secondes**, à plus ou moins une seconde près puisque le canal horodate à la seconde entière. Le tour suivant, à chaud : **7,4 secondes**.

Le critère était fixé à quinze secondes. Il est donc tenu **avec une seconde de marge sur le cas froid**. Sur un modèle plus lent ou une invite système plus longue, il basculerait. Une mesure qui passe de justesse doit être présentée comme telle, sinon elle sera citée plus tard comme une marge confortable.

Côté charge : **130 Mo au repos** pour moins d'un pour cent d'un cœur, et **139 Mo en génération** pour un pic à 209 % de CPU, soit un peu plus de deux cœurs. L'empreinte mémoire est modeste, la pointe processeur ne l'est pas.

## Ce qu'aucune fiche produit n'annonce

### Des paquets installés à chaque démarrage

C'est le constat principal, et il n'était pas cherché.

Le produit exécute une installation de dépendances **à chaque lancement**, deux paquets tirés depuis le dépôt public du langage. Sur une machine dont la sortie réseau est ouverte, cela signifie qu'un agent télécharge du code en cours d'exploitation, sans que rien ne le signale, à chaque redémarrage du service.

Ici, la sortie réseau était fermée par une liste blanche stricte. Le comportement s'est donc traduit par **une centaine de secondes d'attente de délais d'expiration à chaque lancement** et 192 paquets rejetés. Neutralisé par un réglage dédié, le **démarrage est passé de 102 secondes à 4,9 secondes**.

Le point à retenir dépasse ce produit : **c'est la liste blanche qui a rendu le comportement visible**. Sans elle, l'installation aurait réussi silencieusement, le démarrage aurait été rapide, et personne n'aurait jamais su qu'un agent tirait du code à chaque réveil. Un contrôle restrictif n'a pas seulement une valeur de protection, il a une valeur de révélateur.

### Trois réglages là où la documentation en donne un

Empêcher un agent de fabriquer lui-même de nouvelles compétences semblait tenir en une option, celle qui est documentée et présente dans la configuration livrée.

Il en faut trois. Les deux autres sont deux chemins autonomes de mise à jour de la bibliothèque de compétences ; ils sont **actifs par défaut**, **absents de la configuration livrée**, et l'un d'eux est conçu pour continuer en cas d'erreur plutôt que de s'arrêter. Ne désactiver que l'option documentée aurait donné une **fausse assurance** : l'inventaire aurait pu bouger malgré un réglage explicitement posé pour l'en empêcher.

Détail aggravant : la commande de configuration officielle répond « clé non reconnue » sur l'option documentée, alors que le code la lit correctement. Un avertissement faux est pire qu'un silence, parce qu'il pousse à défaire un réglage juste.

### Une panne visible seulement sur le canal qu'on n'avait pas testé

Un paramètre envoyé par la passerelle de messagerie était refusé par notre proxy de modèles. Résultat : la passerelle tombait, **et l'interface en ligne de commande fonctionnait parfaitement pendant ce temps**.

Un POC validé au terminal seul aurait donc déclaré le produit fonctionnel, et découvert la panne en production, sur le seul canal que les utilisateurs empruntent.

Le correctif retenu a été posé côté agent. L'autre correctif possible, côté proxy de modèles, aurait modifié une **ressource partagée de production** pour arranger un POC. C'est un arbitrage qu'il vaut la peine d'expliciter : la bonne correction n'est pas la plus rapide, c'est celle dont le rayon d'action est le plus petit.

## L'adhérence aux consignes, mesurée plutôt que supposée

L'agent portait un fichier d'identité définissant son rôle, son périmètre et ses interdictions. Sur le fond, la tenue est bonne : confronté à une demande hors périmètre, il a refusé en citant deux interdictions, et a formulé de lui-même la phrase qui résume toute la doctrine, à savoir qu'il n'a pas accès aux fichiers ni au terminal de la machine, et que **c'est un contrôle technique qui bloque l'action, pas une décision de sa part**.

Sur la forme, c'est une autre affaire. Le même fichier interdisait explicitement le gras et les listes à puces sur le canal de messagerie : l'agent a utilisé les deux, dans chacune de ses réponses. Et sur une consigne de préfixe applicable à tous ses messages, la tenue est **de quatre sur quatre sur le canal de messagerie, mais de deux sur cinq en ligne de commande**.

La leçon est directement transposable : **une instruction de forme donnée en langage naturel n'est pas un mécanisme**. Elle est tenue souvent, pas toujours, et pas également selon le canal. Tout ce qui doit être garanti doit sortir du texte et entrer dans le code.

## Le critère partiel, et pourquoi il n'a pas été arrondi

Le seul critère non pleinement tenu concerne la sortie réseau. Il faut y distinguer deux natures de trafic.

Les **actions de l'agent** n'ont produit **aucun paquet** hors de la liste autorisée. Le critère est donc tenu pour l'agent.

Le **runtime du produit**, lui, émet à chaque démarrage seize paquets vers des résolveurs DNS publics, dans une tentative de découverte de points d'entrée de repli. Ce trafic n'est annoncé nulle part. Bloqué, il n'empêche pas la connexion d'aboutir.

Le critère est donc tenu pour l'agent et pas pour le produit. Nous l'avons noté partiel plutôt que vert, parce que la distinction entre « l'agent respecte sa politique » et « rien ne sort de cette machine » est exactement celle qu'un client aura en tête, et qu'il vaut mieux la porter soi-même que se la faire opposer.

## Ce que je retiens

**Un POC doit être mené sur le canal de production.** Le terminal ment par omission : il ne traverse pas la même chaîne, et il aurait ici validé un produit en panne.

**Fermer la sortie réseau est un instrument de mesure.** Le comportement le plus important de cette nuit n'a pas été cherché, il est apparu parce qu'un contrôle strict l'a rendu bruyant.

**Une valeur par défaut vaut une décision.** Trois réglages là où la documentation en annonce un, deux d'entre eux actifs et non listés dans la configuration livrée : ce qui n'est pas explicitement fermé est ouvert, et personne ne vous le dira.

**Une mesure qui passe de justesse se déclare de justesse.** Une seconde de marge sur un seuil est une information, pas un détail de présentation.

Ce POC est mis en regard des deux autres runtimes évalués, sur le même matériel et le même modèle, dans [le comparatif des trois architectures](/blog/agents-ia-on-premise-trois-architectures/).
