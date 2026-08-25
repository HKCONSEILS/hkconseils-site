# REPORT — SITE-01 · Site vitrine HK CONSEILS

> ## ⚠️ Circuit de merge en cours — BLOG-VAGUE-2 (25/08/2026)
>
> Deux branches attendent une relecture puis un merge **par Hemerson uniquement** :
> **`blog-02-cinq-articles` d'abord, `blog-03-vague-2` ensuite** (la seconde contient la
> premiere). **Fenetre : avant le 27/08 au soir**, sinon apres le 11/09 a cause du gel
> pre-depot BPI du 28/08 au 11/09. Detail complet en fin de fichier, section
> « REPORT — BLOG-VAGUE-2 ». Decisions autonomes : `Decisions.md`.

---

# REV2 — passe du 26/08, a lire avant le reste du dossier

**Verdict CI du commit final `c819c58` : `success`.** Quatre jobs verts. Lighthouse :
**11 URL, 100 en performance, 100 en accessibilite, 100 en bonnes pratiques, 100 en SEO**,
mediane de trois passages. L'artefact `dist` passe de **229 143 o** a **233 750 o**, soit
**4 607 octets** de plus : du contenu servi a bien change, comme attendu.

## 1. Les quatre liens officiels, poses apres recuperation reelle

| Lien pose sur | Source | Recuperation | Le contenu porte-t-il le fait ? |
|---|---|---|---|
| « toutes les entreprises assujetties a la TVA doivent pouvoir recevoir une facture electronique » | economie.gouv.fr, « Tout savoir sur la facturation electronique » | **403** en client simple, **200 au navigateur**, meme URL, titre conforme | oui : calendrier 2026 et 2027, emission GE et ETI, champ TVA |
| « Ce qui est attendu, ce sont des formats structures » | impots.gouv.fr, « Je decouvre la facturation electronique » | **200**, 59 167 o | oui : UBL, CII, format mixte, « plateforme agreee », « immatriculee par l'Etat », non-conformite du PDF ordinaire |
| « premiere liste de 101 plateformes agreees » | economie.gouv.fr, actualite dediee | **200 au navigateur**, meme URL | oui : le nombre 101 et le terme « plateformes agreees » |
| « Ouvert depuis septembre 2025 » | economie.gouv.fr, actualite sur l'ouverture de l'annuaire | **200 au navigateur**, meme URL | oui : l'article est **date du 18/09/2025** et annonce l'ouverture ce jour-la |

**Le 403 n'etait pas une page morte.** Les trois pages `economie.gouv.fr` refusent un client
non-navigateur ; le corps renvoye dit « Just a moment... Enable JavaScript », c'est un
pare-feu applicatif. Verifie au navigateur : les trois repondent **200**, aux **memes URL**,
avec les titres attendus. **Aucune URL n'a bouge**, aucune substitution n'a ete necessaire.

### Ce que la verification a corrige dans l'article

**« Quatre nouvelles mentions obligatoires » ne figure sur aucune page sourcable.** Le
compte venait d'une synthese de recherche, pas d'une lecture. La phrase est reecrite sur ce
que l'administration ecrit vraiment : les mentions doivent figurer **dans des champs
dedies**, avec les exemples qu'elle cite. **Le compte a disparu de l'article.**

C'est la troisieme fois de ce chantier qu'une formulation plausible tenait lieu de
verification. Les deux precedentes : le tri de l'echantillon Lighthouse annonce comme
chronologique alors qu'il etait alphabetique, et la case « secrets accessibles » qui
rapportait une deduction comme une mesure.

## 2. Densite visuelle, avant et apres

Relevee **depuis les commits eux-memes**, pas de memoire.

| Article | Avant (`a28361f`) | Apres (`c819c58`) | Seuil |
|---|---|---|---|
| e-facture | 1 schema, 0 code, 1 exergue | 1, **1**, 1 | atteint |
| OpenClaw | 1, 0, 1 | 1, **2**, 1 | atteint |
| Hermes | 1, 2, 1 | 1, **3**, 1 | atteint |
| IronClaw | 2, 2, 1 | 2, **3**, 1 | atteint |
| pilier | 2, 0, 1 | 2, 0, 1 | **volontairement** sans extrait, par consigne |

**Neuf extraits** portent desormais l'habillage « fenetre de terminal » : cadre, barre de
titre, pastilles, police mono. **CSS pur, aucun JavaScript**, `dist/` reste sans fichier
`.js`. Un arbitrage a signaler : les pastilles sont **blanches a faible opacite** et non
rouge, jaune, vert — la charte interdit d'introduire une teinte nouvelle, et les trois
couleurs d'usage en auraient ajoute trois.

## 3. Les cinq extraits ajoutes

| Article | Extrait | Source | Fait de l'article qu'il illustre |
|---|---|---|---|
| Hermes | journal du service : decouverte d'IP de repli par DNS-over-HTTPS, puis expirations | rejoue en lecture seule sur l'hote de POC | le runtime emet un trafic **non declare** ; la liste blanche le refuse |
| IronClaw | `ss` sur la surface d'ecoute + ligne `wasm_limiter` avec ses valeurs | rejoue en lecture seule sur l'hote de POC | le bac a sable refuse une demande de memoire a la limite declaree ; une seule socket, sur la boucle locale |
| OpenClaw | le dictionnaire de regles constantes, tel qu'il est ecrit | piece du chantier G | « les regles sont des constantes, le modele ne peut pas les modifier par une invite » |
| OpenClaw | une ligne de verdict au format JSONL | piece du chantier G, **produite en validation le 22/08 et ecartee du journal reel** — dit dans l'article | la regle violee est **nommee**, pas resumee en refus generique |
| e-facture | extrait Factur-X, entreprise **fictive** `EXEMPLE-SARL` | construit d'apres la documentation publique du format | « la facture devient une donnee » : champs nommes et types |

**Assainissement** : identifiants d'hote remplaces par des chevrons, chemins reels remplaces
par une designation entre chevrons, et pour les secrets **aucune valeur**, uniquement les
droits, le proprietaire et le nombre de noms definis.

### ✅ Deux noms de tiers, CAVIARDES sur decision du decideur

**Decision rendue : caviardage.** Signale d'abord comme arbitrage en attente — aucune porte
ne les bloquait, et la litteralite de la ligne avait de la valeur — mais ce sont des
informations **nouvelles**, introduites par un extrait et absentes de toute la prose. Le
decideur a tranche pour le caviardage. **Applique.**

Balayage systematique des 15 blocs : tout nom propre present dans un extrait a ete
recherche dans le corps de son article, figures exclues. Deux cas ressortent.

| Nom | Ou | Occurrences | Present dans la prose ? | Enjeu |
|---|---|---|---|---|
| **Telegram** | extrait de journal, article Hermes | **4**, toutes dans le meme bloc | **non** — la prose dit « canal de messagerie » partout, dans cet article comme dans le pilier | nomme le canal reellement eprouve pendant le POC |
| **ETH-USD** | ligne de verdict JSONL, article OpenClaw | **1** | **non** — la prose dit « instruments volatils », sans jamais nommer d'instrument | revele qu'une paire crypto figure au perimetre du pipeline |

Deux cas sans enjeu, verifies au passage : `EXEMPLE-SARL` est explicitement fictive, et
`VAT` est un code de type du format, pas une donnee.

**Ce que le caviardage a exige en plus du remplacement.** Les deux articles portaient une
phrase decrivant leur propre assainissement. Celle de Hermes disait « les identifiants
d'hote sont remplaces par des chevrons, **rien d'autre n'est modifie** » : elle devenait
**fausse** au moment meme du caviardage. Elle dit desormais que l'identifiant d'hote **et le
nom du canal** sont remplaces. Celle d'OpenClaw a recu la meme mention pour l'instrument.
Un caviardage qui laisse derriere lui une declaration d'assainissement perimee est pire que
pas de caviardage : il transforme une omission en affirmation fausse.

L'alignement du bloc de journal a ete refait, `<messagerie>` etant plus long que le nom
d'origine.

**Recette appliquee**, conservee pour tracer ce qui a change :

```
# article Hermes, dans le seul bloc de journal
sed -i 's/\[Telegram\]/[<messagerie>]/g; s/Telegram API/<messagerie> API/; s/Connecting to Telegram/Connecting to <messagerie>/g' \
  src/content/blog/hermes-poc-agent-ce-qui-nest-pas-annonce.md
# article OpenClaw, dans la ligne de verdict
sed -i 's/"ETH-USD"/"<instrument>"/' src/content/blog/openclaw-plateforme-multi-agents-lecons.md
```

**Controle de disparition** : `Telegram` **0 occurrence**, `ETH-USD` **0 occurrence** sur
les cinq articles, temoin inverse a 1 sur le meme motif. Le cout est assume : l'extrait perd
la litteralite du journal, qui faisait une partie de sa force. Il garde ce qui compte, la
sequence reelle et ses horodatages.

**Controle anti-fuite sur les 15 blocs de code du blog**, cinq familles, temoin inverse a 1
sur chacune :

| Famille | Occurrences |
|---|---|
| adresse IP privee | **0** |
| nom d'hote ou de service interne | **0** |
| sous-domaine interne ou nom de client | **0** |
| identifiant de VM ou de conteneur | **0** |
| chaine ressemblant a une valeur de secret | **0** |

## 4. Natif, extensible, convention, hors produit — ligne par ligne

Deux valeurs ne suffisaient pas. L'identite chez deux des trois n'est **ni native ni
extensible** : c'est un fichier que l'exploitant pose et que rien n'oblige, donc une
**convention**. Et le cloisonnement reseau de ces deux-la vient du pare-feu de la machine,
donc **hors produit**. Ces deux marqueurs ont ete ajoutes, et une legende les explique dans
l'article.

| Ligne du tableau | OpenClaw | Hermes | IronClaw | Source |
|---|---|---|---|---|
| Mecanisme d'identite | convention | convention | **natif** | tableau croise du rapport IronClaw, et sa section sur les quatre fichiers d'identite |
| Qui ecrit l'identite | convention | convention | **natif** | idem |
| Identite relisible | convention | convention | **natif** | idem |
| Restriction d'outillage | natif | natif | natif | tableau croise, ligne « restriction de toolset » |
| Secrets accessibles | non mesure | non mesure | **natif** | rapport IronClaw, test des secrets |
| **Terminal accessible** | non mesure | **extensible** | natif, reglable par capacite | rapport Hermes : en ligne de commande, **c'est le jeu d'outils charge qui donne le terminal** |
| Cloisonnement reseau | hors produit | hors produit | **natif + hors produit** | les deux rapports : pare-feu de la machine, plus une liste blanche applicative chez IronClaw |
| Requetes detournees | non mesure | non mesure | **natif** | rapport IronClaw, garde actif par defaut |
| Bac a sable d'outils | non mesure | non mesure | **natif** | rapport IronClaw, trois temoins inverses |
| Installation au demarrage | non mesure | **natif** | **natif** | rapport Hermes (installation a chaque lancement), rapport IronClaw (aucune) |
| Les trois dernieres lignes | *sans marqueur* | | | ce sont des **mesures**, pas des mecanismes |

**Le cas qui justifie tout l'exercice** est celui du terminal. Chez l'agent Python, il n'est
pas une propriete du produit : il apparait parce que le jeu d'outils charge en ligne de
commande le fournit. Changer d'outillage change la reponse. La question « cet agent a-t-il
acces au shell » est donc incomplete si l'on ne precise pas « avec quels outils charges ».

## 5. Corrections de fond

- **La prescription fausse est corrigee.** « Un POC doit etre mene sur le canal de
  production » devient « sur un canal **identique** a celui de la production, une
  pre-production » — mener un POC sur la production serait imprudent. L'idee conservee, et
  qui reste vraie, est que le terminal ment par omission parce qu'il ne traverse pas la
  meme chaine.
- **Deux paragraphes de langage**, chacun adosse a un fait deja mesure dans son article :
  pour Python, l'ecosysteme IA dominant contre l'installation de dependances a l'execution
  et le pic a 209 % d'un coeur ; pour Rust, la surete memoire sans ramasse-miettes, le
  binaire autonome (32 competences depaquetees, zero installation), l'affinite WebAssembly
  et les 18 % d'un coeur, avec la contrepartie assumee d'un ecosysteme plus jeune et d'une
  ligne de version fraiche.

## 6. Porte de redaction

