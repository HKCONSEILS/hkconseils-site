# REPORT — SITE-01 · Site vitrine HK CONSEILS

- **Directive** : SITE-01 (Mini-ADR-01) · **Exécutant** : Claude Code · **Date** : 2026-08-13
- **Dépôt** : `HKCONSEILS/hkconseils-site` (privé) · **Branche** : `main`
- **Production** : `https://hkconseils.fr` — **en ligne**
- **État** : livré, déployé, **8 AC sur 8 vérifiés par mesure**. Un reliquat
  cosmétique (capture Editos) et une anomalie nouvelle à arbitrer (§8.3).

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
| AC8 | Zéro cookie / tiers / analytics | ✅ ⚠️ | Aucun `Set-Cookie`, aucune requête tierce, aucun outil de mesure — vérifié en production. Le dépôt ne contient aucun script. **Mais Cloudflare injecte un script d'obfuscation d'e-mail dans la page servie** : même origine, non analytique, donc le critère tient à la lettre — mais l'objectif « zéro JS » du Mini-ADR-01 n'est plus respecté à l'arrivée. Voir §8.3. |

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

Lighthouse (mobile, médiane de 3 runs par page)
                        Perf.  A11y  B.P.  SEO
  /                      100    100   100   100
  /mentions-legales      100    100   100   100
  /confidentialite       100    100   100   100
```

### 5.1 Sur le test des résultats enrichis

Le Rich Results Test de Google n'expose **aucune API publique** — l'endpoint
`urlTestingTools/richResults:run` répond 404, et l'outil n'existe que dans une
interface web. Sans navigateur sur la machine de travail, **je ne peux pas
l'exécuter**, et je ne le déclarerai pas passé sur la foi d'un substitut.

Ce qui a pu être vérifié à sa place, et qui l'a été :

- le **validateur schema.org** (`validator.schema.org`, appelé sur l'URL de
  production) : `totalNumErrors = 0`, `totalNumWarnings = 0` ;
- le **JSON-LD tel que servi** : JSON valide, `@graph` complet avec ses 7 nœuds
  — `ProfessionalService`, `Person`, 3 × `Service`, `Product`, `FAQPage` — et
  l'adresse électronique intacte ;
- `check-jsonld.py` : nœuds requis présents, propriétés minimales présentes, et
  les 5 Q/R de la FAQ strictement identiques entre le DOM et le balisage.

Une réserve de méthode : le validateur schema.org ne restitue que 5 objets dans
sa vue synthétique (`numObjects = 5`), sans `ProfessionalService` ni `Person`. Le
contrôle direct du JSON-LD servi montre que les deux nœuds sont bien présents et
valides — c'est une limite d'affichage du validateur sur les nœuds référencés par
`@id`, pas un défaut du balisage. **Le passage au Rich Results Test reste dû**,
depuis un navigateur, et son verdict devra être consigné ici.

Un run isolé de la page d'accueil est descendu à 87 en performance (démarrage à
froid du navigateur), les deux autres à 100. C'est pour cela que la configuration
exécute 3 runs et retient la médiane, comme `lhci assert` : une mesure unique
n'aurait pas été reproductible.

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

### 8.3 Anomalie nouvelle — obfuscation d'e-mail Cloudflare

Constatée en inspectant la page **telle que servie**, et non le dépôt.

L'option *Email Obfuscation* de la zone (`email_obfuscation = on`) réécrit le HTML
à la volée :

- les deux liens `mailto:` — bouton du héros et bloc contact — deviennent
  `href="/cdn-cgi/l/email-protection#4b232e262e39…"` ;
- le texte visible de l'adresse est remplacé par `[email protected]` ;
- un script est injecté dans la page :
  `<script src="/cdn-cgi/scripts/…/email-decode.min.js">`.

Conséquences :

1. **Le site n'est plus à zéro JavaScript.** Le Mini-ADR-01 gelait « pas de build,
   pas de framework, zéro JS ou ≤ 2 Ko ». Le dépôt respecte la contrainte ; la page
   servie non. Le script est de même origine et n'est pas analytique, donc l'AC8
   tient à la lettre — mais l'intention est perdue.
2. **L'adresse de contact disparaît pour qui n'exécute pas JavaScript**, ce qui est
   le cas de la plupart des robots de moteurs de réponse. Sur les 3 occurrences de
   l'adresse dans la page servie, **une seule reste en clair : celle du JSON-LD**.
   Le seul chemin de conversion du site est ce `mailto:` — on vient d'ouvrir la porte
   aux robots et l'adresse leur est masquée dans le corps de page.

**Arbitrage à rendre** — l'obfuscation existe pour limiter la récolte d'adresses par
les robots à spam. La désactiver rend l'adresse lisible par tous, moissonneurs
compris. Le compromis n'appartient pas au site :

- **Option A — désactiver** (recommandée) : `email_obfuscation = off`. Le `mailto:`
  redevient un lien HTML ordinaire, la page repasse à zéro JavaScript, l'adresse
  redevient lisible par les moteurs de réponse. Coût : davantage de spam.
- **Option B — conserver** : accepter que le corps de page masque l'adresse et
  s'appuyer sur le JSON-LD, où elle reste en clair. Coût : un script injecté et un
  chemin de conversion dégradé pour les agents sans JS.

Le jeton d'API porte la permission nécessaire (`email_obfuscation`, `editable: true`).
**Rien n'a été modifié** : le réglage attend l'arbitrage.

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
