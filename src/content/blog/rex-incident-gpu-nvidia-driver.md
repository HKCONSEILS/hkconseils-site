---
title: "Quatre GPU morts à 1 h du matin, et le mauvais coupable"
description: "Un bug NVIDIA non corrigé nous pendait au nez. La panne est arrivée, et ce n'était pas lui. Le capteur posé quelques jours plus tôt a permis de trancher en minutes au lieu d'une nuit, et c'est la seule raison pour laquelle l'incident a duré onze minutes."
pubDate: 2026-08-16
originalDate: 2026-07-01
originalDatePrecision: mois
tags: ["rex", "gpu", "sre", "observabilité"]
---

1 h du matin. `nvidia-smi has failed because it couldn't communicate with the NVIDIA driver`.

Quatre GPU de production, deux RTX 4090 et deux RTX 3090, morts.

Le pire, c'est qu'on l'attendait. Mais pas celui-là.

## Le risque qu'on surveillait

Quelques jours plus tôt, l'agent chargé de notre veille technique nous alertait sur l'issue #1134 de `nvidia/open-gpu-kernel-modules` : des Xid 31 puis 154, « Node Reboot Required », sur RTX 3090, driver open 595.71.05, kernel 7.0.x. Exactement notre pile.

On s'est rassurés un peu vite : « on fait du calcul CUDA sans affichage dans des conteneurs, donc faible exposition, ça devrait passer. »

Le diagnostic a dit l'inverse. `nvidia_drm` était chargé avec `modeset=1`, valeur par défaut du driver, sans qu'aucune ligne de `modprobe.d` ne le demande. Le vecteur du bug, le chemin DRM `__nv_drm_gem_nvkms_map`, était grand ouvert. Notre raisonnement était faux.

## La décision contre-intuitive : ne pas corriger tout de suite

On a d'abord posé un capteur, avant tout correctif. Un timer systemd toutes les 60 secondes, qui lit le journal noyau avec un curseur persistant et cherche trois motifs :

```bash
journalctl --cursor-file=/var/lib/gpu-watch/cursor -k --no-pager \
  | grep -E 'Xid|GSP-CrashCat|heartbeat timed out'
```

Les alertes remontent vers notre supervision, puis en notification poussée sur nos téléphones.

Bénéfice immédiat, avant même la panne : le capteur a exhumé **deux crashs GSP déjà présents dans les journaux**, des Xid 119 que personne n'avait vus passer.

> **Détecter avant de corriger.** Sans capteur, comment saurait-on que le correctif a fonctionné ? Un correctif posé sur une infrastructure qu'on ne mesure pas est une croyance, pas une opération.

## L'incident, et le retournement

Puis vient la panne de 1 h du matin. Et le retournement : **ce n'était pas #1134**.

Un upgrade du kernel, de 7.0.12 vers 7.0.14, était passé sans les headers correspondants. DKMS n'a donc pas reconstruit le module. Pas de module, pas de GPU.

Le capteur a permis de trancher en quelques minutes : **zéro Xid au journal**, donc pas le bug exotique. Sans lui, la nuit se passait à chercher un bug non corrigé chez NVIDIA, sur la foi d'une coïncidence.

Le correctif tenait en trois commandes, headers, reconstruction DKMS, chargement du module. **Onze minutes d'indisponibilité.** La récurrence a été éliminée en installant le paquet de headers par défaut, qui suit désormais chaque mise à jour du kernel.

Le correctif de fond a suivi, celui qui visait le vrai risque :

```bash
# Fermer le vecteur DRM du bug #1134
echo 'options nvidia_drm modeset=0 fbdev=0' > /etc/modprobe.d/nvidia-drm.conf
update-initramfs -u
# Après reboot, vérifier que la valeur a bien été prise
cat /sys/module/nvidia_drm/parameters/modeset   # attendu : N
```

Vecteur fermé, et vérifié au démarrage plutôt que supposé.

## Trois leçons

1. **Pendant qu'on regarde le risque exotique, c'est le risque banal qui frappe.** Un kernel mis à jour sans ses headers n'a rien d'une subtilité.
2. **Le capteur d'abord, le correctif ensuite.** L'inverse revient à corriger à l'aveugle, et à ne jamais savoir si ça a marché.
3. **Vérifier ses hypothèses coûte une heure. Ne pas les vérifier coûte une nuit.**

## Où en est le bug

Vérification faite sur le dépôt : aucun correctif annoncé par NVIDIA, aucune assignation, aucune réponse des mainteneurs. Le bug, un Xid 31 puis 154 par dépassement de BAR1 sur le chemin DRM, avec RTX 3090 et driver 595.71.05, reste non résolu, y compris a priori en 595.84 et en 610.x, où rien dans les journaux de version ne le mentionne.

Si quelqu'un a une solution plus propre, je suis preneur. En attendant, je mesure la stabilité de la mienne.