Elle n'a **pas** ete rouverte par cette passe : le style « fenetre de terminal » vit dans le
gabarit du blog, pas dans la porte. Le commentaire d'en-tete orphelin de `GATE-articles.sh`
**reste donc au backlog**, conformement aux exclusions.


---

# DOSSIER DE RELECTURE — BLOG-VAGUE-2 (a lire en premier)

## A. Verdict CI, run final

**`2f2c8ee` sur `blog-03-vague-2` (PR #7) : `completed / success`.** Les quatre jobs
passent, Lighthouse compris. Les deux runs anterieurs de la branche sont verts eux aussi
(`0bfcbe3`, `a4cd4bb`), et le run de `blog-02-cinq-articles` (PR #6) l'est egalement, avec
**100 / 100 / 100** en performance, accessibilite et SEO sur chaque URL echantillonnee,
sur six passages chacune.

| Branche | Commit | Build + non-regression | Fuites + JSON-LD | HTML valide | Lighthouse |
|---|---|---|---|---|---|
| B1 `blog-02-cinq-articles` | `670e8b3` | ✅ | ✅ | ✅ | ✅ 100/100/100 |
| B2 `blog-03-vague-2` | `a4cd4bb` | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `0bfcbe3` | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `2f2c8ee` | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `1462c74` | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `fdf290e` | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `f1aec21` *(nommage)* | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `474b557` *(schémas)* | ✅ | ✅ | ✅ | ✅ **11 URL, 100 partout** |
| B2 `blog-03-vague-2` | `f0fd64c` | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `ff8a909` *(rapport)* | ✅ | ✅ | ✅ | ✅ |
| B2 `blog-03-vague-2` | `a28361f` *(aeration)* | ✅ | ✅ | ✅ | ✅ **11 URL, 100 partout** |
| **B2 `blog-03-vague-2`** | **`b7db79e`** *(final)* | ✅ | ✅ | ✅ | ✅ |

**Cette reserve est levee depuis `474b557`.** L'echantillon portait sur six URL et
n'incluait aucune page nouvelle ; il en compte desormais **onze**, dont les cinq articles
de cette nuit. Resultat mesure sur chacun d'eux : **100 en performance, 100 en
accessibilite, 100 en bonnes pratiques, 100 en SEO**, mediane de trois passages, six
mesures par categorie. Le vert couvre donc bien ce qui vient d'etre ecrit, schemas
compris, et plus seulement le gabarit.

Effet de bord a connaitre : le job Lighthouse passe d'environ 4 minutes a **7 min 14**,
puisqu'il mesure onze URL au lieu de six.

## B. Liens externes de l'article e-facture, a valider

Tous dans T1, tous vers des sources primaires de l'administration. **Aucun autre article
n'en contient.** Etat actuel : **les liens ne sont PAS poses**. Le texte cite les faits et
nomme la source en clair sans hyperlien, position conservatrice retenue en mode nuit
puisqu'un lien pose est plus difficile a retirer qu'a ajouter.

| # | Source | Ce qu'elle etaye | Justification |
|---|---|---|---|
| 1 | `economie.gouv.fr` — « Tout savoir sur la facturation electronique pour les entreprises » | calendrier 2026 et 2027, champ d'application, quatre nouvelles mentions | page de reference interministerielle, la plus stable dans le temps |
| 2 | `impots.gouv.fr` — « Je decouvre la facturation electronique » | formats UBL, CII et hybride ; non-conformite du PDF ordinaire ; definition de la plateforme agreee | source fiscale directe, c'est elle qui porte les termes exacts cites dans l'article |
| 3 | `economie.gouv.fr` — actualite « ouverture de l'annuaire dedie » | date d'ouverture (septembre 2025) et role de l'annuaire | seule source datee pour l'annuaire, qui est le maillon lent du dispositif |
| 4 | `economie.gouv.fr` — actualite « la liste des 101 premieres plateformes agreees » | le chiffre de 101 et sa date de publication | c'est la source du seul chiffre de plateforme cite dans l'article |

**Action attendue** : valider les quatre, puis les poser. Si l'un est ecarte, la phrase
correspondante tient sans lui, aucune reecriture n'est necessaire.

## C. Faits utilises, par article, avec leur source

Convention : **[M]** = mesure, avec un fichier ou une source primaire a l'appui.
**[E]** = estimation ou declaration non mesuree. **Aucun [E] n'a ete publie.**

### T1 — facture electronique

| Fait | Source | |
|---|---|---|
| Au 01/09/2026, toute entreprise assujettie a la TVA doit pouvoir **recevoir** | economie.gouv.fr, impots.gouv.fr | [M] |
| Emission obligatoire GE et ETI au 01/09/2026 | economie.gouv.fr | [M] |
| Emission micro-entreprises, TPE, PME au 01/09/2027, avec donnees de transaction | economie.gouv.fr | [M] |
| Champ : toutes tailles, tous CA, toutes formes juridiques, tous regimes, franchise comprise | economie.gouv.fr | [M] |
| Quatre nouvelles mentions obligatoires au 01/09/2026 | economie.gouv.fr | [M] |
| Formats : UBL, CII, ou format mixte donnees structurees + image | impots.gouv.fr | [M] |
| PDF ordinaire, scan et envoi par courriel **non conformes** | impots.gouv.fr | [M] |
| Plateforme agreee = entreprise privee immatriculee par l'Etat | impots.gouv.fr | [M] |
| 101 premieres plateformes agreees publiees en janvier | economie.gouv.fr | [M] |
| Annuaire ouvert depuis septembre 2025, indique la plateforme de chaque entite | economie.gouv.fr | [M] |
| Plateforme de reference du secteur public maintenue a partir de 2026 | impots.gouv.fr | [M] |

Le point d'ancrage interne fourni par la directive (une ligne de cadrage marche dans
`infra-backup-new/openclaw/docs/openclaw-masterplan-v3_10_32.html`) a ete **re-verifie et
confirme** par les sources primaires ci-dessus, qui seules sont citees dans l'article.

### T2 — plateforme multi-agents

| Fait | Source | |
|---|---|---|
| Sept phases P0 a P6, intitules et sequencement | `infra-backup-new/openclaw/docs/openclaw-masterplan-v3_10_32.html` | [M] |
| **P0 finalise, P1 complet**, soit 2 phases sur 7 | idem | [M] |
| Veille : 4 collectes par jour a 00h, 06h, 12h, 18h | `homelab/docs/openclaw-masterplan-v3_10_28.html` | [M] |
| Veille : 3 syntheses par semaine, lundi, mercredi, vendredi 8h | idem | [M] |
| 11 depots suivis, plus les registres de paquets | idem | [M] |
| Jeton d'acces en lecture seule, portee restreinte | idem | [M] |
| Auto-surveillance du jeton **a chaque collecte**, avec alerte | idem | [M] |
| Composant de controle : 221 lignes, regles constantes non modifiables par invite | `chantierG/G-RUN-20260822-132924/BPI_ENFORCEMENT_NOTE.md` | [M] |
| Regles couvertes : sens unique, stop-loss et take-profit obligatoires, plafond de perte, taille de position, tresorerie residuelle, seuil de confiance | idem | [M] |
| 19 tests fonctionnels passants | idem | [M] |
| Journal applicatif du 09/04 au 22/08, 57 082 lignes, un refus explicite et date | idem | [M] |
| Coupe-circuit tenant 3 strategies en pause, horodatage de reprise par strategie | idem | [M] |
| Journal de decisions par ligne depuis le 22/08/2026, 6 champs | idem | [M] |
| Trois proprietes testees, dont « une panne d'ecriture ne modifie ni le verdict ni les violations » | idem | [M] |
| Formule « zero violation depuis avril » **retiree** car invérifiable | idem | [M] |
| Instrumentation additive, 19 tests preexistants inchanges | idem | [M] |
| Structure du pipeline : analystes paralleles, debat contradictoire, decideur, trois perspectives de risque, arbitrage de portefeuille | `…masterplan-v3_10_32.html` | [M] |

### T3 — agent conversationnel Python

Source unique : `chantierH/H-RUN-20260822-211451/RAPPORT_FINAL.md`. Tous les faits sont [M].

| Fait | |
|---|---|
| 9 criteres, seuils ecrits avant mesure : 8 tenus, 1 partiel, 0 echec | [M] |
| Service actif 17 s apres demarrage machine, seuil 60 s | [M] |
| Latence : premiere mesure a 22,6 s **ecartee** avec sa raison ; 14,0 s a froid, 7,4 s a chaud, seuil 15 s | [M] |
| Memoire : 2 faits sur 2 restitues apres redemarrage | [M] |
| Tache planifiee a +5 min delivree | [M] |
| Aucune competence auto-creee | [M] |
| Sous-agent delegue, resultat rendu en 29,2 s | [M] |
| Charge : 130 Mo au repos, 139 Mo en generation, pic 209 % d'un coeur | [M] |
| Installation de 2 paquets **a chaque lancement** ; ~100 s de delais d'expiration et 192 paquets rejetes ; demarrage 102 s -> 4,9 s apres neutralisation | [M] |
| Trois reglages necessaires la ou la documentation en annonce un ; deux actifs par defaut, absents de la configuration livree | [M] |
| Avertissement faux de la commande de configuration sur une cle que le code lit | [M] |
| Panne visible uniquement sur le canal de messagerie, ligne de commande fonctionnelle | [M] |
| Adherence : refus hors perimetre conforme, 2 interdictions citees ; gras et listes utilises malgre l'interdiction ; prefixe 4/4 sur un canal, 2/5 sur l'autre | [M] |
| Sortie reseau : 0 paquet de l'agent, 16 paquets du runtime non declares | [M] |

### T4 — runtime Rust

Source unique : `chantierI/I-RUN-20260823-005800/RAPPORT_FINAL.md`. Tous les faits sont [M].

| Fait | |
|---|---|
| 11 criteres : 7 reussis, 1 en forme forte, 1 partiel, 2 echoues | [M] |
| Latence ~22 s par tour sur 10 mesures, seuil 15 s : **echec assume** | [M] |
| Restriction d'outillage : invite de 52 700 a 13 435 jetons, soit -74 %, pour 1 s de gain | [M] |
| Adherence : prefixe 3/3 puis 0/1 ; script de 200 lignes produit hors perimetre | [M] |
| Le script a ete **affiche, jamais ecrit** : outil d'ecriture desactive | [M] |
| Secrets : 7 variables banales dans le processus d'outillage, aucune des 4 secretes du service | [M] |
| Fichier de secrets lisible hors du produit avec le meme compte, **non lisible au travers** | [M] |
| Chemin de lecture construit par l'agent lui-meme, pour que la question n'explique pas le resultat | [M] |
| Liste blanche applicative : cible non declaree 0 connexion, cible declaree 1 connexion (temoin du harnais) | [M] |
| Garde anti-SSRF actif par defaut, applique **apres** resolution de nom | [M] |
| Bac a sable WebAssembly : 3 temoins inverses, dont une boucle interrompue en ~12,7 ms | [M] |
| Aucune installation, aucun paquet emis au premier demarrage ; 32 competences depaquetees du binaire | [M] |
| Telemetrie presente mais en adhesion volontaire, desactivee, 0 enveloppe emise | [M] |
| Charge : ~193 Mo, pic 18 % d'un coeur, plus ~102 Mo de base de donnees | [M] |
| 51 portes d'approbation neutralisees par un reglage global actif a l'installation | [M] |
| 4 fichiers d'identite injectes a chaque tour ; sous profil base, la documentation indique le mauvais emplacement | [M] |
| Aucune voie operateur pour ecrire l'identite : ecriture par l'agent seul, donc ni versionnable ni relisible | [M] |
| Ligne 1.x jeune : premiere version majeure fin juillet, 3 mineures en 23 jours | [M] |
| **Aucun audit de securite independant n'existe** — mention exigee, reprise dans l'article | [M] |

### T5 — comparatif

Aucun fait nouveau. Il croise T2, T3 et T4, plus le tableau croise a trois colonnes de
`chantierI/I-RUN-20260823-005800/RAPPORT_FINAL.md` §5. La **reserve de methode** de ce
meme paragraphe (canaux differents entre les deux POC) est reprise telle quelle dans
l'article, plutot que lissee.

---

---

## D. Backlog post-gel, enregistre et NON execute

Aucune action n'a ete engagee sur ces deux points, conformement a la consigne.

1. **Elargir l'echantillon Lighthouse** de une ou deux URL d'articles recents, pour que le
   seuil mobile porte aussi sur les pages longues. Fichier concerne : `lighthouserc.cjs`.
2. **Integrer les trois visuels** du repertoire de publication a l'article sur la migration
   de modele, sous condition de conversion en webp sous 150 Ko et de chargement differe.

---

- **Directive** : SITE-01 (Mini-ADR-01) · **Exécutant** : Claude Code · **Date** : 2026-08-13
- **Dépôt** : `HKCONSEILS/hkconseils-site` (privé) · **Branche** : `main`
- **Production** : `https://hkconseils.fr` — **en ligne**
- **Amendement** : SITE-01b (souveraineté par couche + FAQ n°6) — appliqué le 14/08
- **État** : livré, déployé, **8 AC sur 8 vérifiés par mesure**. Reliquats : capture
  Editos (cosmétique), Rich Results Test (§5.1), obfuscation d'e-mail à arbitrer (§8.3).

---

## 1. État des critères d'acceptation

| AC | Objet | État | Détail |
|---|---|---|---|
| AC1 | Lighthouse mobile ≥ 95 × 4 | ✅ | **100 / 100 / 100 / 100** sur les trois pages (mobile, 3 runs par page, médiane — §5). Poids hors images : **98,9 Ko** pour une limite de 500 Ko. |
| AC2 | HTML valide, 1 × H1, méta | ✅ | `html-validate` : 3 fichiers, zéro erreur. 1 seul H1 par page, hiérarchie sans saut, `alt` + `width`/`height` sur l'image, `lang="fr"`. Titre **54 car.**, description **155 car.** (limites 60 / 155), canonique, Open Graph et Twitter Card présents. |
| AC3 | JSON-LD | ✅/⏳ | `check-jsonld.py` passe : @graph à **8 nœuds** — ProfessionalService, Person, **5 × Service** dont `#reprise-actifs` (SITE-01d) et Editos (D-site-08 v2, plus aucun Product), FAQPage — et les **7 Q/R** FAQ sont identiques entre le DOM et le balisage. Test des résultats enrichis : à passer sur l'URL de production. |
| AC4 | robots.txt | ✅ | « Managed robots.txt » désactivé : le fichier servi est identique à celui du dépôt (`diff` vide), zéro `Disallow`, zéro `Content-Signal`. Blocage pare-feu levé : **GPTBot, ClaudeBot, PerplexityBot, OAI-SearchBot, Googlebot, Bingbot et Applebot répondent tous 200**, mesuré sur la production. |
| AC5 | Zéro fuite | ✅ | `check-leaks.sh` passe sur les 23 fichiers suivis. **Testé négativement** : les 6 familles de motifs se déclenchent sur un fichier piégé. |
| AC6 | Mentions légales | ✅ | Jeu LCEN + R.123-237 complet : dénomination, forme, **capital 100 €**, siège (6 boulevard Édouard Herriot, 69800 Saint-Priest), SIREN, **RCS de Lyon**, **TVA FR 88 100 332 816** (clé de contrôle recalculée et concordante), directeur de la publication, hébergeur avec adresse, contact. Politique de confidentialité cohérente avec l'absence de cookie et de mesure d'audience. |
| AC7 | HTTPS + www → apex | ✅ | `https://hkconseils.fr` sert le site, certificat valide (Google Trust Services, TLS 1.3), `http://` redirige en 301, aucun contenu mixte. `www` redirige en **301** vers l'apex, chemin **et** chaîne de requête préservés (`/mentions-legales?x=1` vérifié). |
| AC8 | Zéro cookie / tiers / analytics | ✅ | Aucun `Set-Cookie`, aucune requête tierce, aucun outil de mesure, vérifié en production. **Zéro JavaScript** : l'obfuscation d'e-mail de Cloudflare a été désactivée le 14/08 (§8.3), la page servie ne porte plus qu'une seule balise `script`, celle du JSON-LD. |

## 2. Fichiers produits

**Site** — `public/index.html`, `mentions-legales.html`, `confidentialite.html`,
`robots.txt`, `sitemap.xml`, `_redirects`, `css/main.css`,
`fonts/` (2 WOFF2 + 2 licences OFL), `img/` (og-image.png, editos-capture.webp, favicon.svg).

**Qualité** — `scripts/check-leaks.sh`, `scripts/check-jsonld.py`,
`scripts/print-lighthouse-scores.py`, `.github/workflows/validate.yml`,
`.github/workflows/release-gate.yml`, `lighthouserc.json`, `.htmlvalidate.json`.

**Documentation** — `README.md` (déploiement, retour arrière, DNS), ce rapport.

## 3. Conception

Design repris des tokens du design system HK CONSEILS : palette navy / bleu chevron /
gris, unité modulaire de 8 px, rayons et ombres, fonds « dark tech » et « grid
architecture ». Composition alternant surfaces sombres et claires, libellés
techniques en IBM Plex Mono, texte courant en Inter, chevron de marque en filigrane
dans le héros.

Deux écarts assumés par rapport au design system :

1. **`@import` Google Fonts supprimé.** Le design system chargeait Inter et IBM Plex
   Mono depuis Google Fonts, ce qu'interdit le §1. Les deux familles sont sous
   SIL OFL 1.1 : auto-hébergées en WOFF2 (sous-ensemble latin), licences incluses.
   Inter est servie en fonte variable — un seul fichier couvre 400/600/700.
2. **Bleu de marque interdit en texte sur fond sombre.** `#005FFA` sur navy plafonne
   à 3,3:1, sous le seuil AA. Une variante éclaircie (`#6BA6FF`, 6,9:1) sert à tout
   texte et lien posé sur surface sombre ; le bleu canonique reste employé sur fond
   clair et comme aplat décoratif. Sans cet ajustement, l'accessibilité ne tenait pas.

## 4. Écarts par rapport à la directive

| Point | Directive | Livré | Raison |
|---|---|---|---|
| `<title>` | « HK CONSEILS — Conseil en IA générative souveraine pour PME · Lyon » (65 car.) | « HK CONSEILS — IA générative souveraine pour PME · Lyon » (54 car.) | Le titre prescrit au §3.2 dépasse de 5 caractères la limite de 60 fixée par l'AC2. Arbitrage en faveur du critère mesurable ; « conseil » reste en tête de la meta description. **À confirmer.** |
| Meta description | 184 car. | 155 car. | Même conflit §3.2 / AC2. Coupe minimale, tous les termes porteurs conservés. |
| Localité | « basé à Lyon (Auvergne-Rhône-Alpes) » | « basé à Saint-Priest, dans la métropole de Lyon (Auvergne-Rhône-Alpes) » | L'attestation RNE du 13/08/2026 situe le siège à Saint-Priest (69800). Une localité en désaccord avec le code postal dégrade la fiche d'établissement au moment où elle va être créée, et expose un écart avec le registre devant l'instructeur Bpifrance. « Lyon » reste employé comme aire d'intervention (titre, héros, contact). Arbitrage validé par Hémerson. |
| URL des pages légales | `mentions-legales.html` | `/mentions-legales` | Cloudflare Pages retire l'extension `.html` et redirige en 308. Liens internes, canoniques et sitemap alignés sur les URL réellement servies, pour ne pas publier un sitemap intégralement redirigé ni des canoniques pointant des URL inexistantes. |
| Porte de publication | « avertissement qui devient échec si `RELEASE=1` » | même comportement, mais dans un workflow `release-gate` déclenché à la demande | Faire échouer la CI de `main` en permanence à cause d'un placeholder connu détruit le signal, et ne protège rien : Pages déploie sans consulter GitHub Actions. La porte a été jouée dans les deux états — elle refuse avec placeholder, elle passe sans. |

## 5. Résultats des portes

```
check-leaks  : OK — 23 fichiers, aucun motif interdit
               (test négatif : 6/6 familles de motifs déclenchées)
check-jsonld : OK — @graph valide, 7 nœuds, 5 Q/R identiques DOM ↔ balisage
html-validate: OK — 3 fichiers, zéro erreur
release-gate : OK — plus aucun placeholder dans public/
schema.org  : 0 erreur, 0 avertissement sur https://hkconseils.fr/
Rich Results: NON EXÉCUTÉ — voir §5.1

Lighthouse (mobile, médiane des runs — re-mesuré après SITE-01b, 14/08)
                        Perf.  A11y  B.P.  SEO
  /                      100    100   100   100
  /mentions-legales      100    100   100   100
  /confidentialite       100    100   100   100
```

> **Relevé daté du 14/08, conservé tel quel.** Les chiffres du JSON-LD ci-dessus
> (7 nœuds, 5 Q/R) sont ceux de ce jour-là. État courant : **8 nœuds, 7 Q/R** depuis
> SITE-01d — voir §11 ter.

### 5.1 Test des résultats enrichis — exécuté le 14/08

Exécuté par navigateur sur `https://hkconseils.fr/`, exploration Google du
14 août 2026 à 03:05:17, après déploiement de SITE-01c v2.

| Type détecté | Verdict |
|---|---|
| **Organisation** | 1 élément valide, aucun problème |
| **Commerces et services à proximité** | 1 élément valide, 2 problèmes **non critiques** |
| **Extraits de produits** | **1 élément non valide** |
| **FAQPage** | **non listé** par l'outil |

**Extraits de produits, le seul point rouge.** Message de Google sur le nœud
`Editos` : « Il faut indiquer "offers", "review", ou "aggregateRating" ».

C'est un **conflit structurel avec la directive**, pas un défaut d'exécution. Le
§3.3 de SITE-01 impose un nœud `Product` **sans `offers`** (prix sur demande), et la
porte `check-jsonld.py` vérifie précisément cette absence. Or Google exige l'une de
ces trois propriétés pour rendre un `Product` éligible. Les deux exigences sont
incompatibles.

Aucune issue n'est neutre :

- publier `offers` supposerait un prix, qui n'existe pas ;
- publier `review` ou `aggregateRating` supposerait des avis, qui n'existent pas, et
  les inventer serait un faux ;
- changer le type du nœud ferait tomber l'AC3, qui exige « un `Product` ».

**Conséquence réelle : aucune.** Un élément non éligible n'est pas pénalisé, il
n'apparaît simplement pas en résultat enrichi. Le nœud reste du schema.org valide et
continue de servir la compréhension de l'entité, qui est l'objectif GEO. La décision
appartient à la squad : accepter l'inéligibilité et la documenter, ou revoir le §3.3.
**Rien n'a été modifié** — le gel de copie de 48 h (SITE-01c §7) court.

> **Note du 15/08 — analyse dépassée, conservée telle quelle.** La troisième issue
> ci-dessus, « changer le type du nœud ferait tomber l'AC3 », posait l'AC3 comme
> intangible. C'est l'erreur : un critère d'acceptation s'amende. Le ré-arbitrage
> **D-site-08 v2** a retenu la quatrième issue, qui n'avait pas été envisagée — décrire
> Editos en `Service`, type qui ne réclame aucune des trois propriétés. Le conflit
> n'était donc pas structurel, il venait du type choisi. Voir §12, D-site-08 v2.

**Problèmes non critiques sur la fiche d'établissement :**

- `telephone` manquant — **délibéré**, le §6 de SITE-01 interdit de publier le numéro ;
- `priceRange` manquant — pourrait recevoir une valeur du type « Sur devis ». À
  arbitrer après le gel, ce n'est pas une erreur factuelle.

**FAQPage absent de la liste.** L'outil ne le mentionne pas parmi les types détectés,
ce qui confirme que Google ne traite plus les résultats enrichis FAQ pour un site
ordinaire depuis août 2023, cet affichage étant réservé aux sites gouvernementaux et
de santé faisant autorité. Le balisage reste exact et vérifié à 6/6 par la porte ; il
sert la lecture par les moteurs de réponse, pas l'affichage en SERP. Cela ne change
rien à l'objectif de la directive, mais évite d'attendre un encart qui ne viendra pas.

Contrôle de cohérence au passage : les données remontées par Google reflètent bien
SITE-01c v2 — description mentionnant « clouds non européens », `email`
`contact@hkconseils.fr`, adresse de Saint-Priest, `sameAs` LinkedIn et GitHub.

Pour mémoire, les substituts joués avant d'avoir un navigateur restent cohérents avec
ce verdict : validateur schema.org à `totalNumErrors = 0`, JSON-LD servi vérifié nœud
par nœud, `check-jsonld.py` à 6/6.

Au premier passage, un run isolé de la page d'accueil était descendu à 87 en
performance (démarrage à froid du navigateur). C'est pour cela que la configuration
exécute plusieurs runs et retient la médiane, comme `lhci assert` : une mesure
unique n'aurait pas été reproductible. Au passage du 14/08, tous les runs sont à 100.

## 6. Mise en production

| Étape | État |
|---|---|
| Projet Cloudflare Pages `hkconseils-site`, sortie `public`, aucune commande de build | ✅ |
| Intégration Git : un push sur `main` déclenche le déploiement | ✅ vérifié |
| Domaines `hkconseils.fr` et `www.hkconseils.fr` attachés, certificats actifs | ✅ |
| Bascule DNS : les deux `A` vers OVH remplacés par des CNAME proxifiés vers Pages | ✅ |
| Messagerie (MX ×3, SPF, DMARC, DKIM, autodiscover) | intacte, non touchée |

L'origine précédente (`213.186.33.5`, OVH) ne répondait plus : l'apex servait un
HTTP 521 avant la bascule. Aucun service vivant n'a été interrompu.

## 7. Questions ouvertes

1. **Capture Editos** — l'image en ligne est un placeholder neutre de 1280 × 800.
   La capture assainie reste due : jeu d'essai fictif, vue soumission/résultat,
   aucun journal, aucun panneau technique.
2. **Titre raccourci** — arbitrage du §4 à confirmer.
3. **Mentions légales, complétude LCEN** — voir §9.
4. **Search Console et fiche d'établissement Google** — actions Hémerson.

## 8. Réglages Cloudflare — état après correction

Les deux réglages signalés le 13/08 ont été corrigés par Hémerson dans le tableau
de bord, puis **re-vérifiés par mesure, pas sur parole**.

### 8.1 Accès des robots — résolu

`Managed robots.txt` désactivé et `Block AI training bots` levé. Mesure sur la
production, en variant l'en-tête User-Agent :

```
GPTBot         200      OAI-SearchBot  200      Applebot   200
ClaudeBot      200      Googlebot      200      navigateur 200
PerplexityBot  200      Bingbot        200
```

Le `robots.txt` servi est identique à celui du dépôt (`diff` vide) : aucun
`Disallow`, aucun `Content-Signal`. Rappel de l'état antérieur, pour mémoire :
657 réponses 403 sur 669 requêtes de robots en 24 h.

### 8.2 Redirection `www` — résolu

```
https://www.hkconseils.fr/                    301 -> https://hkconseils.fr/
https://www.hkconseils.fr/mentions-legales?x=1 301 -> https://hkconseils.fr/mentions-legales?x=1
```

Chemin et chaîne de requête préservés. L'AC7 est satisfaite.

### 8.3 Obfuscation d'e-mail — résolu le 14/08

L'option *Email Obfuscation* de la zone réécrivait le HTML à la volée : les deux
liens `mailto:` devenaient `/cdn-cgi/l/email-protection#…`, le texte visible
devenait `[email protected]`, et un script `email-decode.min.js` était injecté.

Deux conséquences : le site n'était plus à zéro JavaScript, contrairement au gel du
Mini-ADR-01, et surtout **l'adresse de contact devenait illisible pour qui n'exécute
pas JavaScript** — donc pour GPTBot, ClaudeBot et PerplexityBot, ceux-là mêmes qui
venaient d'être débloqués au pare-feu. Le site n'ayant ni formulaire ni téléphone,
ce `mailto:` est l'unique chemin de conversion.

**Objection examinée.** Hémerson a opposé un argument de zéro-clic : tout donner aux
robots assèche le trafic, faire venir l'utilisateur est stratégique. L'argument est
fondé pour un site de contenu, mais il ne portait pas sur ce levier. L'obfuscation
ne retient aucun contenu : les robots lisaient déjà l'intégralité du pitch, des
références et de la FAQ en HTTP 200. Seule l'adresse leur échappait. Le site perdait
donc la conversion tout en offrant la matière. Par ailleurs la protection était déjà
contournée sur la même page, le JSON-LD portant l'adresse en clair — Cloudflare
n'obfusque pas les données structurées. Coût entier, bénéfice nul. Décision de
désactiver prise par Hémerson après discussion.

**Mesure après bascule** (`email_obfuscation = off`, 14/08) :

```
liens mailto: rétablis            2
liens /cdn-cgi/l/email-protection 0
script email-decode injecté       0
balises <script> dans la page     1   (le seul JSON-LD)
« [email protected] »             0
adresse lisible par GPTBot        4 occurrences
```

Le site est de nouveau strictement sans JavaScript.

## 9. Mentions légales — jeu complet

L'AC6 est satisfaite. Pour mémoire, la LCEN (art. 6-III-1) attend d'un site
professionnel un ensemble un peu plus large. État actuel :

| Mention | État |
|---|---|
| Dénomination sociale, forme juridique | ✅ SASU HK CONSEILS |
| Adresse du siège | ✅ 6 boulevard Edouard Herriot, 69800 Saint-Priest |
| Numéro d'immatriculation | ✅ SIREN 100 332 816 |
| Directeur de la publication | ✅ Hemerson Koffi |
| Hébergeur (dénomination, adresse) | ✅ Cloudflare, Inc. |
| Moyen de contact | ✅ courriel — **le texte cite le téléphone**, écarté par le §6 de la directive |
| Capital social | ✅ 100 euros (Kbis) |
| RCS et ville du greffe | ✅ RCS de Lyon, numéro 100 332 816 (Kbis) |
| Numéro de TVA intracommunautaire | ✅ FR 88 100 332 816 — assujetti confirmé. Clé recalculée `(12 + 3 × (SIREN mod 97)) mod 97 = 88`, concordante |

Capital et RCS ont été ajoutés le 13/08 à partir du Kbis : l'article R.123-237,
auquel renvoie la LCEN, les rend exigibles pour une société commerciale — ma
réserve commerciale initiale sur l'affichage du capital ne tenait pas face à
l'obligation. Reste la TVA, seule question ouverte.

Rien d'autre du Kbis n'est publié. Date et lieu de naissance, nationalité et
domicile personnel du président y figurent, sans aucune raison d'être sur le site.
À noter au passage : le siège social est le domicile personnel du dirigeant. Cette
adresse est déjà publique par le Kbis et le RNE, la publier ne crée donc pas de
divulgation nouvelle — mais autant le savoir.

## 10. Passe de rédaction du 14/08 — tics de rédaction

Signalement d'Hémerson : le site « sonne IA ». Relevé objectif sur le corps de page
avant intervention :

```
souverain / souveraine   9      « cas d'usage »           5
auto-hébergé*            6      tirets cadratins          8
« en production »        3      tournures « … : a, b, c » 13
```

Le marqueur dominant n'était pas le vocabulaire mais **le rythme** : treize
paragraphes bâtis sur « affirmation : énumération de trois éléments », dans une page
qui en compte une vingtaine.

### 10.1 Premier passage — redondances (7 corrections)

Ce passage n'a **pas** touché la ponctuation, ce qui était le défaut principal :
tirets cadratins 8 avant, 8 après. Ce qui a été corrigé :

1. suppression d'un paragraphe de remplissage sous « Trois interventions » ;
2. le H2 de la section R&D répétait mot pour mot l'ouverture de son propre
   paragraphe → titre ramené à « OpenClaw » ;
3-6. quatre surtitres qui redisaient leur H2, supprimés puis **rétablis avec des
   libellés porteurs d'information** (Infrastructure, À propos, FAQ, Contact) pour
   préserver l'homogénéité visuelle des sections ;
7. suppression de « vous recevrez une réponse argumentée, pas une plaquette ».
   Outre la tournure « X, pas Y », cette phrase **inventait un engagement de
   service** absent de la directive, laquelle interdit d'ajouter tout élément qui
   n'y figure pas. C'était le plus grave des sept.

### 10.2 Second passage — ponctuation (13 corrections)

Inventaire des tirets cadratins et de leur origine :

| Emplacement | Nombre | Origine |
|---|---|---|
| Héros, « Chaque recommandation — modèle, GPU, dimensionnement — » | 2 | directive §3.2 |
| Editos, « Pipeline hybride — … — avec charte » | 2 | rédaction Claude Code |
| FAQ RGPD | 2 | directive |
| FAQ équipe technique | 1 | directive |
| Contact, « Lyon — toute la France » | 1 | directive |
| Mentions légales | 3 | rédaction Claude Code |
| Confidentialité | 2 | rédaction Claude Code |

Sept sur treize venaient de moi. Les six autres ont été corrigés également : le §3.2
de SITE-01 autorise explicitement « polish typography/microcopy freely », sous la
seule réserve de ne pas ajouter de fait. Aucun fait n'a été modifié.

**Résultat mesuré sur la page servie** : zéro tiret cadratin dans le corps
rédactionnel, hors les deux de la FAQ n°6 (voir §11.4) et les séparateurs de
`<title>`, qui relèvent de l'usage typographique courant.

### 10.3 Troisième passage — humanisation complète (14/08)

Demande d'Hémerson : supprimer tous les tirets cadratins et toute autre marque de
rédaction automatique, « le texte le plus humanisé possible ». Passe menée à
**faits constants**.

| Marqueur | Avant | Après |
|---|---|---|
| Tirets cadratins (corps) | 13 | **0** |
| Tirets cadratins (`title`, `og:image:alt`) | 6 | **0** |
| Tournures « affirmation : a, b, c » | 13 | **0** |
| « cas d'usage » | 4 | 1 |

La tournure à deux-points était le marqueur dominant, pas la ponctuation : treize
paragraphes bâtis sur le même moule dans une page qui en compte une vingtaine. Le
style nominal des cartes d'offre (« État des lieux des cas d'usage… ») a été
remplacé par des phrases à verbe conjugué. Longueur des phrases après passe :
médiane 16 mots, écart-type 10 — le rythme est irrégulier, ce qu'il n'était pas.

