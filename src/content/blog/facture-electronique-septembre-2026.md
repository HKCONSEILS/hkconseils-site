---
title: "Facture électronique : ce qui change au 1er septembre"
description: "Au 1er septembre 2026, toute entreprise assujettie à la TVA doit être capable de recevoir une facture électronique. Ce que l'obligation couvre vraiment, les formats, le rôle des plateformes agréées, et ce que l'automatisation change une fois la contrainte posée."
pubDate: 2026-08-27
tags: ["conformité", "facturation", "automatisation", "extraction"]
---

Dans quelques jours, une obligation entre en vigueur sans période de tolérance et sans seuil : au 1er septembre 2026, toute entreprise établie en France et assujettie à la TVA doit être en capacité de **recevoir** des factures électroniques. Recevoir, pas émettre. C'est la partie de la réforme qu'on oublie parce qu'elle ne demande rien de spectaculaire, et c'est celle qui concerne tout le monde en même temps.

*Article écrit le 25 août 2026 à partir des textes publiés par l'administration fiscale. Les dates et les termes cités sont ceux en vigueur à cette date ; la réforme a déjà changé de calendrier par le passé, vérifiez la source avant de vous engager.*

## Ce que l'obligation couvre, exactement

Le calendrier tient en deux lignes.

Au **1er septembre 2026**, toutes les entreprises assujetties à la TVA doivent pouvoir recevoir une facture électronique. À la même date, les grandes entreprises et les entreprises de taille intermédiaire ont en plus l'obligation d'**émettre** sous cette forme.

Au **1er septembre 2027**, cette obligation d'émission s'étend aux micro-entreprises, aux TPE et aux PME, avec la transmission à l'administration des données de transaction.

Le champ est large et il vaut la peine de le dire clairement : la réforme vise toutes les entreprises assujetties à la TVA, quels que soient leur taille, leur chiffre d'affaires, leur forme juridique ou leur régime d'imposition, y compris celles qui bénéficient d'une franchise. Il n'y a pas de seuil en dessous duquel on serait hors sujet.

Quatre nouvelles mentions obligatoires apparaissent également sur les factures au 1er septembre 2026, dont la catégorie de l'opération facturée, vente ou prestation de services, et l'adresse de livraison quand elle diffère de l'adresse de facturation.

## Le point qui coince : un PDF n'est pas une facture électronique

C'est la confusion la plus répandue, et la plus coûteuse à découvrir tard. Une facture papier scannée, un PDF ordinaire, un document envoyé par courriel : rien de tout cela ne sera conforme. Le fait qu'un fichier soit numérique ne le rend pas électronique au sens de la réforme.

Ce qui est attendu, ce sont des formats structurés : **UBL**, **CII**, ou un format mixte associant un fichier de données structurées et un fichier image. Ce dernier est celui que la plupart des entreprises françaises croiseront en pratique sous le nom de **Factur-X** : un PDF parfaitement lisible par un humain, qui transporte dans ses métadonnées un fichier XML lisible par une machine. Le même document sert les deux publics, et c'est tout l'intérêt du format hybride.

Autrement dit, la facture cesse d'être une image à lire pour devenir une donnée à traiter. C'est un changement de nature, pas un changement de canal.

## Par où passent les factures

Les échanges ne se font pas de gré à gré. Chaque entreprise doit passer par un intermédiaire, une **plateforme agréée**, définie comme une entreprise privée immatriculée par l'État. Une première liste de 101 plateformes agréées a été publiée par l'administration en janvier, et une large part d'entre elles était déjà raccordée à l'annuaire au moment de cette publication.

L'annuaire, justement, est la pièce que l'on sous-estime. Ouvert depuis septembre 2025, il recense les entreprises et entités publiques soumises aux obligations, et indique pour chacune la plateforme agréée qui gère ses données et ses adresses de facturation électronique. C'est lui qui permet à un émetteur de savoir où adresser sa facture. Une entreprise absente de l'annuaire, ou raccordée à une plateforme qui n'a pas mis à jour son adresse, est une entreprise à qui l'on ne peut pas facturer proprement.

