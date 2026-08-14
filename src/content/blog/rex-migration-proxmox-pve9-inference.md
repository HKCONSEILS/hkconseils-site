---
title: "Proxmox 9 : 35 % de débit perdu, aucune régression"
description: "Après une montée de Proxmox 8.4 vers 9.2.3, mes serveurs d'inférence tombent de 37 à 24 tokens par seconde. Tout accusait le nouveau driver NVIDIA. Le diagnostic a dit autre chose, et la leçon vaut pour toute migration : mesurer avant d'accuser."
pubDate: 2026-08-15
originalDate: 2026-06-30
tags: ["rex", "proxmox", "gpu", "llm"]
---

J'ai migré mon lab de Proxmox VE 8.4 vers 9.2.3. Après la migration, mes serveurs d'inférence tournaient jusqu'à 35 % moins vite.

Tout accusait le nouveau driver NVIDIA. Le diagnostic disait autre chose.

## Le contexte, et la contrainte qui change tout

Il s'agit d'un hyperviseur de production qui sert plusieurs agents LLM en local. Le chantier était lourd, et tout devait passer dans une seule fenêtre :

- Proxmox VE 8.4 vers 9.2, donc Debian 12 vers 13 ;
- kernel 6.8 vers 7.0 ;
- driver NVIDIA 570 vers 595, les anciens ne compilant plus sur le 7.0 ;
- 4 GPU, deux RTX 4090 et deux RTX 3090, en passthrough vers des conteneurs LXC.

Et la vraie contrainte : **aucun accès hors bande**. Pas d'IPMI. Un reboot raté signifie un déplacement physique devant la machine.

> **Le piège de la migration sans IPMI.** Le pire scénario n'est pas que la migration échoue, c'est de redémarrer sur le kernel 7.0 et de découvrir à ce moment-là que le driver ne charge pas. La décision qui change tout : valider que le driver compile pour le nouveau kernel **avant** de redémarrer, avec DKMS, pendant qu'on tourne encore sur l'ancien. Un pari aveugle devient une opération contrôlée.

## La chute de débit, et le réflexe qu'il fallait refuser

La migration passe. Puis un serveur d'inférence tombe d'environ 37 à 24 tokens par seconde.

Le réflexe facile était tout trouvé : « c'est le nouveau driver », ou « c'est le nouveau kernel ». J'ai refusé d'y croire sans preuve, parce qu'une accusation sans mesure ne se corrige pas, elle se contourne.

La méthode a consisté à mesurer, à échantillonner les raisons de bridage en temps réel, puis à éliminer les hypothèses une à une :

- le lien PCIe sous charge : conforme, en Gen4 ;
- la température : 63 °C, loin de tout seuil ;
- le mode persistance du driver : actif ;
- l'espace utilisateur CUDA : cohérent avec le noyau.

Le coupable était **un plafond de puissance à 220 W, déjà présent sous l'ancien driver**. Autrement dit : pas une régression de la migration. Le bridage existait avant, il était simplement passé inaperçu.

## La preuve, par un test réversible

Un diagnostic ne vaut que s'il se démontre. Test A/B, réversible en une commande :

```bash
# Relever le plafond, mesurer, revenir en arrière si besoin
nvidia-smi -i "$GPU" -pl 300
# 220 W -> 24 tok/s     300 W -> 44 tok/s
nvidia-smi -i "$GPU" -pl 220
```

Puis un balayage propre du rapport performance sur watt, sur une RTX 3090 :

| Plafond | Débit | Puissance sous charge | Fréquence cœur |
|---|---|---|---|
| 220 W | 24,5 tok/s | 214 W | 692 MHz |
| 250 W | 31,5 tok/s | 240 W | 848 MHz |
| 265 W | 35,3 tok/s | | |
| 280 W | 38,8 tok/s | 245 W | 1188 MHz |

Le gain marginal reste plat sur toute la plage, entre 0,23 et 0,25 token par seconde et par watt, avec un rendement croissant et aucun point de décroissance. À 280 W en flux unique, le GPU ne sature même plus son plafond. Cible retenue : **280 W, soit 58 % de débit gagné**.

Et une surprise qui vaut la vérification : **les RTX 4090 n'étaient pas limitées par la puissance**. Relever leur plafond n'a rien apporté. Même famille de matériel, même hyperviseur, comportement inverse.

## Ce que j'en retiens

**Une baisse de performance après migration n'est pas une régression tant qu'on ne l'a pas prouvée.** Mesurer, ne pas accuser. Le coût d'un diagnostic paresseux, ici, aurait été de revenir en arrière sur une migration parfaitement saine.

**Sans accès hors bande, la validation du driver précède le reboot.** C'est la seule étape qui transforme un pari en opération réversible.

**Sur plusieurs alimentations, le risque se raisonne par rail, jamais sur le total.** Connaître la répartition physique des GPU est indispensable avant de relever quoi que ce soit. Sur le nœud de référence, la charge concurrente des trois serveurs avec les 3090 à 280 W a produit un pic de 952 W sur quatre GPU.

**Avant de relever un plafond de puissance, vérifier que le GPU est réellement limité par la puissance.** Les 4090 l'ont rappelé sans ménagement.

## Le runbook complet

J'ai écrit le guide complet de cette migration : reproductible, commande par commande, avec matrice de décision, retour arrière par phase, et les pièges rencontrés. Trois méritent d'être cités ici :

- le kernel 7.0 introduit `nova` et `nova_core`, un pilote GPU open source en Rust qui prend la main au démarrage et entre en conflit avec NVRM. À blacklister ;
- si Secure Boot est actif, la clé MOK de DKMS doit être enrôlée, sans quoi les modules ne se chargent pas au démarrage, et on le découvre après le reboot ;
- le passthrough exige le jeu complet de device nodes, pas seulement ceux qui semblent utiles.

Il est public : [khemerson/proxmox-pve8to9-gpu-nvidia-runbook](https://github.com/khemerson/proxmox-pve8to9-gpu-nvidia-runbook).
