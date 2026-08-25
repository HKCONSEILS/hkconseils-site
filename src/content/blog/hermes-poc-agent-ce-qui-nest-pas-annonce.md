---
title: "Hermes : ce qu'un POC de trois heures a montré"
description: "Neuf critères, huit tenus, un partiel. Et surtout trois comportements qu'aucune fiche produit n'annonce : des paquets installés à chaque démarrage, trois réglages là où la documentation en donne un, et une panne visible uniquement sur le canal qu'on n'avait pas testé."
pubDate: 2026-08-24
tags: ["agents", "poc", "sécurité", "mesure"]
---

Un POC d'agent qui se contente de vérifier que l'agent répond ne mesure presque rien. Celui-ci a été construit pour mesurer autre chose : ce que le produit fait quand on ne le lui demande pas. Neuf critères, chacun avec un seuil écrit avant la mesure, et un environnement volontairement contraint. C'est la contrainte qui a rendu visible l'essentiel.

*POC mené sur Hermes, agent conversationnel open source en version 0.20.5 sous licence MIT, dans la nuit du 22 au 23 août 2026, sur un mini-PC dédié, adossé à un modèle servi par notre propre infrastructure. Toutes les valeurs citées sont des mesures de cette nuit-là.*

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

<figure>
<svg viewBox="0 0 820 330" role="img" aria-label="Comparaison de deux environnements. Avec une sortie réseau ouverte, l'installation de deux paquets à chaque lancement réussit en silence : le démarrage est rapide et le comportement reste invisible. Avec une liste blanche stricte, la même installation est bloquée, 192 paquets sont rejetés, environ cent secondes de délais d'expiration s'accumulent et le démarrage passe à 102 secondes, ce qui rend le comportement visible. Après neutralisation du réglage, le démarrage tombe à 4,9 secondes." xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto;font-family:var(--font-sans,sans-serif)">
  <rect x="0" y="0" width="820" height="330" fill="var(--color-surface-sunken,#fafbfc)" rx="10"/>
  <text x="32" y="42" font-size="15" font-weight="700" fill="var(--color-fg,#071b3b)">La liste blanche n'a pas seulement protégé, elle a révélé</text>
  <rect x="32" y="66" width="370" height="196" rx="10" fill="var(--color-surface,#fff)" stroke="var(--color-border,#e5e7eb)"/>
  <text x="52" y="94" font-size="13" font-weight="700" fill="var(--color-fg-muted,#6b7280)">Sortie réseau ouverte</text>
  <text x="52" y="122" font-size="12" fill="var(--color-fg,#071b3b)">Installation de 2 paquets à chaque lancement</text>
  <text x="52" y="144" font-size="12" fill="var(--color-fg,#071b3b)">Elle réussit, sans erreur, sans trace</text>
  <text x="52" y="166" font-size="12" fill="var(--color-fg,#071b3b)">Démarrage rapide</text>
  <rect x="52" y="188" width="330" height="52" rx="8" fill="var(--color-surface-sunken,#fafbfc)" stroke="var(--color-border,#e5e7eb)" stroke-dasharray="4 4"/>
  <text x="217" y="211" font-size="12.5" font-weight="700" text-anchor="middle" fill="var(--color-fg-muted,#6b7280)">Comportement invisible</text>
  <text x="217" y="230" font-size="11" text-anchor="middle" fill="var(--color-fg-muted,#6b7280)">un agent tire du code à chaque réveil, personne ne le sait</text>
  <rect x="418" y="66" width="370" height="196" rx="10" fill="var(--color-surface,#fff)" stroke="var(--color-accent,#005ffa)" stroke-width="1.5"/>
  <text x="438" y="94" font-size="13" font-weight="700" fill="var(--color-accent,#005ffa)">Liste blanche stricte</text>
  <text x="438" y="122" font-size="12" fill="var(--color-fg,#071b3b)">Même installation, bloquée</text>
  <text x="438" y="144" font-size="12" fill="var(--color-fg,#071b3b)"><tspan font-weight="700">192 paquets</tspan> rejetés par lancement</text>
  <text x="438" y="166" font-size="12" fill="var(--color-fg,#071b3b)">une centaine de secondes d'attente</text>
  <rect x="438" y="188" width="330" height="52" rx="8" fill="var(--color-accent,#005ffa)"/>
  <text x="603" y="211" font-size="12.5" font-weight="700" text-anchor="middle" fill="#ffffff">Comportement bruyant, donc trouvé</text>
  <text x="603" y="230" font-size="11" text-anchor="middle" fill="rgba(255,255,255,0.86)">le contrôle sert d'instrument de mesure</text>
  <text x="32" y="292" font-size="12" font-weight="700" fill="var(--color-fg,#071b3b)">Temps de démarrage du service</text>
  <rect x="270" y="278" width="420" height="18" rx="4" fill="var(--color-fg-muted,#6b7280)"/>
  <text x="700" y="292" font-size="12" font-weight="700" fill="var(--color-fg-muted,#6b7280)">102 s</text>
  <rect x="270" y="302" width="20" height="18" rx="4" fill="var(--color-accent,#005ffa)"/>
  <text x="300" y="316" font-size="12" font-weight="700" fill="var(--color-accent,#005ffa)">4,9 s</text>
  <text x="32" y="316" font-size="11.5" fill="var(--color-fg-muted,#6b7280)">après neutralisation du réglage</text>