Pour le secteur public, la plateforme de référence existante reste en place à partir de 2026.

## Ce qu'il y a à faire, concrètement, avant le 1er septembre

Pour la seule obligation de réception, la liste est courte, et c'est une bonne nouvelle.

1. **Choisir une plateforme agréée** et s'y raccorder. C'est le prérequis de tout le reste.
2. **Vérifier sa présence et ses adresses dans l'annuaire.** Une adresse fausse ou absente ne produit pas d'erreur visible chez vous : elle produit une facture qui n'arrive pas.
3. **Interroger son éditeur de logiciel** sur son positionnement dans la réforme et sur la plateforme à laquelle il se raccorde. La question à poser n'est pas seulement « serez-vous prêts », mais « par quelle plateforme passez-vous, et quand mon adresse sera-t-elle à jour dans l'annuaire ».
4. **Vérifier que la chaîne avale du structuré.** Recevoir un fichier ne sert à rien si le système comptable en aval attend toujours qu'un humain relise une image.

Le quatrième point est celui qui distingue une conformité de façade d'une conformité utile. On peut être techniquement en capacité de recevoir, et continuer à ressaisir à la main.

## Ce que l'automatisation change, et dans quel sens

Il faut dire une chose contre-intuitive : la facture électronique **simplifie** le travail d'extraction automatique, elle ne le complique pas.

Le cas difficile, celui sur lequel on se casse les dents depuis des années, c'est le document non structuré. Un PDF dont la mise en page change d'un fournisseur à l'autre, des tableaux sur deux colonnes, des totaux calculés ailleurs que là où on les cherche, des scans de qualité inégale. Extraire de la donnée fiable de ce matériau demande une chaîne complète : segmentation, lecture, vérification, et surtout un dispositif capable de dire quand il n'est pas sûr.

C'est exactement le problème que nous traitons en production sur Editos, notre chaîne de traitement éditorial : un document entre, une donnée structurée et vérifiée sort, sans que le contenu quitte l'infrastructure. La leçon principale de cette chaîne n'est pas dans le modèle employé, elle est dans les contrôles. Un pipeline qui traite un document sans jamais échouer bruyamment produit tôt ou tard un résultat faux que personne ne voit passer. Nous en avons publié [trois exemples mesurés](/blog/editos-defauts-silencieux-pipeline-ia/), et c'est ce qui nous a appris à instrumenter avant d'automatiser.

Face à ce cas difficile, le XML de Factur-X est le cas facile. Les champs sont nommés, typés, au même endroit à chaque fois. L'incertitude de lecture disparaît. Ce qui reste à faire est du rapprochement métier, et c'est là que la valeur se déplace : rapprocher une facture d'un bon de commande, détecter un écart de prix, repérer un doublon, router pour validation. Des problèmes qui redeviennent traitables une fois qu'on ne se bat plus contre le format.

Une précaution, cependant, parce qu'elle sera la source des mauvaises surprises de 2027 : pendant plusieurs années, les deux mondes vont coexister. Les factures conformes arriveront en structuré, et un volume résiduel continuera d'arriver autrement, hors du périmètre de la réforme ou par des fournisseurs étrangers. Une chaîne de traitement qui ne saurait faire que le cas facile devrait être doublée d'un traitement manuel pour tout le reste. Concevoir pour le cas difficile et bénéficier du cas facile est plus robuste que l'inverse.

## Ce que je retiens

La date du 1er septembre 2026 n'est pas un projet informatique, c'est une condition d'exercice. L'obligation de réception se traite en quelques semaines si elle est prise maintenant, et elle se traite mal dans l'urgence parce que le maillon lent n'est pas technique : c'est le raccordement à une plateforme et la mise à jour d'un annuaire, deux choses qui dépendent de tiers.

Le vrai sujet arrive après. Une fois la facture devenue une donnée structurée, la question n'est plus « comment la lire » mais « qu'est-ce que j'en fais automatiquement, et comment je sais que l'automatisme ne s'est pas trompé ». C'est un bien meilleur problème que celui qu'on avait avant.
