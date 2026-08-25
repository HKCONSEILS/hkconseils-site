# Decisions.md — BLOG-VAGUE-2, nuit du 25 au 26/08/2026

Decisions prises sans arbitrage humain, en mode nuit. Chacune porte l'alternative ecartee
et le moyen de revenir en arriere. Rapport complet : section « REPORT — BLOG-VAGUE-2 » de
`REPORT.md`.

---

## D1 — La plateforme interne est nommee dans l'article et dans son slug

**Decision.** L'article T2 nomme la plateforme, dans son titre, dans son corps et donc
dans son URL publique : `/blog/openclaw-plateforme-multi-agents-lecons/`.

**Pourquoi.** La directive la nomme deux fois : dans la liste des livrables du §0 et dans
l'intitule de la tache T2. Son §2 enumere limitativement ce qui ne doit jamais apparaitre,
et prend meme la peine de trancher le cas d'une autre application ; ce nom-ci n'y figure
pas. La porte imposee par la directive, `scripts/check-leaks.sh`, ne le bloque pas et
passe verte.

**Alternative ecartee.** Ecrire l'article en parlant de « notre plateforme interne ». Elle
a ete ecartee parce que le commanditaire nomme les trois plateformes dans la meme phrase,
que les deux autres sont des produits publics nommes sans difficulte, et qu'un comparatif
ou une seule des trois est anonyme est bancal.

**Ce qui reste ouvert, et qui est le point le plus important de ce fichier.** La porte de
redaction hors depot, `siteweb/articles/publications/md/GATE-articles.sh`, **bloque
toujours ce nom** et sort donc en code retour 1. Elle n'a **pas** ete modifiee : son
commentaire dit que le blocage existe parce que « la question n'a pas ete posee » pour ce
nom, et modifier une porte pour la faire passer est exactement ce qu'il ne faut pas faire
en autonomie.

**Retrait, si la decision est inverse au merge.** Trois occurrences seulement, plus un
renommage :

```
# 1. retirer le nom du corps et du titre (2 fichiers du depot + leurs miroirs)
#    -> openclaw-plateforme-multi-agents-lecons.md lignes 2 et 14
#    -> agents-ia-on-premise-trois-architectures.md ligne 14 (lien interne)
# 2. renommer le fichier et le slug, puis corriger les 3 liens internes qui le visent
# 3. renommer le teaser F (son corps ne contient pas le nom, seul son nom de fichier)
```

---

## D2 — Aucun decompte d'agents n'est publie pour le pipeline

**Decision.** L'article decrit la structure du pipeline (analystes paralleles, debat
contradictoire, decideur, trois perspectives de risque, arbitrage de portefeuille) **sans
annoncer de nombre d'agents**.

**Pourquoi.** La directive demandait une liste enumerable, « la retrouver et s'y tenir ».
Les deux enumerations trouvees dans le plan directeur ne se reconcilient pas : l'une
annonce treize agents et en detaille quatorze ; l'autre decrit quatre analystes la ou la
premiere en compte cinq. Le code source n'est pas present sur cette machine.

**Alternative ecartee.** Publier « treize agents » en reprenant la formulation la plus
frequente. Ecartee parce qu'un chiffre dont je sais que l'enumeration ne tombe pas juste
est un chiffre que je sais fragile, et la regle de la nuit est qu'un chiffre sans source
solide se reformule sans chiffre.

---

## D3 — Le fait sur le registre d'annonces legales est abandonne, sans mention attenuee

**Decision.** Ni le chiffre de 7 000 entreprises par departement, ni le fait lui-meme ne
figurent dans l'article.

**Pourquoi.** Un balayage elargi a toutes les extensions de fichier ne trouve que deux
flux d'automatisation datant d'aout 2025, qui interrogent une API publique differente de
celle annoncee et deposent dans un tableur en ligne. Aucun journal d'execution, aucun
comptage, aucune date de run.

**Alternative ecartee.** Une mention qualitative du type « des prototypes de prospection
existent ». Ecartee parce qu'elle aurait donne du credit a un fait que je ne peux pas
etayer, tout en paraissant prudente.

---

## D4 — Aucune comparaison d'embeddings n'est publiee

**Decision.** L'article ne compare pas les deux modeles d'embeddings cites par la
directive, pas meme qualitativement.

**Pourquoi.** Aucun rapport de banc n'existe sur cette machine. La seule trace exploitable
est la dimension du modele en service. Les occurrences de l'autre modele appartiennent a
un projet dont le nom est bloque par les portes, ce qui interdit d'ailleurs de le citer
comme point de comparaison.

**Alternative ecartee.** Une phrase du type « nous avons compare les deux et retenu le
premier ». Vraie peut-etre, non sourcable ici, donc non publiee.

