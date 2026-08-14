---
title: "FinOps appliqué au matériel d'un homelab IA"
description: "La bonne question n'est pas quel serveur est le plus puissant, mais lequel est le plus équilibré. Le raisonnement composant par composant, et l'arbitrage entre acheter et louer, chiffré."
pubDate: 2026-10-15
originalDate: 2025-06-01
originalDatePrecision: mois
tags: ["finops", "matériel", "gpu"]
draft: true
---

Quand on construit un serveur pour des charges d'intelligence artificielle, la performance compte. Mais la vraie question est ailleurs : **quel assemblage est le plus équilibré ?**

C'est une approche FinOps appliquée au matériel. Trouver le bon rapport entre qualité technique et coût, en choisissant chaque élément selon ce qu'il apporte réellement au système, pas selon sa fiche technique.

## Le processeur : éliminer le goulot d'étranglement

Le choix s'est porté sur un AMD Epyc 7742, 64 cœurs et 128 threads. Mais l'argument décisif n'était pas le nombre de cœurs : ce sont les **128 lignes PCIe Gen4**. Chaque GPU et chaque disque NVMe dispose ainsi de sa propre voie vers le processeur, sans partage ni arbitrage.

Sur une machine à quatre GPU, c'est la différence entre quatre cartes qui travaillent et quatre cartes qui s'attendent.

## La carte mère : la stabilité avant les fonctionnalités

Une Gigabyte MZ32-AR0 Rev3, au format EATX et de grade serveur. Le bénéfice attendu est la stabilité en fonctionnement continu, pour des entraînements qui peuvent durer plusieurs jours, ainsi que la gestion à distance.

## Les GPU : deux gammes, deux rôles

- **Deux RTX 4090**, avec 1321 AI TOPS, réservées aux entraînements les plus lourds et à l'inférence sur les modèles les plus complexes.
- **Deux RTX 3090**, achetées à un bien meilleur prix. Leur rapport entre VRAM et coût reste excellent, ce qui les rend parfaites pour des tâches en parallèle ou du fine-tuning, sans mobiliser les grosses cartes.

Ce n'est pas un compromis, c'est une répartition. Toutes les charges n'ont pas besoin de la carte la plus rapide.

## Le stockage et la mémoire

Deux NVMe de 2 To en Gen3, mesurés à 3,2 Go/s en lecture et 3,15 Go/s en écriture, pour que le pipeline de données ne devienne pas le facteur limitant.

512 Go de DDR4 ECC, qui servent moins à l'inférence qu'à l'orchestration : gérer plusieurs modèles en parallèle, disposer d'une zone de transit pour les données, et absorber le pré-traitement.

## L'arbitrage : acheter ou louer

Louer une capacité GPU équivalente chez un hyperscaler tourne autour de **8 000 euros par mois**. Sur un usage de long terme, et avec les compétences techniques pour opérer la machine soi-même, l'investissement initial s'est révélé plus judicieux après analyse du coût total de possession.

Cette conclusion n'est pas universelle. Elle dépend de deux variables : la durée d'usage et l'expertise disponible. Sans l'une ou sans l'autre, la location redevient le bon choix. Le raisonnement compte davantage que le résultat.
