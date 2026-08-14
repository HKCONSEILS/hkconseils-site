import { getCollection } from 'astro:content';

// Le sitemap est produit ici plutôt que par @astrojs/sitemap : cette intégration
// génère un sitemap-index.xml, ce qui obligerait à modifier robots.txt, or l'AC3
// exige que robots.txt reste inchangé. En le servant à /sitemap.xml, on reste sur
// l'URL que robots.txt annonce déjà, et le blog s'y ajoute automatiquement.
const SITE = 'https://hkconseils.fr';

// Pages statiques servies depuis public/, avec la date de leur dernière révision.
const STATIC_PAGES = [
  { path: '/', lastmod: '2026-08-14', changefreq: 'monthly', priority: '1.0' },
  { path: '/blog/', lastmod: '2026-08-14', changefreq: 'weekly', priority: '0.8' },
  { path: '/mentions-legales', lastmod: '2026-08-14', changefreq: 'yearly', priority: '0.2' },
  { path: '/confidentialite', lastmod: '2026-08-14', changefreq: 'yearly', priority: '0.2' },
];

export async function GET() {
  const posts = (await getCollection('blog')).sort(
    (a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf(),
  );

  const entries = [
    ...STATIC_PAGES,
    ...posts.map((post) => ({
      path: `/blog/${post.id}/`,
      lastmod: post.data.pubDate.toISOString().slice(0, 10),
      changefreq: 'yearly',
      priority: '0.6',
    })),
  ];

  const body = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${entries
  .map(
    (e) => `  <url>
    <loc>${SITE}${e.path}</loc>
    <lastmod>${e.lastmod}</lastmod>
    <changefreq>${e.changefreq}</changefreq>
    <priority>${e.priority}</priority>
  </url>`,
  )
  .join('\n')}
</urlset>
`;

  return new Response(body, {
    headers: { 'Content-Type': 'application/xml; charset=utf-8' },
  });
}
