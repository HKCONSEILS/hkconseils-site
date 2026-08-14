import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  // Le flux ne publie que ce qui est publié.
  const posts = (await getCollection('blog', ({ data }) => !data.draft)).sort(
    (a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf(),
  );

  return rss({
    title: 'Blog HK CONSEILS',
    description:
      "Retours d'expérience sur l'IA générative auto-hébergée : infrastructure d'inférence, dimensionnement, sécurité et coûts réels.",
    site: context.site,
    customData: '<language>fr-fr</language>',
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate,
      link: `/blog/${post.id}/`,
    })),
  });
}
