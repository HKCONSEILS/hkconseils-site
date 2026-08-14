---
title: "Passthrough GPU : conteneur ou machine virtuelle"
description: "Deux philosophies s'opposent pour donner un GPU à une charge virtualisée : l'isolation matérielle de la machine virtuelle, ou l'agilité du conteneur. Le choix conditionne la performance et la souplesse de toute la plateforme."
pubDate: 2026-12-15
originalDate: 2025-07-01
originalDatePrecision: mois
tags: ["gpu", "lxc", "proxmox"]
draft: true
---

Exploiter la puissance d'un GPU en environnement virtualisé passe par le passthrough : connecter une carte physique à une charge virtualisée sans couche d'émulation.

Deux approches s'offraient à moi, et la direction prise allait conditionner la performance, la flexibilité et la capacité à grandir de toute la plateforme.

## Les deux philosophies

**Le passthrough vers une machine virtuelle**, par IOMMU et VFIO. Le GPU est complètement isolé de l'hôte et dédié à une seule machine virtuelle. C'est une isolation matérielle, robuste et sûre, mais lourde, puisqu'il faut virtualiser un système complet, et rigide : une carte, une machine.

**Le passthrough vers un conteneur**, par cgroups et device mapping. Le pilote reste sur l'hôte, et les cgroups donnent au conteneur un accès direct aux fichiers de périphérique du GPU. C'est très léger, souple, et les performances sont quasi natives.

## Le choix : la flexibilité

L'objectif du projet est de déployer une multitude de services d'inférence conteneurisés. Trois critères ont tranché :

- **la légèreté**, pour multiplier les travailleurs sans consommer les ressources en virtualisation ;
- **la rapidité**, pour créer et détruire ces travailleurs en quelques secondes avec Terraform et Ansible ;
- **la performance**, en minimisant la surcouche entre le modèle et le matériel.

Le conteneur s'imposait.

> **Ce que le conteneur coûte en isolation.** Le pilote reste sur l'hôte et est partagé : une défaillance à ce niveau touche tous les conteneurs qui en dépendent, là où la machine virtuelle aurait cloisonné. C'est un arbitrage assumé, pas un repas gratuit. Sur une plateforme mono-tenant, il se défend ; sur une plateforme multi-clients, la réponse serait probablement différente.

## Le résultat mesuré

Après automatisation du déploiement de bout en bout, le premier travailleur sur une RTX 4090 atteint **environ 150 tokens par seconde**, soit à peu près 110 mots par seconde, en inférence sur un modèle de 24 milliards de paramètres.

Pour donner l'échelle : la lecture silencieuse d'un humain tourne autour de 3 à 4 mots par seconde.

Le choix architectural tenait ses promesses de performance et d'agilité.
