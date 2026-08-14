---
title: "Une stack d'inférence bâtie sur Mistral"
description: "Choisir un écosystème européen de modèles ouverts n'est pas qu'une posture : c'est aussi une décision d'architecture. Comment chaque modèle est assigné à un GPU et à une tâche, et pourquoi tout est décrit de façon déclarative."
pubDate: 2027-01-15
originalDate: 2025-07-01
originalDatePrecision: mois
tags: ["llm", "souveraineté", "mistral"]
draft: true
---

Les fondations posées, venons-en au cœur du réacteur : les modèles. Pour ce projet, j'ai fait reposer l'ensemble de la stack sur l'écosystème français Mistral AI.

Trois convictions motivent ce choix, au-delà de la performance brute.

**La souveraineté technologique.** Construire sur un écosystème européen de pointe est un enjeu stratégique, et un pari sur notre capacité collective à proposer des alternatives crédibles.

**L'ouverture des poids.** Des modèles open-weights donnent la transparence, la flexibilité et le contrôle complet sur la technologie utilisée. C'est ce qui rend l'auto-hébergement possible.

**La cohérence technique.** Des modèles conçus pour fonctionner ensemble produisent un environnement plus prévisible qu'un assemblage hétéroclite.

## Comment cela se traduit concrètement

J'ai architecturé une ferme d'inférence multi-GPU spécialisée, où chaque modèle est assigné à un travailleur et à une tâche précise. Les modèles sont exécutés localement, les requêtes réparties par une passerelle LLM unifiée, et l'ensemble déployé par la chaîne d'automatisation.

| Rôle | Modèle | Format | Contexte |
|---|---|---|---|
| Généraliste rapide | Mistral-Small-3.2, 24B | Q4_K_M | 12k tokens |
| Vision, multimodal | Pixtral, 12B | Q6_K | 6k tokens |
| Raisonnement explicite | Magistral-Small-2506, 24B | Q4_K_M | 6k tokens |

Le généraliste couvre la majorité des tâches standards. Le modèle de vision analyse le contenu des images soumises. Le troisième produit un raisonnement transparent, utile quand la réponse doit être auditable et pas seulement juste.

Chaque déploiement est ajusté par variables d'environnement, notamment Flash Attention et le cache clé-valeur, pour maximiser à la fois le débit et la taille de contexte tenable sur chaque carte.

## Le point qui compte vraiment

Toute cette architecture est décrite de manière **déclarative**, dans des fichiers de configuration. Changer un modèle ou ajuster un paramètre revient à modifier une ligne, et la chaîne d'automatisation se charge du reste.

C'est ce qui distingue une plateforme d'un bricolage : non pas qu'elle fonctionne, mais qu'on puisse la reconstruire à l'identique sans se souvenir de ce qu'on a fait.