---

## D5 — Les trois visuels restent en reliquat

**Decision.** Les trois images du repertoire de publication ne sont integrees a aucun
article. Aucun article de cette nuit ne contient d'image.

**Pourquoi.** Deux raisons independantes, chacune suffisante. D'abord, l'article qu'elles
concernent vit sur B1, dont le §1 de la directive dit que **rien d'autre n'y change** que
le re-datage. Ensuite, la condition posee au §2 (conversion en webp sous 150 Ko et
chargement differe) n'a pas pu etre verifiee : aucune conversion n'a ete tentee, donc le
seuil n'est pas prouve, et la doctrine du depot interdit une image non verifiee.

**Alternative ecartee.** Convertir et integrer. Ecartee sur le premier motif, qui est un
interdit explicite de la directive.

---

## D6 — Les dates de publication en doublon sont assumees

**Decision.** Trois articles portent le 24/08, deux portent le 27/08.

**Pourquoi.** Le 27/08 est impose par la directive pour T1 et pour T5. Le 24/08 regroupe
volontairement les trois articles de plateformes, qui forment un ensemble. La `pubDate` ne
sert qu'au tri : elle ne differe aucune publication, donc un doublon n'a pas d'effet
mecanique. L'ordre rendu a ete verifie sur le build : le pilier arrive en tete de l'index,
l'article e-facture en deuxieme, ce qui est l'ordre souhaitable.

**Alternative ecartee.** Etaler artificiellement les dates pour les rendre uniques. Elle
n'aurait rien change au comportement du site et aurait desaligne T1 et T5 de la directive.

---

## D7 — Les deux branches sont poussees, aucune n'est fusionnee

**Decision.** `blog-02-cinq-articles` et `blog-03-vague-2` sont poussees sur le distant.
Aucun merge vers `main`, aucune modification de `main`.

**Pourquoi.** La directive interdit le merge par l'executant, mais confie le merge a
Hemerson : les branches doivent donc lui etre accessibles. La regle du parc veut par
ailleurs qu'un commit soit pousse le jour meme.

**Alternative ecartee.** Laisser les commits en local. Ecartee : elle rendrait le merge
impossible sans acces a cette machine.

---

## D8 — `AUDIT-BLOG-01.md` reste non suivi par git

**Decision.** Le rapport d'audit de la veille, a la racine du depot, n'est pas ajoute a
l'index et n'est pas commite.

**Pourquoi.** Il contient six occurrences d'un mot appartenant a la famille « nom d'hote
interne » de `check-leaks.sh`. L'ajouter ferait echouer la porte du depot, donc la CI.
Le point etait deja signale dans sa propre section 8.

**Alternative ecartee.** Le reecrire pour le rendre commitable. Hors perimetre de cette
nuit, et ce n'est pas a l'executant de decider qu'un rapport d'audit entre au depot.

---

## D9 — Aucune porte n'a ete modifiee pour faire passer un contenu

**Decision.** `GATE-articles.sh`, `check-leaks.sh`, `check-jsonld.py`, les workflows de CI
et les configurations de validation sont **inchanges**.

**Pourquoi.** C'est la regle qui rend tout le reste credible. Une porte que l'on assouplit
pour livrer ne mesure plus rien. La consequence assumee est qu'une porte sort en echec
cette nuit, et que cet echec est rapporte tel quel plutot que supprime.

**Alternative ecartee.** Ajouter une exception dans `GATE-articles.sh` pour le nom de la
plateforme, en s'appuyant sur la directive. Ecartee : la directive commande un article,
elle ne commande pas de modifier une porte, et la difference compte.

---

## D10 — Une PR **brouillon** est ouverte pour B2, afin que la CI tourne

**Decision.** `gh pr create --draft` sur `blog-03-vague-2` vers `main` : PR #7, en
brouillon, explicitement intitulee « ne pas merger sans relecture ».

**Pourquoi.** La CI de ce depot ne se declenche que sur un push vers `main`, sur une
*pull request*, ou a la main. Sans PR, **le job Lighthouse ne tourne jamais** — or c'est
le seul controle que la directive impose de lire et que la machine d'execution ne peut pas
rejouer, faute de navigateur. B1 disposait deja d'une PR (#6) ; B2 n'en avait pas.

**Pourquoi en brouillon.** Une PR en brouillon declenche la CI mais ne peut pas etre
fusionnee par megarde. Elle fournit la surface de relecture sans franchir l'interdit de
merge.

**Alternative ecartee.** Ne rien ouvrir et signaler le manque. Ecartee parce qu'elle
laissait le decideur sans le seul signal qu'il ne peut obtenir autrement, a deux jours de
la fermeture de la fenetre.

