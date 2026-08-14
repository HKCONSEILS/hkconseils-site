---
title: "Du matériel à l'hyperviseur : pourquoi Proxmox"
description: "Une fois l'assemblage terminé, il faut choisir la couche qui coordonne cette puissance. Le choix s'est fait sur l'API et l'automatisation, bien avant l'interface graphique."
pubDate: 2026-11-16
originalDate: 2025-07-01
originalDatePrecision: mois
tags: ["proxmox", "virtualisation", "iac"]
draft: true
---

L'assemblage est l'étape satisfaisante. La suivante l'est moins : choisir la couche logicielle qui va coordonner tout ce matériel.

Mon choix s'est porté sur Proxmox VE, pour quatre raisons qui dépassent la simple virtualisation.

## Une API pensée pour l'infrastructure as code

C'est la raison principale, et elle précède toute considération d'interface. La pierre angulaire du projet est d'automatiser la gestion de l'infrastructure avec des outils comme Terraform et Ansible. Une API complète en est le prérequis. J'ai choisi l'hyperviseur pour son API, pas pour son tableau de bord.

## Un passthrough GPU de niveau entreprise

L'assignation directe d'une ou plusieurs cartes graphiques physiques à une machine virtuelle ou à un conteneur est une caractéristique fondamentale ici. Elle permet d'allouer l'intégralité de la puissance des cartes aux modèles, sans couche d'émulation et sans compromis.

## La légèreté des conteneurs

Un conteneur LXC a une empreinte mémoire et processeur sans commune mesure avec une machine virtuelle complète. Sur une machine dédiée à l'inférence, chaque gigaoctet consacré à la virtualisation est un gigaoctet perdu pour l'applicatif.

Le plan est donc de segmenter le serveur pour isoler chaque service dans son propre conteneur, avec ou sans GPU dédié.

## Une trajectoire vers la haute disponibilité

Le clustering est intégré nativement. L'ajout de mes autres serveurs permettra à terme de constituer un cluster à trois nœuds et d'activer la haute disponibilité pour les services critiques. La plateforme est conçue pour grandir, pas seulement pour fonctionner.

## Le premier démarrage

Toujours un moment de vérité. Après une configuration réseau à reprendre, grand classique, la plateforme est installée et stable.

Prochaine étape : le passthrough GPU en détail, avec la méthode et les écueils.