**Contrôle des faits.** Chaque chiffre du dossier a été recompté après réécriture :
1 485, 100/100, ~120/h, 1 750, 51 → 94, 16 000 $, 48 Go, 19,9 Go, 24 Go, 11 modèles,
45 métriques, 27-35 milliards, 4 GPU, 16 ans, et toutes les dates. Deux formulations
diluaient un chiffre et ont été corrigées : « treize agents » est redevenu
« 13 agents », et « inférence entièrement locale » est redevenue « inférence 100 %
locale ». Un moteur de réponse extrait mieux un chiffre qu'un mot.

**Écart assumé sur les `title`.** SITE-01b §4 gelait le titre de la page. La demande
d'Hémerson portait sur *tous* les tirets cadratins, y compris celui du séparateur.
Seul le glyphe change, remplacé par le point médian déjà employé ailleurs sur le
site : aucun mot modifié, longueur inchangée à 54 caractères, sous la limite de 60.
Les deux pages légales ont reçu le même traitement.

**Vérification en production.** Premier relevé trompeur : un edge Cloudflare servait
encore une copie périmée, mêlant nouveau corps et ancien titre. Mesure reprise avec
contournement de cache sur trois requêtes : titre au point médian, zéro tiret
cadratin dans le corps, une seule occurrence de « : » sur toute la page. CI verte,
Lighthouse toujours à 100 sur les quatre axes.

