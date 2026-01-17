import { defineCollection, z } from 'astro:content';

const newsCollection = defineCollection({
    type: 'content',
    schema: z.object({
        title: z.string(),
        description: z.string().optional(),
        pubDate: z.date(),
        updatedDate: z.date().optional(),
        lang: z.enum(['ja', 'en']).default('ja'),
    }),
});

export const collections = {
    'news': newsCollection,
};
