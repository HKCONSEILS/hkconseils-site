# REPORT — SITE-01 · Site vitrine HK CONSEILS

- **Directive** : SITE-01 (Mini-ADR-01) · **Exécutant** : Claude Code · **Date** : 2026-08-13
- **Dépôt** : `HKCONSEILS/hkconseils-site` (privé) · **Branche** : `main`
- **État** : build livré, **non déployé**. Deux placeholders bloquent la mise en ligne.

---

## 1. État des critères d'acceptation

| AC | Objet | État | Détail |
|---|---|---|---|
| AC1 | Lighthouse mobile ≥ 95 × 4 | ⏳ | Seuils armés dans `lighthouserc.json`, exécution en CI. Non mesurable localement (Node.js et Chrome absents de la machine de travail). Poids hors images : **98,9 Ko** pour une limite de 500 Ko. |
| AC2 | HTML valide, 1 × H1, méta | ✅/⏳ | Structure vérifiée : 1 seul H1 par page, hiérarchie sans saut, `alt` + `width`/`height` sur l'image, `lang="fr"`. Titre **54 car.**, description **155 car.** (limites 60 / 155). `html-validate` s'exécute en CI. |
| AC3 | JSON-LD | ✅/⏳ | `scripts/check-jsonld.py` passe : @graph à 7 nœuds — ProfessionalService, Person, 3 × Service, Product, FAQPage — et **les 5 Q/R FAQ sont identiques entre le DOM et le balisage**. Validation finale par le test des résultats enrichis : à faire après mise en ligne. |
| AC4 | robots.txt | ✅ | GPTBot, PerplexityBot, ClaudeBot, Claude-Web, Google-Extended et `*` explicitement autorisés ; `Sitemap:` pointe le sitemap déployé, qui liste les 3 pages. |
| AC5 | Zéro fuite | ✅ | `scripts/check-leaks.sh` passe sur les 16 fichiers suivis. **Testé négativement** : les 6 familles de motifs se déclenchent bien sur un fichier piégé. |
| AC6 | Mentions légales | ⚠️ | SASU, SIREN 100 332 816, directeur de la publication, hébergeur (avec adresse) et politique de confidentialité sans cookie : présents. **Siège social = `{{ADRESSE_SIEGE}}`, non fourni.** |
| AC7 | HTTPS + www → apex | ⏳ | `public/_redirects` en place. Bascule DNS à faire après le premier déploiement. |
| AC8 | Zéro cookie / tiers / analytics | ✅ | Aucun script, aucun cookie, aucune ressource externe. Polices auto-hébergées. Une porte automatisée refuse désormais toute ressource chargée depuis un domaine tiers. |

## 2. Fichiers produits

**Site** — `public/index.html`, `mentions-legales.html`, `confidentialite.html`,
`robots.txt`, `sitemap.xml`, `_redirects`, `css/main.css`,
`fonts/` (2 WOFF2 + 2 licences OFL), `img/` (og-image.png, editos-capture.webp, favicon.svg).

**Qualité** — `scripts/check-leaks.sh`, `scripts/check-jsonld.py`,
`.github/workflows/validate.yml`, `lighthouserc.json`, `.htmlvalidate.json`.

**Documentation** — `README.md` (déploiement, retour arrière, DNS, suites), ce rapport.

## 3. Conception

Le design reprend les tokens du design system HK CONSEILS — palette (navy, bleu chevron,
gris), unité modulaire de 8 px, rayons et ombres, fonds « dark tech » et « grid architecture ».
La composition alterne surfaces sombres et claires ; les libellés techniques sont en
IBM Plex Mono, le texte courant en Inter.

Deux écarts assumés par rapport au design system, tous deux imposés par la directive :

