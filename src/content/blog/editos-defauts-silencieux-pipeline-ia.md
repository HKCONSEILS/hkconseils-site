---
title: "Editos : trois défauts qu'un pipeline IA tait"
description: "Un correcteur éditorial qui parle de lui-même dans le livrable, un GPU qui disparaît sans erreur, un total juste mais trompeur. Trois défauts silencieux d'un pipeline de correction par LLM, comment ils ont été trouvés, et la prédiction falsifiable qui a validé le correctif."
pubDate: 2026-08-26
tags: ["llm", "qualité", "observabilité", "python"]
---

Editos est un assistant éditorial que j'ai conçu et que j'exploite : un manuscrit entre, un manuscrit corrigé sort, et rien ne quitte l'infrastructure. Le pipeline enchaîne une extraction structurée, une passe orthographique déterministe, trois passes d'un modèle de langage, un calcul de différences, un écran de revue humaine, puis les exports.

*Travaux conduits en juin 2026, versions 2.7.1 et 2.8.0. L'un des trois défauts décrits remonte au 6 mars 2026 et n'a été mesuré qu'à cette occasion.*

Ce qui suit ne parle pas de la qualité des corrections. Il parle de trois défauts qui avaient tous la même propriété : **le système fonctionnait, ne remontait aucune erreur, et livrait quelque chose de faux.**

## Défaut 1 : le correcteur parlait de lui-même dans le livrable

### Le symptôme

Un fichier livré contenait **104 marqueurs d'édition** en clair, du type `[EDIT-FLUIDITE :]`, et **14 préambules** de la forme « Voici le texte corrigé... ».

Autrement dit : le modèle commentait son propre travail, et ces commentaires se retrouvaient dans le manuscrit remis à l'auteur.

### La cause, qui n'est pas celle qu'on croit

Un nettoyage existait. Il visait les marqueurs **bien formés**, ceux du format que le prompt demandait.

Or un modèle de langage ne respecte pas un format, il le suit statistiquement. À côté de la forme attendue, il produisait une famille de variantes : espace avant les deux-points, catégorie abrégée, séparateur inversé. Aucune ne correspondait au motif de nettoyage, toutes traversaient le pipeline intactes.

Le correctif est un motif élargi, qui accepte toute la famille tout en restant **ancré et délimité** pour ne pas dévorer du texte légitime : un manuscrit contient des `[1]` de note, des `[...]` de coupure, et le mot `[EDITION]` peut parfaitement figurer dans une prose éditoriale. Un nettoyage trop large aurait été pire que le défaut.

### Le bug latent que le correctif a révélé

En regardant le pipeline de plus près, un second défaut est apparu, invisible jusque-là : les marqueurs n'étaient nettoyés qu'à la sortie. Chaque passe recevait donc en entrée la prose **annotée par la passe précédente**.

Deux conséquences. Le modèle voyait des annotations dans un texte censé être de la prose, ce qui l'encourageait à en produire davantage. Et le compteur de la passe 2 était mécaniquement gonflé, puisqu'il comptait aussi les marqueurs de la passe 1.

Correctif : nettoyer les marqueurs **entre** les passes, pour que chaque passe travaille sur de la prose propre.

### La partie qui vaut d'être racontée : une prédiction falsifiable

Ce correctif reposait sur une hypothèse : si les variantes apparaissent parce que le modèle voit des marqueurs en entrée, alors nettoyer entre les passes doit faire chuter leur nombre.

Plutôt que de déclarer la correction faite, j'ai écrit la prédiction **avant** la mesure, avec un chiffre et un moyen de la réfuter :

> Si le correctif traite la cause, le compteur de variantes de la passe 2 doit tomber de ~104 vers ~7, c'est-à-dire au niveau de la passe 1, qui ne reçoit jamais de marqueurs en entrée. Si ça ne baisse pas, le modèle dévie pour une autre raison, et il faut rouvrir le diagnostic côté émission.

Un compteur par passe a été instrumenté pour rendre la mesure possible, puis un traitement complet de manuscrit réel a été lancé.