## 11. SITE-01b — souveraineté par couche + FAQ n°6 (14/08)

### 11.1 E1 — copie

| Élément | Avant | Après |
|---|---|---|
| H1 | « …sans dépendre du cloud américain » | « …sans confier vos données au cloud américain » |
| Meta description | 155 car. | **148 car.** (voir 11.2) |
| `og:image:alt` | ancienne formulation | alignée |

### 11.2 Écart assumé sur la meta description

La formulation fournie au §1.2 fait **162 caractères**, au-dessus de la limite de 155
de l'AC2, et **ne contient pas « souveraine »** — que ce même §1.2 demande pourtant
de ne pas perdre. Le §1.2 autorisant un ajustement à la marge, cinq variantes ont été
mesurées et la retenue fait 148 caractères en conservant « Lyon » **et**
« souveraine » :

> Conseil en IA souveraine à Lyon : diagnostic, LLM auto-hébergés (RAG, image,
> vidéo), formation. Vos données ne quittent jamais votre infrastructure.

Termes perdus par rapport à la proposition : « Cabinet de » et « déploiement de ».

### 11.3 §1.3 — balayage de cohérence

```
grep -ri "sans dépendre\|sans dépendance" public/   →   0 occurrence
```

Une occurrence non textuelle a été trouvée hors du champ du grep : **l'image Open
Graph affichait l'ancienne accroche en dur**. Non corrigée, la carte sociale aurait
montré « sans dépendre du cloud américain » alors que son propre attribut `alt`
annonçait la nouvelle formule. L'image a été régénérée.