</svg>
<figcaption>Le même comportement produit, selon l'environnement, un démarrage rapide et silencieux ou une anomalie de 102 secondes impossible à ignorer.</figcaption>
</figure>

### Trois réglages là où la documentation en donne un

Empêcher un agent de fabriquer lui-même de nouvelles compétences semblait tenir en une option, celle qui est documentée et présente dans la configuration livrée.

Il en faut trois. Les deux autres sont deux chemins autonomes de mise à jour de la bibliothèque de compétences ; ils sont **actifs par défaut**, **absents de la configuration livrée**, et l'un d'eux est conçu pour continuer en cas d'erreur plutôt que de s'arrêter. Ne désactiver que l'option documentée aurait donné une **fausse assurance** : l'inventaire aurait pu bouger malgré un réglage explicitement posé pour l'en empêcher.

Les trois, relevés dans la configuration de la machine de POC, qui tourne encore :

```yaml
skills:
  creation_nudge_interval: 0      # le seul que la documentation mentionne
auxiliary:
  background_review:
    enabled: false                # actif par defaut, et concu pour continuer en cas d'erreur
curator:
    enabled: false                # actif par defaut lui aussi
```

Le résultat se vérifie du dehors, sur l'inventaire lui-même :

```console
$ ls -A ~hermes/.hermes/skills/ | wc -l
0
$ ls -ld ~hermes/.hermes/skills/
dr-xr-xr-x 2 root root 4096 .../skills/
```

Zéro entrée, et un répertoire que le compte de service ne peut pas écrire. Le réglage dit ce qui devrait arriver, les droits garantissent ce qui peut arriver.

Détail aggravant : la commande de configuration officielle répond « clé non reconnue » sur l'option documentée, alors que le code la lit correctement. Un avertissement faux est pire qu'un silence, parce qu'il pousse à défaire un réglage juste.

### Une panne visible seulement sur le canal qu'on n'avait pas testé

Un paramètre envoyé par la passerelle de messagerie était refusé par notre proxy de modèles. Résultat : la passerelle tombait, **et l'interface en ligne de commande fonctionnait parfaitement pendant ce temps**.

Un POC validé au terminal seul aurait donc déclaré le produit fonctionnel, et découvert la panne en production, sur le seul canal que les utilisateurs empruntent.

Le correctif retenu a été posé côté agent. L'autre correctif possible, côté proxy de modèles, aurait modifié une **ressource partagée de production** pour arranger un POC. C'est un arbitrage qu'il vaut la peine d'expliciter : la bonne correction n'est pas la plus rapide, c'est celle dont le rayon d'action est le plus petit.

## L'adhérence aux consignes, mesurée plutôt que supposée

L'agent portait un fichier d'identité définissant son rôle, son périmètre et ses interdictions. Sur le fond, la tenue est bonne : confronté à une demande hors périmètre, il a refusé en citant deux interdictions, et a formulé de lui-même la phrase qui résume toute la doctrine, à savoir qu'il n'a pas accès aux fichiers ni au terminal de la machine, et que **c'est un contrôle technique qui bloque l'action, pas une décision de sa part**.

Sur la forme, c'est une autre affaire. Le même fichier interdisait explicitement le gras et les listes à puces sur le canal de messagerie : l'agent a utilisé les deux, dans chacune de ses réponses. Et sur une consigne de préfixe applicable à tous ses messages, la tenue est **de quatre sur quatre sur le canal de messagerie, mais de deux sur cinq en ligne de commande**.

La leçon est directement transposable : **une instruction de forme donnée en langage naturel n'est pas un mécanisme**. Elle est tenue souvent, pas toujours, et pas également selon le canal. Tout ce qui doit être garanti doit sortir du texte et entrer dans le code.

> **Une consigne n'est pas un contrôle.** Une instruction écrite dans une invite est une suggestion adressée à un système probabiliste : elle sera suivie souvent, jamais toujours, et pas également selon le canal. Ce qui doit être garanti se déplace du texte vers le code, ou n'est pas garanti.

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
