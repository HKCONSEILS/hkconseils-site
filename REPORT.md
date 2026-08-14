# REPORT — SITE-01 · Site vitrine HK CONSEILS

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
| AC3 | JSON-LD | ✅/⏳ | `check-jsonld.py` passe : @graph à 7 nœuds — ProfessionalService, Person, 3 × Service, Product, FAQPage — et les 5 Q/R FAQ sont identiques entre le DOM et le balisage. Test des résultats enrichis : à passer sur l'URL de production. |
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

## 12. Decisions Log

| Réf. | Décision | Date | Portée |
|---|---|---|---|
| **D-site-08** | **Inéligibilité du nœud `Product` assumée.** Le test des résultats enrichis juge `Editos` non valide faute de `offers`, `review` ou `aggregateRating`. Aucune des trois n'est publiable : le prix n'existe pas, les avis non plus, et les inventer serait un faux ; changer le type du nœud casserait l'AC3. Le nœud remplit son objectif réel — l'entité Editos existe dans le graphe et reste valide au sens schema.org. L'encart en SERP n'a jamais été la cible. **Ne rien modifier.** | 14/08 | JSON-LD, définitif |
| **D-site-09** | **`priceRange: "Sur devis"` accepté** sur le nœud `ProfessionalService`, en réponse à l'avertissement non critique de la fiche d'établissement. C'est une donnée factuelle, pas une invention. **À appliquer après le gel**, dans le lot post-gel, pas avant. | 14/08 | JSON-LD, différé |
| **D-site-10** | **Amendement de D2 : la porte anti-fuite distingue désormais deux familles.** Les **identifiants** — IP, hostnames internes, VMID contextuels, noms de clients — restent bloqués partout, vitrine comme blog. Les **noms de produits ou technologies publiques** — Proxmox, ZFS, RTX, EPYC, LXC — restent bloqués sur la vitrine, qui parle en capacités agrégées par choix éditorial, et deviennent **autorisés dans les sources du blog** : « nous utilisons Proxmox » est un argument de compétence, pas une fuite. Implémentation par chemin, preuve par test négatif sur les deux périmètres. | 14/08 | `check-leaks.sh`, branche `blog-01` |
| **D-site-11** | **Cadrage projet.** Le site et le blog sont les actifs permanents de la SASU. Le dépôt Bpifrance du 11/09 est un jalon du calendrier, pas la finalité. Le gel du 28/08 au 11/09 est une fenêtre de prudence recommandée, levable sur GO explicite si une livraison est propre et recettée. **Les priorités s'arbitrent par valeur commerciale, pas par urgence administrative** — plus aucune justification « parce que BPI » dans les rapports, chaque décision se motive par sa valeur propre. | 14/08 | doctrine, permanent |
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
