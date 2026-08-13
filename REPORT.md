# REPORT — SITE-01 · Site vitrine HK CONSEILS

- **Directive** : SITE-01 (Mini-ADR-01) · **Exécutant** : Claude Code · **Date** : 2026-08-13
- **Dépôt** : `HKCONSEILS/hkconseils-site` (privé) · **Branche** : `main`
- **Production** : `https://hkconseils.fr` — **en ligne**
- **État** : livré et déployé. **Deux réglages Cloudflare restent à faire côté
  tableau de bord** (§8), dont un qui annule l'objectif GEO tant qu'il tient.

---

## 1. État des critères d'acceptation

| AC | Objet | État | Détail |
|---|---|---|---|
| AC1 | Lighthouse mobile ≥ 95 × 4 | ✅ | **100 / 100 / 100 / 100** sur les trois pages (mobile, 3 runs par page, médiane — §5). Poids hors images : **98,9 Ko** pour une limite de 500 Ko. |
| AC2 | HTML valide, 1 × H1, méta | ✅ | `html-validate` : 3 fichiers, zéro erreur. 1 seul H1 par page, hiérarchie sans saut, `alt` + `width`/`height` sur l'image, `lang="fr"`. Titre **54 car.**, description **155 car.** (limites 60 / 155), canonique, Open Graph et Twitter Card présents. |
| AC3 | JSON-LD | ✅/⏳ | `check-jsonld.py` passe : @graph à 7 nœuds — ProfessionalService, Person, 3 × Service, Product, FAQPage — et les 5 Q/R FAQ sont identiques entre le DOM et le balisage. Test des résultats enrichis : à passer sur l'URL de production. |
| AC4 | robots.txt | ⛔ | Le fichier du dépôt est conforme, **mais Cloudflare préfixe un « Managed robots.txt » qui interdit GPTBot, ClaudeBot, Google-Extended, CCBot, Bytespider, Amazonbot, Applebot-Extended et meta-externalagent**, et pose `Content-Signal: ai-train=no`. Voir §8.1. |
| AC5 | Zéro fuite | ✅ | `check-leaks.sh` passe sur les 23 fichiers suivis. **Testé négativement** : les 6 familles de motifs se déclenchent sur un fichier piégé. |
| AC6 | Mentions légales | ✅ | SASU HK CONSEILS, SIREN 100 332 816, siège réel (6 boulevard Edouard Herriot, 69800 Saint-Priest), directeur de la publication Hemerson Koffi, hébergeur Cloudflare Inc. avec adresse, politique de confidentialité cohérente avec l'absence de cookie et de mesure d'audience. |
| AC7 | HTTPS + www → apex | ⚠️ | `https://hkconseils.fr` sert le site, certificat valide (Google Trust Services, TLS 1.3), `http://` redirige en 301 vers `https://`, aucun contenu mixte. **Mais `www` répond 200 au lieu de rediriger** — §8.2. La balise canonique consolide vers l'apex, ce qui limite le préjudice sans satisfaire le critère. |
| AC8 | Zéro cookie / tiers / analytics | ✅ | Vérifié sur le site en production : aucun `Set-Cookie`, aucun script, aucune ressource externe. Polices auto-hébergées. Une porte automatisée refuse toute ressource chargée depuis un domaine tiers. |

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
Rich Results : à passer sur l'URL de production

Lighthouse (mobile, médiane de 3 runs par page)
                        Perf.  A11y  B.P.  SEO
  /                      100    100   100   100
  /mentions-legales      100    100   100   100
  /confidentialite       100    100   100   100
```

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

## 8. Deux actions hors de portée du jeton d'API

Les deux demandent le tableau de bord Cloudflare, ou un jeton portant
`Zone → Bot Management` et `Zone → Config Rules`. Le jeton utilisé répond
`request is not authorized` sur les deux.

### 8.1 Désactiver le « Managed robots.txt » — prioritaire

Cloudflare préfixe au `robots.txt` du site un bloc managé qui **interdit
explicitement les robots des moteurs de réponse** :

```
User-agent: *
Content-Signal: search=yes,ai-train=no,use=reference
...
User-agent: ClaudeBot
Disallow: /
User-agent: GPTBot
Disallow: /
User-agent: Google-Extended
Disallow: /
(idem CCBot, Bytespider, Amazonbot, Applebot-Extended, meta-externalagent)
```

C'est l'exact contraire de l'objectif GEO de la directive. En théorie, la RFC 9309
impose de fusionner les groupes portant le même agent et, à longueur de chemin
égale, de faire primer `Allow` — le bloc `Allow: /` du dépôt, placé ensuite,
devrait donc l'emporter chez un robot conforme. Mais tous ne fusionnent pas les
groupes, certains retiennent le premier qui correspond, et le
`Content-Signal: ai-train=no` reste une réserve de droits expresse au titre de
l'article 4 de la directive 2019/790. Faire reposer la proposition de valeur du
cabinet sur une subtilité d'interprétation n'est pas acceptable.

**Chemin** : tableau de bord Cloudflare → zone `hkconseils.fr` → *AI Crawl Control*
(anciennement *AI Audit*, sous *Security*) → désactiver *Managed robots.txt*.

```bash
curl -s https://hkconseils.fr/robots.txt | head -5
```

Attendu ensuite : le fichier commence par `User-agent: *` et ne contient plus
aucun `Disallow`.

### 8.2 Rediriger `www` vers l'apex en 301

`public/_redirects` ne peut pas le faire : ses règles portent sur les chemins, pas
sur les noms d'hôte, et `www.hkconseils.fr` est attaché au même projet Pages — il
sert donc le site en 200.

**Chemin** : tableau de bord → zone → *Rules* → *Redirect Rules* → *Create rule*
(une *Single Redirect*, incluse dans l'offre gratuite) :

- Si `Hostname` égal `www.hkconseils.fr`
- Alors redirection dynamique vers `concat("https://hkconseils.fr", http.request.uri.path)`
- Code **301**, conserver la chaîne de requête

```bash
curl -sI https://www.hkconseils.fr/ | head -2
```

Attendu : `301` puis `location: https://hkconseils.fr/`.

## 9. Mentions légales — ce qui est exigible et ce qui manque

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
| Capital social | ❌ absent — 100 EUR selon le RNE |
| RCS et ville du greffe | ❌ absent — le RNE ne mentionne pas le greffe, à prendre sur le Kbis |
| Numéro de TVA intracommunautaire | ❌ absent — à ajouter seulement si assujetti |

Aucun de ces manques n'est bloquant pour la mise en ligne. Trois décisions
attendent Hémerson : afficher ou non le capital social (100 €, signal commercial
faible pour un bénéfice légal nul à ce stade), fournir la ville du greffe, et
indiquer s'il y a un numéro de TVA à publier.