1. **`@import` Google Fonts supprimé.** Le design system chargeait Inter et IBM Plex Mono
   depuis Google Fonts, ce qu'interdit le §1. Les deux familles sont sous SIL OFL 1.1 :
   elles sont auto-hébergées en WOFF2 (sous-ensemble latin), licences incluses. Inter est
   servie en fonte variable — un seul fichier couvre les graisses 400/600/700.
2. **Bleu de marque interdit en texte sur fond sombre.** `#005FFA` sur navy plafonne à
   3,3:1, sous le seuil AA. Une variante éclaircie (`#6BA6FF`, 6,9:1) est utilisée pour
   tout texte et lien posé sur surface sombre ; le bleu canonique reste employé sur fond
   clair et comme aplat décoratif.

## 4. Écarts par rapport à la directive

| Point | Directive | Livré | Raison |
|---|---|---|---|
| `<title>` | « HK CONSEILS — Conseil en IA générative souveraine pour PME · Lyon » (65 car.) | « HK CONSEILS — IA générative souveraine pour PME · Lyon » (54 car.) | Le titre prescrit au §3.2 dépasse de 5 caractères la limite de 60 fixée par l'AC2. Arbitrage en faveur du critère mesurable ; « conseil » est conservé en tête de la meta description. **À confirmer.** |
| Meta description | 184 car. | 155 car. | Même conflit §3.2 / AC2. Coupe minimale : « fondé en 2026 » et « et » retirés, tous les termes porteurs conservés. |
| Lien LinkedIn | attendu comme acquis | `{{LINKEDIN_URL}}` | Aucune URL de profil dans les sources fournies. Elle n'a pas été inventée. Traitée comme `{{ADRESSE_SIEGE}}` : bloquante à la publication. |

## 5. Résultats des portes

```
check-leaks : OK — 16 fichiers analysés, aucun motif interdit
              (test négatif : 6/6 familles de motifs déclenchées)
check-jsonld: OK — @graph valide, 7 nœuds, 5 Q/R identiques DOM ↔ balisage
Lighthouse  : en attente d'exécution CI
html-validate: en attente d'exécution CI
Rich Results: en attente de mise en ligne
```

## 6. Questions ouvertes

1. **`{{ADRESSE_SIEGE}}`** — adresse du siège, pour les mentions légales et le JSON-LD.
   Bloquant pour l'AC6 et pour la publication.
2. **`{{LINKEDIN_URL}}`** — URL du profil LinkedIn, utilisée à quatre endroits
   (bouton d'accroche, contact, `sameAs` de l'organisation et de la personne).
   Bloquant pour la publication.
3. **Capture Editos** — l'image livrée est un placeholder neutre de 1280 × 800.
   La capture assainie reste due (jeu d'essai fictif, vue soumission/résultat,
   aucun journal, aucun panneau technique).
4. **Titre raccourci** — arbitrage du §4 à valider.

> **Conséquence attendue sur la CI** : le job `leaks-check` s'exécute avec `RELEASE=1`
> sur `main`. Il **échouera donc tant que les deux placeholders ne seront pas fournis** —
> c'est la porte qui fait son travail, pas une régression. À noter : Cloudflare Pages
> déploie sur son intégration Git sans consulter GitHub Actions. Ce qui protège réellement
> la production, c'est que le domaine n'est pas encore basculé : tant que l'apex ne pointe
> pas vers Pages, le site n'existe que sur son URL `*.pages.dev`.

## 7. Suites

1. Créer le projet Cloudflare Pages sur ce dépôt (sortie `public`, aucune commande de build).
2. Vérifier le premier déploiement de prévisualisation, puis relever les scores Lighthouse
   réels et compléter l'AC1 ci-dessus.
3. Une fois les deux placeholders résolus : `RELEASE=1 bash scripts/check-leaks.sh` doit
   passer, puis basculer l'apex et `www` vers Pages et documenter les enregistrements
   touchés dans `README.md`.
4. Passer l'URL de production au test des résultats enrichis et consigner le verdict ici.
5. Search Console + fiche d'établissement Google — actions Hémerson.
