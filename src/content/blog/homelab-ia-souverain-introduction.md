---
title: "Un homelab IA souverain : le projet et la série"
description: "Pourquoi construire soi-même une plateforme d'inférence plutôt que louer du GPU, et ce que les six épisodes de cette série vont détailler : matériel, virtualisation, passthrough, modèles, automatisation et sécurité."
pubDate: 2026-09-15
originalDate: 2025-06-01
originalDatePrecision: mois
tags: ["homelab", "souveraineté", "série"]
draft: true
---

Le montage est terminé. Un serveur personnel dédié à l'intelligence artificielle, conçu pour expérimenter, entraîner des modèles et déployer des démonstrateurs sur du matériel que je contrôle entièrement.

L'objectif n'était pas d'avoir une machine puissante. Il était de disposer d'une plateforme sur laquelle une recommandation faite à un client puisse d'abord être mesurée : combien de VRAM ce modèle consomme réellement, quel débit tient ce GPU, ce que coûte une requête. Des réponses qu'on ne peut pas donner honnêtement sans les avoir vérifiées.

## Ce que cette série va couvrir

Six épisodes, chacun sur une décision et ce qu'elle a coûté.

- **L'architecture matérielle.** Le raisonnement derrière chaque composant : pourquoi ce processeur, pourquoi ce mélange de cartes graphiques, et comment l'arbitrage entre performance et coût a été tranché.
- **Du matériel à l'hyperviseur.** L'assemblage, puis le choix de la couche de virtualisation, motivé par l'automatisation avant l'interface.
- **Le passthrough GPU.** Conteneur ou machine virtuelle, les deux philosophies, et pourquoi l'une l'a emporté ici.
- **La stack de modèles.** Le choix d'un écosystème européen, et comment chaque modèle est assigné à un GPU et à une tâche.
- **L'automatisation et la sécurité.** L'infrastructure décrite en code, validée avant déploiement.

## Le point de départ

L'ensemble tourne sur une plateforme de virtualisation, avec les services isolés les uns des autres : moteurs d'inférence, interface de conversation web, métamoteur de recherche auto-hébergé, outils d'automatisation d'agents. Chaque brique dans son propre conteneur, avec ou sans GPU dédié.

Le fil conducteur de la série est simple : rien n'est affirmé sans avoir été mesuré, et chaque choix est expliqué par ce qu'il apporte plutôt que par ce qu'il permet d'afficher.