### 11.4 E2 — FAQ n°6

Ajoutée en 6e position, DOM et JSON-LD, texte verbatim. `check-jsonld.py` valide
6/6 paires identiques.

**Point signalé** : la réponse approuvée verbatim s'ouvre sur « Non — la souveraineté
se raisonne… ». Elle réintroduit donc un tiret cadratin dans un corps de page qui
venait d'en être purgé à la demande d'Hémerson. Le verbatim demandé par SITE-01b a
primé ; la substitution du tiret par un point est une modification d'un caractère,
disponible sur simple accord.

### 11.5 Validation

```
check-jsonld  : OK — 7 nœuds, 6 Q/R identiques DOM ↔ balisage
check-leaks   : OK — aucun motif introduit
html-validate : OK — zéro erreur, une seule H1
CI            : verte sur les 3 jobs
```

Vérifications publiques (résolution forcée) : nouveau H1 servi, description à
148 caractères, FAQ n°6 présente dans le HTML initial (6 blocs `<details>`, aucun
JavaScript), `sans dépendre` à zéro occurrence, GPTBot toujours en 200.

### 11.6 Rich Results Test — toujours dû

Le §3.6 demande de le passer après ce déploiement. **Il n'a pas pu être exécuté** :
l'outil de Google n'a pas d'API publique et n'existe qu'en interface web, or la
machine de travail n'a pas de navigateur. Ce qui a été fait à la place est décrit au
§5.1 — validateur schema.org à 0 erreur et 0 avertissement, JSON-LD servi vérifié
nœud par nœud. Le test reste à passer par Hémerson depuis un navigateur, sur
`https://hkconseils.fr`, en vérifiant que `FAQPage` remonte bien **6** questions.

## 11 ter. SITE-01d — nommer la reprise d'applications (15/08)

La prestation la plus différenciante du cabinet n'existait qu'implicitement, dans
l'étude de cas santé. Un lecteur venu faire reprendre son application ne pouvait pas
deviner que c'était une offre. SITE-01d la nomme, sans casser le rythme des trois
interventions : le compteur reste `01/02/03`.

### Ce qui a changé

| Élément | Nature |
|---|---|
| Carte d'offre n°2 | titre élargi en « Déploiement & reprise d'applications IA souveraines », texte remplacé. Cartes 1 et 3 intactes |
| Bande `#reprise-actifs` | nouveau bloc pleine largeur entre l'offre et les références. Trois phrases, **aucun chiffre nouveau, aucun nom de client**, ancre interne vers l'étude de cas santé |
| Ancre `#cas-sante` | ajoutée sur l'article de l'étude de cas santé, qui n'en portait pas |
| FAQ n°7 | « Pouvez-vous reprendre une application développée par un autre prestataire ? », DOM et balisage identiques |
| JSON-LD | nœud `Service` `#reprise-actifs` ajouté ; le graphe passe de 7 à **8 nœuds**, 5 `Service` |

**Aucun style nouveau.** La bande reprend `.sunken`, déjà dans les tokens. Aucun tiret
cadratin : contrôlé sur la copie servie, décompte à 0.

### Une mise en cohérence non demandée, signalée

Le nœud `#service-deploiement` reprenait **mot pour mot** le texte de la carte 2. La
directive ne demandait que l'ajout du nouveau nœud. Le laisser tel quel aurait fait
décrire au graphe une offre que la page ne proposait plus : `name` et `description`
ont donc été réalignés sur le nouveau texte. Signalé plutôt qu'enfoui — c'est une
initiative, pas une consigne.

### Porte AC3 mise à jour

`Service` 4 → **5**, socle FAQ 6 → **7**, et la vérification nommée par `@id`
généralisée : `#editos` et `#reprise-actifs` sont contrôlés chacun sur son `@type` et
ses propriétés requises, au lieu d'être simplement comptés. Le compte seul laisserait
passer cinq `Service` quelconques.

**Tests négatifs rejoués**, sur copie hors dépôt :

```
cas 1 — nœud #reprise-actifs supprimé
  ABORT: JSON-LD non conforme
    - nœud Service : 4 trouvé(s), 5 attendu(s)
    - nœud Reprise d'actifs (#reprise-actifs) absent du @graph
  code = 1

cas 2 — 7e question retirée du DOM seulement
  ABORT: JSON-LD non conforme
    - FAQ : 6 paire(s) dans le DOM contre 7 dans le balisage
  code = 1
```

### Cohérences périphériques (§6 de la directive)

Meta description, `og:title`, `og:description` et `og:image:alt` **ne citaient pas**
l'ancien titre de la carte 2 : elles décrivent les offres en termes génériques, et
l'alt de l'image OG porte le H1. Vérifié par grep avant de conclure ; **rien à
modifier**, image OG non régénérée. Blog et pages légales intouchés.

Reste à la main d'Hémerson, hors dépôt : si la fiche Google Business Profile est créée
avec la description proposée par la squad, y remplacer « déploiement d'IA souveraine
on-premise ou sur cloud européen » par « déploiement et reprise d'applications IA
souveraines ».

### Validation

| Contrôle | Résultat |
|---|---|
| Portes locales | `check-jsonld.py` OK (8 nœuds, 7 Q/R), `check-leaks.sh` OK (45 fichiers) |
| CI `validate`, run 31898940192 | **success**, 4 jobs sur 4 |
| Lighthouse mobile | **100 / 100 / 100 / 100**, médiane de 6 runs, sur toutes les pages |
| Recette servie, 3 User-Agents dont Googlebot | 8 nœuds, 5 `Service`, 0 `Product`, FAQ 7 balisage / 7 DOM, carte 2 au nouveau titre, bande présente, ancre `#cas-sante` présente des deux côtés, 0 tiret cadratin, 0 nom de client |

Commit **`a33f415`**, poussé le jour même.

## 11 quater. SITE-01e — zone d'intervention élargie à l'espace francophone (15/08)

Le site s'arrêtait aux frontières françaises. La règle retenue sépare ce que lit un
humain de ce que lit une machine : **prose courte dans le visible, exhaustivité dans le
balisage**. Ni « monde entier », ni liste de pays dans la copie.

### Ce qui a changé

| Élément | Nature |
|---|---|
| Ligne de zone, section Contact | « Lyon et toute la France » → « Basé à Lyon. Interventions sur site dans toute la France, à distance dans l'espace francophone : Europe, Canada, Afrique francophone. » |
| Paragraphe À-propos | « les PME et TPE **françaises** » → « les PME et TPE **des pays francophones** ». Reste de la phrase inchangé |
| `areaServed` du `ProfessionalService` | objet unique `France` → **tableau de 31 `Country`** |
| `areaServed` des 4 nœuds `Service` | **retiré** : ils héritent par `provider` |

**Le nombre de nœuds ne bouge pas (8)** : `areaServed` est une propriété, pas un nœud.
`#editos` est inchangé, il n'en portait pas.

### La seule interprétation que j'ai eu à faire, et son motif

La directive dit que les `Service` « héritent par `provider` — ne pas dupliquer
`areaServed` sur chacun ». Or les quatre en portaient déjà un, à `France`. Deux
lectures : ne pas y recopier les 31, ou ne pas leur en laisser du tout.

**J'ai retenu la seconde.** Laisser `France` aurait fait dire au graphe que le cabinet
sert 31 pays mais que chacune de ses prestations s'arrête à la France, en contradiction
directe avec la phrase écrite juste au-dessus dans la même livraison. Une zone dupliquée
est aussi une zone qui se désynchronise au prochain élargissement.

C'est une interprétation, pas une consigne littérale. Elle se renverse en restaurant
quatre lignes.

### Porte

`areaServed` : compte à **31**, type `Country` sur chaque entrée, absence de doublon, et
**deux pays en sonde d'échantillon** (France, Sénégal). La porte **n'énumère pas** les
31 : recopier la donnée qu'elle vérifie reviendrait à contrôler que le fichier est égal
à lui-même.

**Trois tests négatifs**, sur copie hors dépôt :

```
cas 1 — areaServed retiré
    - ProfessionalService : propriété 'areaServed' manquante          code = 1
cas 2 — un pays de moins (30)
    - areaServed : 30 entrée(s), 31 attendues
    - areaServed : « Sénégal » absent (sonde d'échantillon)           code = 1
cas 3 — retour à un objet unique
    - areaServed : dict, tableau de Country attendu                   code = 1
```

Le compte de 31 annoncé par la directive a été **recalculé depuis sa propre liste**
avant d'être posé dans la porte (6 + 25, aucun doublon). Une porte calée sur un chiffre
faux échoue sur du contenu correct.

### Cohérences périphériques (§4)

FAQ inchangée (7/7). **Aucune métadonnée ne disait « toute la France »** : ni `<title>`,
ni description, ni Open Graph, ni Twitter Card. Vérifié par grep, rien aligné. Zéro
tiret cadratin. Conventions d'apostrophe respectées par contexte, leçon SITE-01d §5.

Reste à la main d'Hémerson, hors dépôt : description Google Business Profile, dernière
phrase « Interventions dans toute la France. » → « Interventions dans toute la France
et, à distance, dans l'espace francophone. » La **zone desservie GBP reste la France**,
l'outil sert le référencement local français.

### Une occurrence non traitée, signalée

Le bandeau du héros porte toujours « Interventions dans toute la France ». Le §1 de la
directive impose deux retouches **exactement** et interdit toute autre modification de
copie : elle n'a donc pas été touchée. L'affirmation reste vraie — les interventions sur
site couvrent bien toute la France — mais elle est désormais **incomplète** au regard de
la ligne de contact. À arbitrer, hors de cette livraison.

### Validation

| Contrôle | Résultat |
|---|---|
| Portes locales | `check-jsonld.py` OK (8 nœuds, 7 Q/R), `check-leaks.sh` OK |
| CI `validate`, run 31900821906 | **success**, 4 jobs sur 4 |
| Lighthouse mobile | **100 / 100 / 100 / 100**, médiane de 6 runs |
| Recette servie, 4 User-Agents dont Googlebot | 8 nœuds, 5 `Service`, 0 `Product`, `areaServed` à 31 pays, **0 `Service` portant `areaServed`**, les deux retouches présentes, FAQ 7/7, 0 tiret cadratin, 0 « monde entier », aucun pays énuméré dans le visible hors la phrase prescrite |

Commit **`8cce0a8`**, poussé le jour même.

## 11 quinquies. Retouches arbitrées après SITE-01e (15/08)

Deux points laissés ouverts par les livraisons précédentes, tranchés par Hémerson et
déployés **d'un seul tenant**.

### Bandeau du héros

« Interventions dans toute la France » → **« Interventions en France et dans l'espace
francophone »**.

SITE-01e imposait deux retouches exactement et interdisait toute autre modification de
copie : le bandeau était donc resté en l'état, signalé au §11 quater. L'affirmation
était vraie mais incomplète, et c'était la première chose que lisait un visiteur,
au-dessus de la ligne de flottaison. Plus aucune occurrence de « Interventions dans
toute la France » dans la page.

### Bande « reprise d'actifs » — `.sunken` → `.on-dark`

Le rendu n'avait pas pu être vérifié à la livraison de SITE-01d, faute de navigateur ;
la réserve avait été portée au §9 de son rapport. Le défaut était structurel et
prévisible à la lecture : **la bande et la section Références qui la suit étaient toutes
deux `.sunken`**, donc collées sur un même fond creusé. La bande se lisait comme le
début de Références plutôt que comme un bloc à elle.

`.on-dark` lui rend son autonomie. **Toujours aucun style nouveau** : la classe est déjà
dans les tokens, et le lien de la bande hérite automatiquement de `--color-accent-on-dark`,
la variante de bleu éclaircie créée parce que le bleu canonique plafonne à 3,3:1 sur
navy (§3).

**Le point à surveiller était le contraste** : Lighthouse le mesure, **accessibilité à
100** après déploiement. Le fond sombre apparaît désormais trois fois dans la page
(`#reprise-actifs`, `#rd`, `#contact`) ; c'est un choix de rythme, arbitré.

### Validation

| Contrôle | Résultat |
|---|---|
| Portes locales | `check-jsonld.py` OK (8 nœuds, 7 Q/R), `check-leaks.sh` OK |
| CI `validate`, run 31902345202 | **success**, 4 jobs sur 4 |
| Lighthouse mobile | **100 / 100 / 100 / 100**, médiane de 6 runs |
| Recette servie, 4 User-Agents dont Googlebot | bandeau au nouveau texte, **0** occurrence résiduelle, bande en `on-dark` et plus en `sunken`, ancre `#cas-sante` présente des deux côtés, 8 nœuds, 5 `Service`, 0 `Product`, `areaServed` 31, FAQ 7/7, 0 tiret cadratin |