**Retour arriere.** `gh pr close 7`, la branche reste intacte.

---

## D11 — `GATE-articles.sh` amendee : le nom de la plateforme sort de la famille bloquee

**Decision d'Hemerson, revue du 2026-08-25.** Ce n'est pas une decision autonome : elle est
consignee ici parce que c'est le registre des arbitrages qui touchent aux portes.

`openclaw` est **retire** de la famille « noms d'applications » de
`siteweb/articles/publications/md/GATE-articles.sh`. Justification donnee : **c'est le nom
public de la plateforme, et sa publication etait deja actee par ailleurs** (section Agents,
dossier BPI). Le blocage precedent n'existait que parce que la question n'avait pas ete
posee ; elle l'est desormais, et elle est tranchee. Le slug
`/blog/openclaw-plateforme-multi-agents-lecons/` est valide.

**Ce qui a change, exactement.** Une seule ligne `scan` retiree sur quinze. Le controle de
disparition le prouve : `diff` des seules lignes `scan` avant et apres, **une ligne
supprimee, aucune modifiee**.

**Pourquoi le scan est retire et non vide.** La famille n'avait que cette entree. Laisser
`scan "..." '\b()\b'` aurait produit une alternation vide, qui **matche chaque ligne** et
aurait transforme la porte en refus permanent. C'est le piege classique du motif qu'on
croit desactiver en le vidant.

**Preuve 1, la porte repasse au vert.** `./GATE-articles.sh` -> `GATE: OK — 10 articles +
10 teasers analyses`, **code retour 0**, alors que les trois occurrences sont toujours dans
les fichiers (titre et corps de l'article dedie, lien interne du comparatif).

**Preuve 2, la porte mord toujours.** Un temoin positif par famille non touchee, ecrit
dans `blog/` puis retire :

| Temoin | Code retour | Motif declenche |
|---|---|---|
| nom d'hote interne | **1** | `nom d'hote ou de service interne` |
| nom de client confidentiel | **1** | `nom de client ou de projet confidentiel` |
| adresse IP privee | **1** | `adresse IP privee (RFC1918)` |
| identifiant de conteneur | **1** | `identifiant de VM/conteneur, forme accolee` |
| sous-domaine interne | **1** | `sous-domaine interne ou de client` |
| tiret cadratin | **1** | `tiret cadratin (convention: aucun)` |

Controle de disparition du temoin apres coup : fichier absent, **10 articles** dans
`blog/`, porte rejouee a **0**. Une porte qui repasse au vert sans qu'on ait verifie
qu'elle mord encore n'est plus une porte, c'est un `echo`.

**Un residu signale, non corrige.** L'en-tete du script decrit encore son perimetre comme
couvrant « les noms de produits et d'applications non ouverts au public ». La famille est
desormais vide : ce commentaire ne decrit plus rien. Il n'a **pas** ete touche, la consigne
etant de ne retirer que `openclaw` et rien d'autre. A nettoyer a la prochaine passe sur ce
fichier.

**Portee.** `scripts/check-leaks.sh`, la porte du depot, **n'a pas ete modifiee** : elle ne
bloquait deja pas ce nom. Aucune autre porte, aucun workflow de CI, aucune configuration de
validation n'a change. La decision D9 reste donc vraie sous sa forme utile : aucune porte
n'a ete assouplie **par l'executant pour faire passer un contenu**, celle-ci l'a ete sur
arbitrage explicite du decideur, et la preuve qu'elle mord encore accompagne le changement.

---

## D12 — Backlog post-gel enregistre, rien d'engage

**Trois** points portes au backlog par la revue, **aucune action entreprise sur aucun** :

1. **Elargir l'echantillon Lighthouse** de une ou deux URL d'articles recents, pour que le
   seuil mobile porte aussi sur les pages longues. Fichier : `lighthouserc.cjs`.
2. **Integrer les trois visuels** a l'article sur la migration de modele, sous condition de
   conversion en webp sous 150 Ko et de chargement differe.
3. **Nettoyer le commentaire d'en-tete de `GATE-articles.sh`**, orphelin depuis le retrait
   de la famille « noms d'applications » (decision D11). Il decrit encore un perimetre
   couvrant « les noms de produits et d'applications non ouverts au public », alors que
   cette famille n'a plus aucune entree. **A traiter a la prochaine passe sur la porte**,
   pas avant : c'est la que le fichier sera de toute facon rouvert.

Les deux premiers sont repris en section **D** du dossier de relecture, en tete de
`REPORT.md`. Le troisieme est ajoute ici a la demande de la revue, sur le principe qu'un
backlog qui ne vit que dans une conversation meurt en silence, alors qu'une ligne dans le
depot survit.
