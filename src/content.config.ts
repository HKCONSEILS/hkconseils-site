import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// Un article rapatrié depuis LinkedIn porte deux dates :
//   pubDate      — sa date de publication sur ce blog, qui ordonne la liste ;
//   originalDate — la date du post LinkedIn d'origine, affichée dans l'article.
// Les deux sont obligatoires : un article sans provenance datée serait un
// article réécrit en silence.
const blog = defineCollection({
  loader: glob({ base: './src/content/blog', pattern: '**/*.md' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    originalDate: z.coerce.date(),
  }),
});

export const collections = { blog };