Résultat, lu directement dans les fichiers de rapport et non déduit du livrable : **passe 1 = 1, passe 2 = 2, passe 3 = 0**.

La prédiction est confirmée et dépassée. Le modèle produit désormais le format propre, et le nettoyage de sortie n'est plus qu'un filet de sécurité.

Ce qui compte ici n'est pas le chiffre, c'est la forme. Une correction validée par « on ne voit plus le problème » ne prouve rien : le symptôme peut avoir été masqué. Une correction validée par une prédiction chiffrée, écrite avant la mesure et réfutable, prouve qu'on a compris la cause.

### Et le défaut que celui-ci cachait

Une fois les marqueurs partis, un troisième résidu est devenu visible : de la **prose méta sans aucun marqueur**. Des phrases entières, en français correct, qui parlent du travail de correction au lieu de faire partie du manuscrit.

Quatre familles, chacune échappant au nettoyage pour une raison différente :

- processuel à la première personne, « J'ai appliqué les corrections... » ;
- passif, « Les modifications ont été apportées... » ;
- variante de préambule, « Voici le texte **avec**... », qui échappe à un motif ancré sur « corrigé » ou « complet » ;
- formule de clôture, « n'hésitez pas à me le faire savoir ».

Mesure sur l'historique : **11 traitements sur 29** avec du texte final touché, **25 paragraphes** cumulés, le plus ancien remontant au **6 mars 2026**. Ce n'était donc pas une régression récente. La fuite de marqueurs, beaucoup plus visible, la masquait depuis trois mois.

### Le piège de la mesure elle-même

Compter ces paragraphes est plus délicat qu'il n'y paraît, et le premier critère que j'ai voulu employer était faux.

Chercher « j'ai » dans un manuscrit **sur-compte massivement**, parce que les manuscrits traités sont souvent des récits à la première personne. L'auteur écrit « j'ai décidé de partir » ; ce n'est pas le modèle qui parle de son travail, c'est le livre.

Le critère retenu procède en deux temps : nettoyer les marqueurs **d'abord**, puis exiger la **co-occurrence** d'une marque de discours sur le travail et d'un lexique d'édition. Jamais un mot seul.

Un indicateur qui sur-compte est aussi inutile qu'un indicateur aveugle, avec un défaut supplémentaire : il donne l'impression de fonctionner, et on agit sur ses chiffres.

## Défaut 2 : le GPU disparaissait sans erreur

### Le symptôme, et pourquoi il induisait en erreur

Certains traitements échouaient à la première passe avec trois expirations de délai de 600 secondes chacune.

Diagnostic naturel : le serveur d'inférence est tombé. Sauf que sa sonde de vivacité répondait 200, et son inventaire de modèles aussi.

Service vivant, traitements en échec. La contradiction a coûté du temps.

### La cause

Au redémarrage de la machine, le service d'inférence peut démarrer avant que le runtime CUDA de la carte qui lui est assignée soit prêt. Son garde de démarrage teste la disponibilité globale des GPU, qui répond positivement **avant** que la carte précise soit utilisable.

Le moteur d'inférence ne considère pas cette situation comme une erreur. Il charge le modèle en mémoire centrale et **sert sur processeur**. Silencieusement.

Trois conséquences en cascade. Le service ne sort jamais en erreur, donc la politique de redémarrage automatique ne se déclenche jamais et l'état dégradé persiste indéfiniment. Les sondes de vivacité répondent parfaitement, **parce qu'elles ne touchent pas au GPU**. Et un modèle de cette taille servi sur processeur est si lent que l'application, elle, voit des expirations de délai.

### Le correctif, et sa généralisation

Le diagnostic tient en une commande : vérifier dans le journal du service s'il annonce avoir trouvé un GPU et déchargé ses couches, ou s'il annonce n'en avoir trouvé aucun. La remise en état tient en un redémarrage du service.

Mais le vrai correctif est ailleurs. Une sonde qui répond 200 sans exercer la ressource critique ne prouve rien.

