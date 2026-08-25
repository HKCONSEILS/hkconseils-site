const { readdirSync, existsSync } = require('node:fs');

// Fichier en CommonJS, et nommé .cjs à dessein : package.json déclare
// "type": "module", or @lhci/cli charge sa configuration par require(). Un
// lighthouserc.js serait alors lu comme un module ES, le chargement échouerait
// en silence, et lhci retomberait sur ses assertions par défaut — ce qui s'est
// produit : la CI a échoué sur des audits jamais déclarés ici.
//
// Les pages du blog n'existent qu'après le build : la liste des URL est donc
// construite au moment de l'exécution.
//
// ⚠️ Correction du 2026-08-25. Le commentaire d'origine annonçait « les deux
// articles les plus récents ». C'était faux : le tri porte sur le NOM du
// répertoire, donc sur le slug, par ordre alphabétique décroissant. La date de
// publication n'intervient nulle part. En pratique l'échantillon retenait
// toujours les deux mêmes articles, et aucune page nouvelle n'a jamais été
// mesurée par ce job. Le tri est conservé tel quel — il donne un échantillon
// stable, ce qui est une qualité pour une comparaison dans le temps — mais son
// intitulé est corrigé et il ne suffit plus à lui seul.
const ARTICLE_SAMPLE = 2;

// Articles dont la mesure est EXIGÉE, indépendamment de l'échantillon ci-dessus.
// Un vert qui ne couvre pas les pages nouvelles n'atteste qu'une non-régression
// du gabarit, pas la qualité de ce qui vient d'être publié.
const ARTICLES_REQUIS = [
  'facture-electronique-septembre-2026',
  'agents-ia-on-premise-trois-architectures',
  'openclaw-plateforme-multi-agents-lecons',
  'hermes-poc-agent-ce-qui-nest-pas-annonce',
  'ironclaw-secret-absent-pas-refuse',
];

function articleUrls() {
  const dir = 'dist/blog';
  if (!existsSync(dir)) return [];
  const construits = readdirSync(dir, { withFileTypes: true })
    .filter((e) => e.isDirectory() && existsSync(`${dir}/${e.name}/index.html`))
    .map((e) => e.name);

  const echantillon = [...construits].sort((a, b) => b.localeCompare(a)).slice(0, ARTICLE_SAMPLE);

  // Un article requis mais absent du build est une erreur de configuration
  // silencieuse : il serait simplement omis de la mesure. On l'annonce.
  const manquants = ARTICLES_REQUIS.filter((a) => !construits.includes(a));
  if (manquants.length) {
    console.warn(`lighthouserc: articles requis absents du build : ${manquants.join(', ')}`);
  }

  const retenus = [...new Set([...ARTICLES_REQUIS.filter((a) => construits.includes(a)), ...echantillon])];
  return retenus.map((nom) => `http://localhost/blog/${nom}/index.html`);
}

module.exports = {
  ci: {
    collect: {
      staticDistDir: 'dist',
      url: [
        'http://localhost/index.html',
        'http://localhost/mentions-legales.html',
        'http://localhost/confidentialite.html',
        'http://localhost/blog/index.html',
        ...articleUrls(),
      ],
      numberOfRuns: 3,
      settings: {
        formFactor: 'mobile',
        throttlingMethod: 'simulate',
        screenEmulation: {
          mobile: true,
          width: 412,
          height: 823,
          deviceScaleFactor: 1.75,
          disabled: false,
        },
      },
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.95 }],
        'categories:accessibility': ['error', { minScore: 0.95 }],
        'categories:best-practices': ['error', { minScore: 0.95 }],
        'categories:seo': ['error', { minScore: 0.95 }],
      },
    },
    upload: {
      target: 'filesystem',
      outputDir: '.lighthouseci/reports',
    },
  },
};