Commit **`6d3df64`**, poussé le jour même. Les deux retouches sont de la copie et du
gabarit : le retour arrière est un `git revert` sans effet de bord.

## 12. Decisions Log

| Réf. | Décision | Date | Portée |
|---|---|---|---|
| ~~**D-site-08**~~ | ~~**Inéligibilité du nœud `Product` assumée.** Le test des résultats enrichis juge `Editos` non valide faute de `offers`, `review` ou `aggregateRating`. Aucune des trois n'est publiable : le prix n'existe pas, les avis non plus, et les inventer serait un faux ; changer le type du nœud casserait l'AC3. Le nœud remplit son objectif réel — l'entité Editos existe dans le graphe et reste valide au sens schema.org. L'encart en SERP n'a jamais été la cible. **Ne rien modifier.**~~ ⛔ **ANNULÉE ET REMPLACÉE par D-site-08 v2 le 15/08.** La décision reposait sur une prémisse fausse : « changer le type du nœud casserait l'AC3 ». C'est l'AC3 qui s'amende. Prémisse levée, la conclusion s'inverse. | 14/08 | **caduque** |
| **D-site-08 v2** | **Editos décrit en `Service`, plus en `Product`.** `Product` est un type à résultat enrichi : il réclame `offers`, `review` et `aggregateRating` parce qu'il décrit ce qui se vend, s'évalue et se note. Editos n'est rien de cela — application interne, sans prix public ni avis. L'erreur signalée n'était donc pas un défaut à assumer, **c'était le symptôme d'un type mal choisi**. `Service` n'appelle aucune des trois : l'élément non valide disparaît définitivement du rapport **sans qu'aucune donnée soit inventée**, et l'entité reste comprise du graphe. Le nœud garde `@id`, `name`, `description` et `image` ; `brand` devient `provider`, qui désigne le même `ProfessionalService`. AC3 amendé en conséquence (quatre `Service`, aucun `Product`) ; la porte `check-jsonld.py` rejette désormais tout `Product`, vérifie Editos par son `@id` et refuse un `brand` survivant — régressions prouvées par test négatif. Livré en `b149ab6`, CI verte, recette servie verte. Détail : `~/siteweb/directives/AMENDEMENT-SITE-01-AC3-D-site-08-v2-2026-08-15.md`. | 15/08 | JSON-LD, en vigueur |
| **D-site-09** | **`priceRange: "Sur devis"` accepté** sur le nœud `ProfessionalService`, en réponse à l'avertissement non critique de la fiche d'établissement. C'est une donnée factuelle, pas une invention. **À appliquer après le gel**, dans le lot post-gel, pas avant. | 14/08 | JSON-LD, différé |
| **D-site-10** | **Amendement de D2 : la porte anti-fuite distingue désormais deux familles.** Les **identifiants** — IP, hostnames internes, VMID contextuels, noms de clients — restent bloqués partout, vitrine comme blog. Les **noms de produits ou technologies publiques** — Proxmox, ZFS, RTX, EPYC, LXC — restent bloqués sur la vitrine, qui parle en capacités agrégées par choix éditorial, et deviennent **autorisés dans les sources du blog** : « nous utilisons Proxmox » est un argument de compétence, pas une fuite. Implémentation par chemin, preuve par test négatif sur les deux périmètres. | 14/08 | `check-leaks.sh`, branche `blog-01` |
| **D-site-11** | **Cadrage projet.** Le site et le blog sont les actifs permanents de la SASU. Le dépôt Bpifrance du 11/09 est un jalon du calendrier, pas la finalité. Le gel du 28/08 au 11/09 est une fenêtre de prudence recommandée, levable sur GO explicite si une livraison est propre et recettée. **Les priorités s'arbitrent par valeur commerciale, pas par urgence administrative** — plus aucune justification « parce que BPI » dans les rapports, chaque décision se motive par sa valeur propre. | 14/08 | doctrine, permanent |
| **D-site-14** | **Zone d'intervention = France sur site, espace francophone à distance.** Règle de forme : **prose courte et humaine dans le visible, exhaustivité dans le JSON-LD `areaServed`** (31 pays : socle Europe + Canada, plus Afrique francophone et Maghreb). **« Monde entier » est proscrit**, ainsi que toute énumération de pays dans la copie — sauf la formule courte approuvée « Europe, Canada, Afrique francophone ». `areaServed` vit sur le seul `ProfessionalService` : les `Service` d'offre héritent par `provider` et n'en portent plus, une zone dupliquée étant une zone qui se désynchronise. La porte contrôle le compte, le type et deux pays en sonde, sans réénumérer la liste. | 15/08 | JSON-LD + copie, en vigueur |
| D-site-03 | Numéro de téléphone non publié. Délibéré, documenté, clos. Explique l'avertissement `telephone` manquant de la fiche d'établissement. | 13/08 | rappel |

Sur le `FAQPage` non listé par l'outil : confirmé sans regret. La cible du balisage
FAQ est la lecture par les moteurs de réponse, pas l'encart SERP que Google a retiré
aux sites ordinaires. La porte à 6/6 garde tout son sens.

## 12 bis. Incidents

### INC-2026-08-14 — Dépôt `HemersonAIBuild` public pendant un an

| | |
|---|---|
| **Exposé** | Cartographie de l'infrastructure : 44 adresses distinctes, 10 hôtes nommés, identifiants de conteneurs. **Noms de clients**, dont un présent dans 25 fichiers. |
| **Non exposé** | **Aucun secret.** Audit gitleaks 8.30.1 sur l'historique complet, 147 commits et 4 références, plus recherches ciblées sur cinq familles de clés. Les cinq versions des fichiers de coffre Ansible présentes dans l'historique sont chiffrées, vérifié. |
| **Confinement** | Dépôt passé en privé le 14/08. Absence d'accès anonyme vérifiée : 404 sur la page comme sur l'API. |
| **Résiduel accepté** | Ce qui a été lu ne peut pas être repris. 0 étoile, 0 fork : l'exposition reste théorique, aucune exploitation constatée. Accepté et daté. |
| **Détection** | Par la porte pré-lien du §4.1 de l'amendement BLOG-01-A, qui impose d'auditer un dépôt cible avant de le lier depuis un article. |
| **Suites** | Republication d'une version vitrine assainie, sans historique, dans un nouveau dépôt — backlog post-gel. **Les noms de branches entrent dans le périmètre d'assainissement : l'une contient un nom de projet client.** |

Ce que l'incident dit du dispositif : la porte qui l'a trouvé n'avait pas été écrite
pour ça. Elle demandait de vérifier une cible avant de poser un lien, et c'est en
l'appliquant qu'une exposition sans rapport avec le blog est apparue. Une règle de
contenu a servi de contrôle de sécurité, un an après le fait.

Rien dans les portes du site ne pouvait le détecter : elles ne regardent que ce dépôt.
Un contrôle périodique des dépôts publics du compte serait le complément manquant.

## 13. Gel de copie et lot post-gel

**Gel actif jusqu'au 16/08 au matin.** Aucune modification de `public/` d'ici là, y
compris `priceRange`. Seule une erreur factuelle avérée lèverait le gel.

Cette section et le §12 sont les seules écritures faites pendant le gel, sur
instruction explicite de la squad (point 3 de sa note du 14/08). Elles ne portent que
sur la documentation : `git diff` confirme qu'aucun fichier de `public/` n'est touché.

**Lot post-gel**, à exécuter en une seule passe, sur GO explicite d'Hémerson après sa
relecture à froid :

1. `priceRange: "Sur devis"` sur le nœud `ProfessionalService` (D-site-09), puis
   `check-jsonld.py` et recette sur la page servie ;
2. les corrections issues de la relecture à froid, groupées ;
3. le remplacement du placeholder par la capture Editos si elle est fournie d'ici là
   (WebP, dimensions du placeholder inchangées, `alt` inchangé).

À l'issue de ce lot, plus aucune tâche côté exécutant. Search Console, sitemap et
fiche Google Business Profile sont des actions Hémerson, hors dépôt.

## 14. Statut

**SITE-01, SITE-01b et SITE-01c v2 : DONE.** 8 critères d'acceptation sur 8, tous
vérifiés par la mesure. Un reliquat visuel, la capture Editos, et un lot post-gel
unique.

Le retour d'expérience du §10 — recette sur la page servie, avec variation des
User-Agents — est adopté comme doctrine squad pour les futurs SITE-xx.

---

# BLOG-02 — Cinq articles de fond, et la provenance rendue facultative

**Date** : 2026-08-20. **Branche** : `blog-02-cinq-articles`, sur `50a40d7`.
**Entrée hors des trois actées, ouverte par un GO explicite d'Hémerson.**

## 1. Ce qui entre

| Article | Sujet | Mots |
|---|---|---:|
| `haute-disponibilite-proxmox-sans-cluster` | HA par couches, sans corosync | 2 742 |
| `agent-ia-operations-infrastructure-protocole` | protocole d'exécution d'un agent IA | 2 503 |
| `migrer-llm-production-on-premise-cinq-minutes` | bascule d'un LLM de production | 3 058 |
| `modules-ia-application-sante-deploiement` | deux modules IA chez un client santé | 2 545 |
| `editos-defauts-silencieux-pipeline-ia` | trois défauts silencieux d'un pipeline IA | 1 940 |

Écrits pour ce blog, à partir des rapports d'exécution réels. Chaque chiffre cité a été
confronté à son rapport d'origine ; trois affirmations non étayées ont été corrigées
avant rédaction (une accroche fausse, un rollback annoncé « testé » alors qu'il n'était
que préparé, une comparaison de débits entre deux profondeurs différentes).

## 2. Décision D-blog-01 — `originalDate` devient facultative

Le schéma imposait `originalDate`, et le gabarit en faisait la phrase « Publié
initialement sur LinkedIn le [date] ». Cette phrase est **fausse** pour un article né
ici : c'est le teaser qui part ensuite sur LinkedIn, dans l'autre sens.

Le champ passe donc en `.optional()`, et le bloc de provenance n'est rendu que s'il
existe. Il reste obligatoire de fait pour les articles rapatriés, et le commentaire du
schéma a été réécrit pour dire pourquoi la règle d'origine reste vraie pour eux.

La chronologie descend **dans le corps de l'article**, en clair, sur les cinq. Cela
permet de publier en octobre un retour d'expérience de juin sans forcer sa date de
publication ni mentir sur sa provenance.

**Contrôle de disparition, sur le HTML produit et non sur le code** : la phrase est
absente des cinq nouveaux et **présente** sur les trois rapatriés. Le correctif ne
devait pas seulement la supprimer là où elle est fausse, il devait la laisser là où
elle est vraie.

## 3. Ce qu'un essai préalable a rattrapé

L'ensemble a d'abord été monté sur une **copie** du dépôt. `html-validate` y a fait
échouer **quatre articles sur cinq** : `title text cannot be longer than 70 characters`.
Cause : le gabarit accole « · HK CONSEILS », soit 14 caractères, au titre du
frontmatter. Le budget réel est de **56**, et rien ne le signalait avant la CI.

Titres raccourcis, slugs et URL inchangés. Second passage : zéro erreur.

La règle est désormais dans la porte de rédaction locale, avec son budget calculé, pour
que le prochain article ne la redécouvre pas en CI.

## 4. Contrôles rejoués avant commit

