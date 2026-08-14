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
    // 'jour' quand la date exacte est connue, 'mois' quand elle est approchée.
    // Afficher un jour qu'on n'a pas vérifié serait une précision fausse.
    originalDatePrecision: z.enum(['jour', 'mois']).default('jour'),
    // Étiquettes techniques courtes, en minuscules, affichées en monospace.
    tags: z.array(z.string()).default([]),
    // Un brouillon est rédigé et versionné, mais absent du site publié :
    // ni page, ni entrée d'index, ni flux, ni sitemap. Sa publication à
    // l'échéance prévue n'est alors qu'un changement de ce drapeau.
    draft: z.boolean().default(false),
  }),
});

export const collections = { blog };
