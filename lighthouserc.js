import { readdirSync, existsSync } from 'node:fs';

// Les pages du blog n'existent qu'après le build : la liste des URL est donc
// construite au moment de l'exécution. Deux articles suffisent à l'AC5, et ce
// sont les deux plus récents qui sont retenus — c'est sur eux que porteront les
// premiers regards, et un gabarit qui tient sur eux tient sur les autres.
const ARTICLE_SAMPLE = 2;

function articleUrls() {
  const dir = 'dist/blog';
  if (!existsSync(dir)) return [];
  return readdirSync(dir, { withFileTypes: true })
    .filter((e) => e.isDirectory() && existsSync(`${dir}/${e.name}/index.html`))
    .sort((a, b) => b.name.localeCompare(a.name))
    .slice(0, ARTICLE_SAMPLE)
    .map((e) => `http://localhost/blog/${e.name}/index.html`);
}

export default {
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