D'où une **sonde de disponibilité réelle** : une micro-génération chronométrée, qui exerce effectivement le chemin GPU et en tire un débit, avec quatre états distincts au lieu d'un booléen.

| État | Signification |
|---|---|
| disponible | génère, débit nominal |
| dégradé | génère, mais très en dessous du débit attendu, ce qui est la signature du repli processeur |
| occupé | un traitement est en cours, la lenteur est normale et attendue |
| injoignable | ne répond pas |

L'état « occupé » n'est pas un raffinement cosmétique : sans lui, la sonde déclare « dégradé » chaque fois qu'un vrai traitement occupe le GPU, produit une fausse alerte à chaque usage normal, et finit par être ignorée. Une garde anti-contention et un cache de 60 secondes complètent le dispositif, pour que la sonde ne devienne pas elle-même une charge.

Cette sonde est partagée entre l'écran d'administration et le point de santé public. Et le script de déploiement en tire une conséquence explicite : il **avertit sans déclencher de retour arrière**, parce qu'une application saine avec un GPU indisponible n'est pas une application défectueuse. Confondre les deux ferait annuler un déploiement correct pour une panne d'infrastructure.

Deux valeurs codées en dur ont disparu au passage : une capacité mémoire GPU écrite dans le code, et un débit de référence obsolète. Une valeur figée qui décrit un système vivant devient fausse sans prévenir, et elle est d'autant plus dangereuse qu'elle a l'air d'une mesure.

## Défaut 3 : le total était juste, et l'affichage mentait

Le rapport de fin de traitement annonçait **2 263 corrections**. Les quatre tuiles de détail, juste en dessous, en affichaient **1 975**.

Un écart de 288 entre un total et son détail, sur le même écran.

Le calcul était pourtant correct. Le total additionnait toutes les catégories, y compris les **123 corrections orthographiques en attente de validation humaine**, que les tuiles n'affichaient pas parce qu'elles ne sont justement pas appliquées automatiquement.

Le vrai défaut n'était donc pas dans le calcul, il était dans la **présentation** : un chiffre exact devenait faux par ce qu'il laissait croire. L'utilisateur lit « 2 263 corrections apportées » alors que 123 attendent son arbitrage.

Un second point de fragilité au passage : la somme parcourait toutes les valeurs du dictionnaire, y compris une clé `total` qui valait zéro. Elle donnait le bon résultat par chance, et aurait silencieusement doublé le compte le jour où cette clé aurait été renseignée.

Un total qui a raison mais fait comprendre autre chose est un défaut de la même famille que les deux précédents : le système fonctionne, ne signale rien, et transmet une information fausse.

## Ce que ces trois défauts ont en commun

Aucun n'a produit d'erreur. Aucun n'a fait tomber un service. Aucun n'aurait été détecté par une supervision d'infrastructure, et deux d'entre eux ont voyagé jusqu'à un livrable.

Trois enseignements, dans l'ordre d'importance.

**Une sonde qui n'exerce pas la ressource critique ne prouve rien.** Un service d'inférence peut répondre parfaitement à toutes ses sondes de vivacité tout en ayant perdu son GPU. La sonde utile est celle qui fait le travail, en petit, et qui mesure.

**Une correction se valide par une prédiction, pas par une absence de symptôme.** Écrire le chiffre attendu avant la mesure, et le moyen de se tromper, transforme une intuition en résultat. Et quand la prédiction est dépassée, on apprend quelque chose de plus : ici, que le modèle avait cessé de dévier, et pas seulement que le filet fonctionnait.

**Un indicateur qui sur-compte est aussi mauvais qu'un indicateur aveugle**, et plus dangereux, parce qu'il inspire confiance. Le premier critère de comptage des résidus aurait attribué au modèle la prose à la première personne des auteurs eux-mêmes.

Le point commun à ces trois défauts est finalement une seule question, qu'il faut poser à chaque étage d'un pipeline d'IA : **qu'est-ce que ce contrôle prouve exactement, et que laisse-t-il passer ?**

Hémerson Koffi, fondateur de HK CONSEILS, IA générative souveraine et infrastructures auto-hébergées pour les PME.
