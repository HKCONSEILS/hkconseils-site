---
title: "DevSecOps : sécuriser une chaîne IaC en pratique"
description: "Une stack automatisée qui tourne, c'est bien. Une stack dont chaque déploiement est vérifié avant d'atteindre la production, c'est le minimum. Ce que cela veut dire concrètement sur l'infrastructure, les images et les secrets."
pubDate: 2027-02-15
originalDate: 2025-08-01
originalDatePrecision: mois
tags: ["devsecops", "iac", "sécurité"]
draft: true
---

Avoir une stack automatisée qui tourne est satisfaisant. La rendre vérifiable l'est davantage. C'est là que le DevSecOps prend son sens : le but n'est pas seulement de déployer, mais de déployer de façon fiable, répétable et sûre.

Voici comment la méthode est incorporée au projet, sur trois plans.

## L'infrastructure décrite en code

L'infrastructure est définie avec Terraform. Avant toute modification, la chaîne d'intégration continue déclenche automatiquement une analyse statique du code, qui cherche les configurations dangereuses : ports ouverts, listes de contrôle d'accès trop permissives, réglages par défaut oubliés.

La vérification a lieu **avant** le déploiement, pas après l'incident.

## Les images de conteneurs

Toutes les applications tournent dans des images que je construis moi-même. Chaque image récente est examinée automatiquement à la recherche de vulnérabilités connues dans les bibliothèques et les dépendances.

Construire ses propres images ne suffit pas : une image maison peut embarquer une dépendance vulnérable aussi facilement qu'une image tierce. La différence est qu'on peut la corriger.

## Les secrets

Aucun secret n'est écrit en dur dans le code. La chaîne d'intégration s'appuie sur des secrets chiffrés, et l'objectif à terme est de centraliser leur gestion dans un gestionnaire dédié, pour un contrôle dynamique en production.

> **Le point faible du dispositif reste l'humain.** Un secret peut être commité par inadvertance, et une analyse qui ne tourne qu'à l'intégration ne le rattrapera pas toujours. Une vérification côté poste de travail, avant même le commit, est le complément qui manque le plus souvent.

## Ce que cela vaut

L'idée n'est pas d'empiler des outils, mais d'incorporer la vérification au plus tôt et de l'automatiser, pour qu'elle devienne une protection plutôt qu'un obstacle. Une sécurité qui ralentit finit contournée ; une sécurité qui s'exécute toute seule finit respectée.
