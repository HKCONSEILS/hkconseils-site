# hkconseils-site

Site vitrine de HK CONSEILS — `https://hkconseils.fr`.

HTML5 et CSS natifs, **aucune étape de build, aucun framework, aucun JavaScript**.
Le répertoire `public/` est servi tel quel. Toutes les ressources (feuille de style,
polices, images) sont locales&nbsp;: la page ne fait aucune requête vers un domaine tiers.

---

## Structure

```
public/                    racine déployée
  index.html               page unique (contenu, JSON-LD @graph)
  mentions-legales.html
  confidentialite.html
  robots.txt               crawlers IA explicitement autorisés
  sitemap.xml
  _redirects               www → apex, 301
  css/main.css             tokens du design system HK CONSEILS, purgés
  fonts/                   Inter + IBM Plex Mono en WOFF2 (SIL OFL 1.1, licences incluses)
  img/                     og-image.png, editos-capture.webp, favicon.svg
scripts/check-leaks.sh     porte AC5 — fuites d'infrastructure et de noms de clients
scripts/check-jsonld.py    porte AC3 — @graph valide, FAQ identique entre DOM et balisage
lighthouserc.json          seuils Lighthouse (mobile, ≥ 0,95 sur les 4 axes)
.github/workflows/validate.yml
```

## Validations locales

```bash
bash scripts/check-leaks.sh && python3 scripts/check-jsonld.py
```

Aucune dépendance&nbsp;: bash et Python 3 suffisent. `html-validate` et Lighthouse CI
tournent en intégration continue (ils demandent Node.js, absent de la machine de travail).

Pour rejouer la porte de publication telle qu'elle s'exécute sur `main`&nbsp;:

```bash
RELEASE=1 bash scripts/check-leaks.sh
```

Tant qu'un placeholder `{{...}}` subsiste, cette commande échoue&nbsp;: c'est voulu.

## Déploiement

Cloudflare Pages, projet `hkconseils-site`, connecté au dépôt GitHub.

| Réglage | Valeur |
|---|---|
| Branche de production | `main` |
| Commande de build | `npm ci && npm run build` |
| Répertoire de sortie | `dist` |
| Version de Node | lue dans `.nvmrc` (22.23.2) |
| Variables d'environnement | *(aucune)* |

Un push sur `main` déclenche le déploiement. Une pull request produit une URL de
prévisualisation. **Aucun jeton d'API Cloudflare ne doit être ajouté au dépôt**&nbsp;:
Cloudflare Pages déploie par sa propre intégration Git.

### Cohabitation entre le site et le blog

La vitrine reste du HTML natif, écrit à la main dans `public/`. Astro **recopie ce
répertoire tel quel** dans `dist/` et n'y ajoute que `/blog/`, le flux RSS et le
sitemap. Aucune page existante ne passe par une transformation, ce que la CI vérifie
à chaque exécution par comparaison octet à octet entre `public/` et `dist/`.

Conséquence pratique&nbsp;: pour modifier la page d'accueil ou une page légale, on
édite le fichier dans `public/`, exactement comme avant le blog.

### Bascule de la configuration de build

Le passage de « aucune commande » à `npm ci && npm run build` est un réglage **de
projet**, pas de branche&nbsp;: il s'applique aussi aux prévisualisations. Il faut donc
le changer **avant** de pouvoir valider le blog sur l'URL de prévisualisation d'une
branche, puisque sans build, la prévisualisation ne sert que le contenu de `public/`.

Pendant la fenêtre qui sépare ce changement du merge, un déploiement de `main`
échouera, `main` ne portant pas encore de `package.json`. **Un build en échec ne coupe
pas le site**&nbsp;: Cloudflare Pages continue de servir le dernier déploiement réussi.
Le risque n'est donc pas une indisponibilité, mais l'impossibilité temporaire de
déployer un correctif urgent. Garder la fenêtre courte.

**Retour arrière de la bascule**, à appliquer si la validation échoue&nbsp;:

1. Tableau de bord Pages → *Settings* → *Builds & deployments*&nbsp;: remettre la
   commande de build à vide et le répertoire de sortie à `public`.
2. Si un déploiement fautif est déjà en production&nbsp;: *Deployments* →
   *Rollback to this deployment* sur le dernier déploiement sain.
3. Le site repart alors sur le HTML de `public/`, sans le blog, dans l'état qui était
   le sien avant la bascule.

### Enregistrements DNS

La zone `hkconseils.fr` est gérée par Cloudflare. Le passage en production ne touche
que l'apex et `www`&nbsp;; **les enregistrements de messagerie (MX, SPF, DMARC, DKIM,
autodiscover) ne doivent pas être modifiés.**

| Nom | Type | Valeur | Modifié le |
|---|---|---|---|
| `hkconseils.fr` | CNAME → `hkconseils-site.pages.dev`, proxifié | *avant : `A 213.186.33.5` (origine OVH, hors service — HTTP 521)* | 2026-08-13 |
| `www.hkconseils.fr` | CNAME → `hkconseils-site.pages.dev`, proxifié | *avant : `A 213.186.33.5`* | 2026-08-13 |

Aucun autre enregistrement n'a été touché. La messagerie (MX ×3, SPF, DMARC,
DKIM, autodiscover) est restée intacte.

**Retour arrière DNS** : recréer les deux `A` vers `213.186.33.5` en proxifié —
étant entendu que cette origine ne répondait plus.

> ⚠️ La redirection `www` → apex **n'est pas assurée par `public/_redirects`** :
> les règles de ce fichier s'appliquent aux chemins, pas aux noms d'hôte, et
> `www` est attaché au même projet Pages. Il sert donc le site en 200. Le
> correctif est une *Single Redirect* au niveau de la zone (voir `REPORT.md`).

## Retour arrière

1. **Voie normale** — tableau de bord Cloudflare Pages → *Deployments* → sélectionner
   le déploiement précédent → **Rollback to this deployment**. Effet immédiat, sans
   passer par Git. Les déploiements antérieurs sont conservés.
2. **Voie Git** — `git revert <sha>` puis `git push`&nbsp;: un nouveau déploiement part
   automatiquement. À privilégier lorsque le contenu fautif doit aussi disparaître du dépôt.

## Après la mise en ligne

- [ ] Créer la propriété Search Console pour `hkconseils.fr` et y soumettre
      `https://hkconseils.fr/sitemap.xml` — *action Hémerson*.
- [ ] Créer la fiche Google Business Profile — *action Hémerson, tâche parallèle*.
- [ ] Passer l'URL de production au test des résultats enrichis de Google et
      consigner le résultat dans `REPORT.md`.
- [ ] Remplacer `{{ADRESSE_SIEGE}}` et `{{LINKEDIN_URL}}` (voir `REPORT.md`).
