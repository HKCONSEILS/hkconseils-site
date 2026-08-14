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
    // Coloration syntaxique par Shiki, au build : aucun JavaScript n'est émis,
    // la couleur est calculée une fois pour toutes et posée dans le HTML.
    // Contrepartie connue : Shiki pose un attribut style= par jeton. La règle
    // no-inline-style de html-validate est donc levée pour les seules pages
    // générées du blog, jamais pour la vitrine écrite à la main.
    syntaxHighlight: 'shiki',
    // Le thème n'est pas choisi pour son allure mais pour son contraste. Mesuré
    // sur le navy de la marque, qui sert de fond aux blocs de code : le jeton le
    // plus faible de catppuccin-frappe atteint 6,29:1, là où github-dark tombait
    // à 1,16 et faisait chuter l'accessibilité à 95 sur les pages à code.
    shikiConfig: { theme: 'catppuccin-frappe' },
  },
  // Le blog n'émet aucun JavaScript ; les styles restent groupés dans un seul
  // fichier plutôt que dispersés en balises inline, pour rester cacheable.
  vite: {
    build: {
      cssCodeSplit: false,
    },
  },
});
