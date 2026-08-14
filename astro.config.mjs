// @ts-check
import { defineConfig } from 'astro/config';

// Le site actuel vit dans public/ et Astro le recopie tel quel dans dist/.
// C'est ce qui garantit l'AC7 : la page d'accueil et les pages légales ne
// passent par aucune transformation, elles sont copiées octet pour octet.
// Astro n'ajoute que /blog/, le flux RSS et le sitemap.
export default defineConfig({
  site: 'https://hkconseils.fr',
  // 'directory' produit /blog/<slug>/index.html, donc des URL avec barre finale.
  build: { format: 'directory' },
  // Aucune intégration : pas de framework, pas de MDX, pas de sitemap tiers.
  integrations: [],
  markdown: {
    // La coloration syntaxique de Shiki pose un attribut style= sur chaque jeton,
    // ce que html-validate refuse (no-inline-style) et qui alourdit le HTML de
    // plusieurs kilooctets par bloc de code. Les blocs sont stylés par la feuille
    // du site, sur le même navy que le reste.
    syntaxHighlight: false,
  },
  // Le blog n'émet aucun JavaScript ; les styles restent groupés dans un seul
  // fichier plutôt que dispersés en balises inline, pour rester cacheable.
  vite: {
    build: {
      cssCodeSplit: false,
    },
  },
});