`npm run build` (9 pages, 8 articles) · `check-leaks.sh` (50 fichiers) ·
`check-jsonld.py` (8 nœuds, 7 Q/R) · non-régression `public/` → `dist/` (14 fichiers à
l'octet) · zéro JavaScript émis · une seule H1 par page · RSS et sitemap bien formés ·
`html-validate` vitrine et blog.

**Non rejouable ici** : le job Lighthouse, qui exige un navigateur sur la machine
d'exécution. À lire au run.

## 5. Deux points laissés ouverts, à l'attention du décideur

**Une `pubDate` future ne diffère pas la publication.** Seul `draft` filtre, dans
l'index, le flux et le sitemap. Fusionner cette branche publie donc les cinq articles
d'un coup, quelles que soient les dates portées. L'échelonnement doit se faire côté
LinkedIn, où les teasers partent après.

**L'article sur le client santé** ne le nomme pas, la porte du dépôt l'interdisant.
Il décrit toutefois le domaine avec assez de précision pour être reconnaissable par
quelqu'un du secteur. Arbitrage non rendu.

---
---

# REPORT — BLOG-VAGUE-2 · Production nocturne du 25 au 26/08/2026

> ## Circuit de merge, à lire avant tout
>
> **Aucun merge n'a ete fait vers `main`, et aucun ne doit l'etre par l'executant.**
> L'ordre est : **B1 d'abord (`blog-02-cinq-articles`), B2 ensuite (`blog-03-vague-2`)**,
> par Hemerson seul, apres relecture, **avant le 27/08 au soir**. Passe cette date, le
> gel pre-depot BPI du 28/08 au 11/09 s'applique et la fenetre est fermee jusqu'au 11/09.
> B2 contient B1 : verifie par `git merge-base --is-ancestor`.

- **Directive** : `siteweb/directives/DIRECTIVE-BLOG-VAGUE-2-20260825.md` (remplace et annule la directive D1-D2 du meme jour, jamais deposee sur disque)
- **Executant** : Claude Code, mode nuit autonome
- **Branches** : **B1** `blog-02-cinq-articles` @ `670e8b3` · **B2** `blog-03-vague-2`
- **Base** : `main` @ `50a40d7`, inchangee

---

## 1. Statut par tache

| Tache | Livrable | Statut | Mots | pubDate |
|---|---|---|---|---|
| **B1** | re-datage de `editos-defauts-silencieux-pipeline-ia.md` 27/08 -> 26/08 | ✅ | — | 2026-08-26 |
| **T1** | `facture-electronique-septembre-2026.md` | ✅ **publie** | 1 261 | 2026-08-27 |
| **T2** | `openclaw-plateforme-multi-agents-lecons.md` | ✅ **publie** | 1 338 | 2026-08-24 |
| **T3** | `hermes-poc-agent-ce-qui-nest-pas-annonce.md` | ✅ **publie** | 1 280 | 2026-08-24 |
| **T4** | `ironclaw-secret-absent-pas-refuse.md` | ✅ **publie** | 1 537 | 2026-08-24 |
| **T5** | `agents-ia-on-premise-trois-architectures.md` (pilier) | ✅ **publie** | 1 353 | 2026-08-27 |
| **T6** | 5 teasers LinkedIn, `siteweb/articles/publications/md/linkedin/teaser-{E,F,G,H,I}-*.md` | ✅ | 456 a 496 | hors depot |

**Gate factuelle T3/T4 : franchie largement.** Le seuil etait de 800 mots et 5 faits
opposables. Les deux POC ont produit des rapports d'execution complets, avec seuils ecrits
avant mesure : 9 criteres mesures pour T3, 11 pour T4. Aucun article n'est reste en
brouillon, le comparatif T5 est donc dans sa version pleine et non degradee.

**Total de la nuit : 6 774 mots publiables, 2 328 mots de teasers.**
Le blog passe de 8 a **13 articles publies** ; les 6 brouillons homelab sont intacts.

Ordre effectif de l'index apres build (tri decroissant sur `pubDate`) : le pilier arrive
en tete, l'article e-facture en deuxieme.

---

## 2. Statut par gate

| Gate | Objet | Resultat |
|---|---|---|
| **G1a** | `scripts/check-leaks.sh` sur B2 (fichiers suivis) | ✅ **rc=0** — `OK — 55 fichiers analyses, dont 14 soumis a la famille « produits » ; aucun motif interdit` |
| **G1b** | familles d'identite appliquees a la main aux 10 nouveaux fichiers hors depot | ✅ **10 familles a 0**, 1 exception assumee (§4, decision D1) |
| **G1c** | `GATE-articles.sh` (porte de redaction hors depot) | ✅ **rc=0 apres l'arbitrage du 25/08** (decision D11). Sortait auparavant en rc=1 sur le seul motif `nom d'application non arbitre`. La porte a ete verifiee mordante apres amendement : 6 temoins positifs, 6 fois rc=1 |
| **G2** | absence de « Editeos » et du chiffre interdit | ✅ **0 sur 56 fichiers suivis + 0 sur 20 fichiers hors depot**, temoin inverse a 1 sur les deux motifs |
| **G3** | build Astro | ✅ **rc=0** — `14 page(s) built`, dont 13 articles + l'index. Attendu 13, constate 13 |
| **G3a** | `check-jsonld.py` | ✅ `@graph valide, 8 noeuds, 7 Q/R FAQ identiques entre le DOM et le balisage` |
| **G3b** | non-regression `public/` -> `dist/` | ✅ **14 fichiers identiques a l'octet** |
| **G3c** | aucun JavaScript emis | ✅ **0 fichier `.js`** dans `dist/` |
| **G3d** | une seule H1 par page | ✅ 14 pages, une H1 chacune |
| **G3e** | RSS et sitemap bien formes | ✅ les deux parses sans erreur |
| **G4a** | `html-validate` vitrine (regles strictes) et blog | ✅ **rc=0** sur les deux perimetres |
| **G4b** | titres <= 56 caracteres, **comptes** | ✅ **0 titre hors budget sur 19**. Le plus long des nouveaux : 53 (e-facture). Marge la plus faible du depot : 55 sur un article deja publie |
| **G5** | liens internes resolus sur le build local | ✅ **12 liens inter-articles, 0 casse**, temoin inverse (cible inexistante) bien detecte |
| **G6** | `pubDate` <= 2026-08-27, re-datage, doublons | ✅ sur les deux premiers points, **doublons declares volontaires** (§4, decision D6) |
| **Lighthouse** | seuil mobile >= 95 | ⛔ **non rejouable ici**, aucun navigateur sur la machine. A lire au run |

### Le detail de G1c, avant et apres arbitrage

**Avant.** La porte sortait en echec sur trois lignes, et une seule famille :

```
ABORT: nom d'application non arbitre
    blog/agents-ia-on-premise-trois-architectures.md:14
    blog/openclaw-plateforme-multi-agents-lecons.md:2
    blog/openclaw-plateforme-multi-agents-lecons.md:14
GATE: ECHEC.   >>> code retour = 1
```

**Apres**, l'arbitrage du 25/08 ayant retire ce seul motif de la famille (decision D11,
qui porte les deux preuves exigees) :

```
GATE: OK — 10 articles + 10 teasers analyses ; identite et conventions verifiees.
>>> code retour = 0
```

Les trois occurrences sont **toujours dans les fichiers** : c'est la porte qui a change
d'avis, pas le contenu qui a ete edulcore. Et la porte a ete re-eprouvee mordante,
famille par famille, avant d'etre declaree verte.

### Risque Lighthouse, enonce

Cinq pages s'ajoutent, plus longues que la moyenne. Aucune n'introduit d'image, de script
ni de ressource externe : le controle « ressource chargee depuis un domaine externe » est a
zero, et `dist/` ne contient aucun `.js`. Les causes habituelles de chute sont donc
ecartees, mais le score reel ne sera connu qu'au run.

---

## 3. Faits utilises, par article

Remontes en tete de fichier, section **C** du dossier de relecture.

## 4. Balayages de matiere, et preuve de couverture

Methode reprise de `AUDIT-BLOG-01.md` §6 : liste de fichiers construite d'abord, comptee,
puis interrogee ; et un temoin positif avant toute conclusion sur une absence.

| Motif | Fichiers touches, hors outillage | Verdict |
|---|---|---|
| runtime Rust evalue | 33 | matiere abondante, **T4 ecrit** |
| agent Python evalue | 57 | matiere abondante, **T3 ecrit** |
| plateforme interne | 195 | matiere abondante, **T2 ecrit** |
| registre d'annonces legales | **4**, dont la directive elle-meme et une trace de session | **matiere insuffisante, fait abandonne** |

**Chemins retenus.** T3 : `chantierH/H-RUN-20260822-211451/` (rapport final, rapport des
phases 1 a 4, decisions). T4 : `chantierI/I-RUN-20260823-005800/` (rapport final, rapports
de phase, runbook d'identite). T2 : `infra-backup-new/openclaw/` (plan directeur, rapports)
et `chantierG/G-RUN-20260822-132924/` (note d'enforcement).

**Preuve de couverture.** Le balayage etroit, sur six extensions de texte, a d'abord rendu
**zero** sur le registre d'annonces legales. Ce zero etait **faux** : un balayage elargi a
toutes les extensions a trouve deux fichiers de flux d'automatisation en `.json`. Le
temoin positif du meme balayage elargi renvoyait 51 fichiers sur un motif connu present,
ce qui prouve que l'outil voyait. **C'est l'elargissement, pas le temoin, qui a corrige
l'erreur** : un temoin positif prouve que le harnais fonctionne, il ne prouve pas que le
perimetre est le bon.

Les deux fichiers trouves datent d'aout 2025, interrogent une API publique differente de
celle annoncee et deposent dans un tableur en ligne. **Aucun journal d'execution, aucun
comptage, aucune date de run.** Le chiffre de 7 000 entreprises par departement n'est
donc etaye par rien sur cette machine : il n'est pas publie, et il ne figure pas non plus
sous une forme attenuee.

---

## 5. Liens externes proposes

Remontes en tete de fichier, section **B** du dossier de relecture.

## 6. Decisions autonomes

Detaillees, avec l'alternative ecartee, dans `Decisions.md` a la racine du depot.
Resume : neuf decisions, dont une seule change ce qui sera publiquement visible (D1, le
nom de la plateforme interne et son slug d'URL).

---

## 7. Questions for squad

1. ~~**Nommer la plateforme interne, oui ou non — et jusque dans l'URL ?**~~ **TRANCHE le
   25/08 par la revue** : c'est le nom public de la plateforme, sa publication etait deja
   actee, le slug `/blog/openclaw-plateforme-multi-agents-lecons/` est valide, et la porte
   de redaction a ete amendee en consequence. Voir `Decisions.md` D11. La recette de
   retrait de D1 devient sans objet, elle est conservee a titre d'historique.
2. **Le decompte des agents du pipeline.** Deux enumerations coexistent dans le plan
   directeur et **ne se reconcilient pas** : l'une annonce treize agents mais en detaille
   quatorze, l'autre decrit quatre analystes la ou la premiere en compte cinq. Aucun code
   source n'est present sur cette machine pour trancher. **Aucun decompte n'a donc ete
   publie**, seule la structure l'a ete. Une enumeration faisant autorite serait utile.
3. **Le registre d'annonces legales.** Le fait fourni est sans source verifiable ici
   (§4). Fournir un journal de run, ou retirer le fait de l'argumentaire.
4. **Le comparatif d'embeddings.** Aucun rapport de banc n'existe sur cette machine : la
   seule trace est la dimension du modele en service. Aucune comparaison n'a ete publiee,
   pas meme qualitative, faute de pouvoir la sourcer.
5. **Lighthouse.** Non rejouable ici. A lire au run avant merge.
6. **Trois visuels en reliquat**, inchange depuis le rapport du 20/08 : ils ne sont pas
   integres (§ decision D5).
7. **Reste ouvert depuis le 20/08** : l'article sur les modules IA en sante decrit son
   domaine avec assez de precision pour etre reconnaissable dans le secteur, sans nommer
   le client. Arbitrage toujours non rendu, et il porte sur B1, donc sur le premier merge.

---
---

# REPORT — RETOUCHE-PILIER-01 et R1 a R4 (25/08/2026, seconde passe)

- **Branche** : B2 `blog-03-vague-2` uniquement. `main` et B1 intactes.
- **Commits** : `f1aec21` nommage, `474b557` schemas et echantillon Lighthouse, `f0fd64c` tableau defilable.

## 1. R1 — nommage du pilier

Les trois plateformes sont nommees dans les trois intitules de la section Positions et
dans les en-tetes de colonnes du tableau : **OpenClaw**, **Hermes**, **IronClaw**. Les deux
articles de POC portent leur nom des la premiere phrase du contexte en italique.

### La case « secrets accessibles par un detour en ligne de commande » n'etait pas etayee

Verification faite dans le rapport de POC. Ce qui a ete **mesure**, c'est l'acces au
**terminal** : sur la question suivant un refus hors perimetre, l'agent a execute une
commande et rapporte sa sortie. La **lecture du secret n'a jamais ete tentee**.
L'affirmation venait en fait du rapport de l'autre POC, qui l'enonce comme point de
comparaison — une deduction defendable (le fichier est en 0600 au nom du compte sous lequel
l'agent tourne), mais une deduction.

Deux consequences, appliquees :
- la case passe a **« non mesure »** ;
- une ligne **« terminal accessible a l'agent »** est ajoutee, qui porte le fait
  reellement mesure. Sans elle, le tableau aurait perdu une information de confinement
  vraie au lieu d'en perdre une fausse.

Aucune prose de l'article ni du pilier n'affirmait cet acces : le changement est
auto-coherent, verifie par recherche avant edition.

## 2. R2 — cinq schemas, aucune capture

| Article | Schema | Poids |
|---|---|---|
| e-facture | frise 2026 / 2027 separant **recevoir** et **emettre**, puis le circuit entreprise, plateforme agreee, annuaire, destinataire | 5,2 Ko |
| OpenClaw | les sept phases, P0 et P1 pleines, les cinq autres en creux, monetisation en quatrieme position | 5,6 Ko |
| Hermes | les deux environnements cote a cote, puis la barre 102 s contre 4,9 s | 3,6 Ko |
| IronClaw | les trois couches emboitees, et le temoin du harnais 0 / 0 / 1 | 4,8 Ko |
| pilier | matrice confinement x gouvernance | 4,4 Ko |

Contraintes tenues : SVG en ligne, **aucune police ni ressource externe**, palette et
typographie prises aux variables du site **avec valeur de repli**, texte reel dans le SVG,
`role="img"` et `aria-label` descriptif, `figcaption`, largeur fluide par `viewBox`.
Plafond de 60 Ko : le plus lourd fait 5,6 Ko.

**Chaque chiffre porte par un schema a ete verifie present dans le corps**, en excluant le
schema lui-meme du texte fouille — sinon le controle se serait auto-valide. Neuf
assertions, neuf conformes.

**Le pilier n'affirme pas ce qui n'a pas ete mesure.** OpenClaw n'ayant pas ete passe au
meme banc, il ne pouvait pas recevoir d'abscisse de confinement : il est represente par un
**marqueur creux pose sur une bande en pointilles**, avec une legende qui dit « axe non
mesure, aucune position affirmee ». Hermes et IronClaw sont des points pleins.

**Un piege rencontre** : une ligne vide a l'interieur d'un bloc `<figure>` fait sortir
Markdown du mode HTML brut et reinjecte un `<p>` au milieu du SVG. `html-validate` l'a
attrape (`Stray end tag </p>`). Les cinq blocs sont desormais sans ligne vide, et le
controle est pose.

## 3. R3 — l'echantillon Lighthouse couvre enfin les pages nouvelles

**Pourquoi il ne les couvrait pas.** Le commentaire de `lighthouserc.cjs` annoncait « les
deux articles les plus recents ». C'etait faux : le tri porte sur le **nom du repertoire**,
donc sur le slug, par ordre alphabetique decroissant. La date de publication n'intervenait
nulle part, l'echantillon retenait toujours les deux memes articles, et **aucune page
nouvelle n'avait jamais ete mesuree par ce job**.

Correctif : tri stable conserve, intitule corrige, et une liste d'articles **exiges**
ajoutee, avec un avertissement si l'un d'eux manque au build — eprouve par temoin inverse
sur un slug inexistant.

**Resultat mesure** : de six a **onze URL**, et **100 / 100 / 100 / 100** sur chacune des
cinq pages nouvelles, mediane de trois passages. Cout : le job passe de ~4 min a 7 min 14.

## 4. Un defaut reel, trouve en mesurant plutot qu'en regardant

Une capture semblait montrer la derniere colonne du tableau du pilier coupee. Mesure faite
avant de conclure : `scrollWidth` egal a `clientWidth`, `scrollX` a zero, aucun
debordement. **C'etait un artefact de capture.**

En revanche, en contraignant le conteneur d'article a 390 px, le debordement etait reel :
largeur minimale de **399 px** de contenu plus les marges internes, soit environ **447 px**
pour 390 disponibles. Colonnes dimensionnantes : « Cloisonnement » a 113 px et
« WebAssembly, » a 110 px.

Balayage sur **les douze articles construits** : **onze tableaux tiennent** dans 390 px,
**un seul deborde**, celui du comparatif. Le defaut est donc specifique a cet article et
non au gabarit.

Correctif : ce seul tableau est encadre d'un conteneur a defilement horizontal, **dans cet
article uniquement**. Le gabarit partage n'est pas touche et les onze autres tableaux ne
changent pas.

## 5. R4 — non livrable en l'etat, et pourquoi

Trois obstacles constates, pas supposes.

1. **Le redimensionnement de fenetre n'agit pas sur le viewport.** Le rendu reste a 1465 px
   quelle que soit la taille demandee. Une tentative a 414 px a fige le moteur de rendu et
   deux captures ont expire. Une capture a 390 px n'est donc pas productible par cette
   voie, et « 1440 » vaudrait en realite 1465.
2. **L'ecriture sur disque n'aboutit pas ici.** L'option de sauvegarde ne cree aucun
   fichier sur cette machine, verifie : les captures vivent cote extension, sur une autre
   machine. Elles ne peuvent pas etre deposees dans un repertoire de travail local.
3. **C'est un navigateur personnel.** Un onglet dedie a ete cree puis referme, et la
   fenetre remise a 1440x900.

**Ce qui a ete produit a la place**, et qui repond mieux a la question posee : une **mesure**
du comportement a 390 px et a 1440 px sur les douze articles, rapportee au paragraphe 4.

## 6. R2 amende — captures de POC : non livrables

- **Condition (1), remplie** : les deux environnements existent toujours, les deux services
  tournent. Verifie.
- **Condition (2), bloquante** : les hotes de POC sont **sans affichage**, et le seul moyen
  de capture disponible est un navigateur sur une autre machine. Un « terminal plein
  ecran » n'est pas productible. L'interface web de l'un des deux n'ecoute que sur la
  boucle locale : l'atteindre supposerait de l'exposer, donc de modifier l'infrastructure
  et de casser la contrainte de securite du POC lui-meme. L'autre a ete eprouve sur une
  messagerie personnelle, ce qui echoue d'emblee sur « aucune barre personnelle ».
- **Condition (3)** : sans capture, l'inventaire de texte visible est sans objet.

**Alternative proposee, non appliquee** : un extrait de terminal **reel, rejoue et colle en
bloc de code**. C'est du texte, donc integralement relisible par la revue anti-fuite, ce que
la condition (3) cherche precisement a obtenir. Elle modifierait le corps des articles :
elle attend un accord.

---
---

# REPORT — AERATION (25/08/2026, troisieme passe)

- **Branche** : B2 `blog-03-vague-2` uniquement. **Commit** : `a28361f`.
- **Origine** : question de la revue sur les captures d'ecran. Elles restent non livrables
  (section « R4 » et decisions D15 et D16). Ce qui suit est ce qui a ete fait a la place.

## 1. Le constat qui a declenche la passe

Les cinq articles de la vague n'avaient **ni bloc de code ni citation en exergue**, la ou
les trois articles deja publies en comptent de un a quatre. Ce n'etait pas un defaut de
fond, c'etait un ecart de rythme avec le reste du blog : des blocs de prose de 1 300 a
1 500 mots coupes par un seul schema.

| | schemas | tableaux | blocs de code | exergues |
|---|---|---|---|---|
| Les 5 articles, avant cette passe | 1 chacun | 0 a 1 | **0** | **0** |
| REX incident GPU (deja publie) | 0 | 0 | 4 | 1 |
| REX migration (deja publie) | 0 | 1 | 2 | 1 |
| Qwen-AgentWorld (deja publie) | 0 | 1 | 0 | 1 |

## 2. Etat apres la passe

| Article | Schemas | Blocs de code | Exergue |
|---|---|---|---|
| e-facture | 1 | 0 | 1 |
| OpenClaw | 1 | 0 | 1 |
| Hermes | 1 | **2** | 1 |
| IronClaw | **2** | **2** | 1 |
| pilier | **2** | 0 | 1 |

## 3. Les extraits de terminal sont reels, et assainis

**Rejoues** sur les deux machines de POC, qui tournent toujours — pas reconstitues de
memoire, pas recopies d'un rapport. Commandes en **lecture seule**, bornees par `timeout`
cote machine cible.

| Extrait | Ce qu'il montre | Fait deja present dans l'article |
|---|---|---|
| Hermes, configuration | les **trois** reglages qui ferment la creation de competences, dont deux non documentes | oui |
| Hermes, inventaire | `0` entree dans le repertoire des competences, et un repertoire que le compte de service ne peut pas ecrire | oui |
| IronClaw, secrets | droits `640`, proprietaire, **8 noms** de variables definis, lisible par le compte hors du produit | oui |
| IronClaw, competences | **32** competences et **32** marqueurs de depaquetage, donc aucune arrivee par le reseau | oui |

**Ce qui n'est jamais affiche** : aucune valeur de secret. Uniquement les droits, le
proprietaire et le **nombre** de noms definis. Les chemins reels sont remplaces par une
designation entre chevrons.

### Controle anti-fuite sur les blocs de code

Applique aux **dix** blocs de code du blog, cinq familles, avec temoin inverse.

| Famille | Occurrences |
|---|---|
| adresse IP privee | **0** |
| nom d'hote interne | **0** |
| sous-domaine interne ou nom de client | **0** |
| identifiant de VM ou de conteneur | **0** |
| chaine ressemblant a une valeur de secret | **0** |

Temoin inverse : une ligne piegee portant une adresse privee, un nom d'hote, un
identifiant de conteneur et un sous-domaine est bien detectee. Les zeros sont donc mesures.

## 4. Les exergues portent une idee, elles ne repetent pas une phrase

C'etait le risque de l'exercice : une citation qui recopie le corps ajoute du bruit et
donne au lecteur l'impression de relire. Les cinq formulent une regle que le paragraphe
precedent a demontree sans l'enoncer.

| Article | Idee portee |
|---|---|
| e-facture | etre conforme et ne rien y gagner : la date decide de la conformite, ce qu'on branche derriere decide du benefice |
| OpenClaw | une absence de trace n'est pas une preuve d'absence de violation |
| Hermes | une consigne n'est pas un controle : ce qui doit etre garanti sort du texte et entre dans le code |
| IronClaw | l'intention derive, l'action ne suit pas, et c'est tout l'interet de separer les deux |
| pilier | un controle vaut par ce qu'il exerce, pas par ce qu'il affiche |

## 5. Deux schemas de plus

- **IronClaw** : les **trois issues** du test des secrets — l'agent lit, l'agent refuse
  poliment mais le secret reste joignable, ou le secret n'est pas la — et pourquoi seule la
  troisieme resiste a une invite bien tournee. L'article posait ce critere avant la mesure,
  il ne le montrait pas.
- **Pilier** : **les quatre formes de la meme panne silencieuse**, en trois colonnes, ce qui
  arrive, ce que le systeme montre, ce qui est vrai. Second visuel partageable du lot.

**Sept schemas au total**, de 3,6 a 5,6 Ko, plafond unitaire de 60 Ko. Toujours aucune
image, aucune police, aucune ressource externe.

## 6. Gates

Toutes rejouees avant push et vertes : porte de redaction hors depot (10 articles,
10 teasers), `check-leaks.sh` (56 fichiers), build Astro (14 pages), `check-jsonld.py`,
non-regression `public/` vers `dist/` (14 fichiers a l'octet), zero JavaScript, une seule
H1 par page, RSS et sitemap bien formes, `html-validate` sur les deux perimetres, titres a
55 caracteres au maximum pour un budget de 56, 12 liens internes sans casse.

**Un piege deja rencontre, reverifie** : une ligne vide dans un bloc `<figure>` fait sortir
Markdown du mode HTML brut et reinjecte un `<p>` au milieu du SVG. Le controle est pose sur
les sept schemas, resultat zero.

**CI — ligne fermee.** Le run de `a28361f` est **vert** sur les quatre jobs, Lighthouse
compris : **11 URL, 100 en performance, 100 en accessibilite, 100 en bonnes pratiques,
100 en SEO**, mediane de trois passages. Les sept schemas, les quatre blocs de code et les
cinq exergues ne coutent donc rien au budget.

Le signe annonce est au rendez-vous : l'artefact `dist` passe de **226 016 o** a
**229 143 o**, soit **3 127 octets** de plus. C'est bien du contenu servi qui a change,
contrairement aux commits de rapport qui laissaient cette taille identique a l'octet.
Le run suivant, `b7db79e`, qui ne porte que ce rapport, ressort a **229 143 o** : inchange,
comme attendu.
