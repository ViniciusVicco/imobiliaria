import { PrismaClient } from '@prisma/client';

import { env } from '../src/config/env.js';
import { hashPassword } from '../src/shared/security/password.js';

const prisma = new PrismaClient();

const now = new Date();

const propertyTags = [
  {
    slug: 'na-planta',
    label: 'Na planta',
    description: 'Imoveis em lancamento ou em fase de construcao.',
    sortOrder: 10,
  },
  {
    slug: 'recem-entregue',
    label: 'Recem entregue',
    description: 'Imoveis novos, entregues recentemente.',
    sortOrder: 20,
  },
  {
    slug: 'alta-rentabilidade',
    label: 'Alta rentabilidade',
    description: 'Oportunidades com forte potencial de renda ou valorizacao.',
    sortOrder: 30,
  },
  {
    slug: 'entrada-reduzida',
    label: 'Entrada reduzida',
    description: 'Condicoes comerciais com entrada inicial menor.',
    sortOrder: 40,
  },
  {
    slug: 'exclusivo',
    label: 'Exclusivo',
    description: 'Oportunidades com curadoria ou disponibilidade especial.',
    sortOrder: 50,
  },
  {
    slug: 'pronto-para-morar',
    label: 'Pronto para morar',
    description: 'Imoveis prontos para ocupacao imediata.',
    sortOrder: 60,
  },
] as const;

const featuredProperties = [
  {
    id: 'prop_001',
    title: 'Apartamento com varanda gourmet',
    segment: 'residential',
    propertyType: 'Apartamento',
    tagSlugs: ['pronto-para-morar'],
    city: 'Palmas',
    neighborhood: 'Plano Diretor Sul',
    subNeighborhood: '706 Sul',
    coverUrl:
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
    areaM2: 82,
    bedrooms: 2,
    bathrooms: 2,
    garageSpaces: 1,
    propertyAgeYears: 4,
    price: 850000,
  },
  {
    id: 'prop_002',
    title: 'Sala comercial pronta para receber clientes',
    segment: 'commercial',
    propertyType: 'Sala comercial',
    tagSlugs: ['pronto-para-morar'],
    city: 'Palmas',
    neighborhood: 'Plano Diretor Sul',
    subNeighborhood: 'ACSU-SE 20',
    coverUrl:
      'https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=1200&q=80',
    areaM2: 54,
    bedrooms: null,
    bathrooms: 2,
    garageSpaces: 1,
    propertyAgeYears: 7,
    price: 620000,
  },
  {
    id: 'prop_003',
    title: 'Projeto na planta com lazer completo',
    segment: 'residential',
    propertyType: 'Oportunidades na planta',
    tagSlugs: ['na-planta', 'entrada-reduzida'],
    city: 'Palmas',
    neighborhood: 'Orla',
    subNeighborhood: 'Orla 14',
    coverUrl:
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
    areaM2: 68,
    bedrooms: 2,
    bathrooms: 2,
    garageSpaces: 1,
    propertyAgeYears: 0,
    price: 560000,
  },
  {
    id: 'prop_004',
    title: 'Casa terrea com piscina e area gourmet',
    segment: 'residential',
    propertyType: 'Casa',
    tagSlugs: ['exclusivo'],
    city: 'Palmas',
    neighborhood: 'Plano Diretor Norte',
    subNeighborhood: 'ARNO 21',
    coverUrl:
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1200&q=80',
    areaM2: 186,
    bedrooms: 3,
    bathrooms: 3,
    garageSpaces: 2,
    propertyAgeYears: 5,
    price: 1250000,
  },
  {
    id: 'prop_005',
    title: 'Apartamento nascente proximo ao parque',
    segment: 'residential',
    propertyType: 'Apartamento',
    tagSlugs: [],
    city: 'Palmas',
    neighborhood: 'Plano Diretor Sul',
    subNeighborhood: 'ARSE 51',
    coverUrl:
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80',
    areaM2: 96,
    bedrooms: 3,
    bathrooms: 2,
    garageSpaces: 2,
    propertyAgeYears: 3,
    price: 980000,
  },
  {
    id: 'prop_006',
    title: 'Loja comercial em avenida de alto fluxo',
    segment: 'commercial',
    propertyType: 'Loja',
    tagSlugs: [],
    city: 'Palmas',
    neighborhood: 'Taquaralto',
    subNeighborhood: 'Taquaralto 2 Etapa',
    coverUrl:
      'https://images.unsplash.com/photo-1604014237800-1c9102c219da?auto=format&fit=crop&w=1200&q=80',
    areaM2: 140,
    bedrooms: null,
    bathrooms: 2,
    garageSpaces: 4,
    propertyAgeYears: 9,
    price: 890000,
  },
  {
    id: 'prop_007',
    title: 'Casa em condominio com suite master',
    segment: 'residential',
    propertyType: 'Casa em condominio',
    tagSlugs: ['exclusivo'],
    city: 'Palmas',
    neighborhood: 'Orla',
    subNeighborhood: 'Orla 14',
    coverUrl:
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
    areaM2: 224,
    bedrooms: 4,
    bathrooms: 5,
    garageSpaces: 3,
    propertyAgeYears: 2,
    price: 1850000,
  },
  {
    id: 'prop_008',
    title: 'Predio comercial para renda recorrente',
    segment: 'commercial',
    propertyType: 'Proximos de entregar',
    tagSlugs: ['alta-rentabilidade'],
    city: 'Palmas',
    neighborhood: 'Centro',
    subNeighborhood: 'ACNO 1',
    coverUrl:
      'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80',
    areaM2: 420,
    bedrooms: null,
    bathrooms: 6,
    garageSpaces: 8,
    propertyAgeYears: 1,
    price: 3200000,
  },
  {
    id: 'prop_009',
    title: 'Studio compacto para investimento',
    segment: 'residential',
    propertyType: 'Oportunidades na planta',
    tagSlugs: ['na-planta', 'alta-rentabilidade'],
    city: 'Palmas',
    neighborhood: 'Plano Diretor Sul',
    subNeighborhood: '706 Sul',
    coverUrl:
      'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?auto=format&fit=crop&w=1200&q=80',
    areaM2: 42,
    bedrooms: 1,
    bathrooms: 1,
    garageSpaces: 1,
    propertyAgeYears: 0,
    price: 420000,
  },
] as const;

async function main() {
  const firstAdminPasswordHash = await hashPassword(env.FIRST_ADMIN_PASSWORD);

  await prisma.user.upsert({
    where: { email: env.FIRST_ADMIN_EMAIL.toLowerCase() },
    update: {
      name: env.FIRST_ADMIN_NAME,
      passwordHash: firstAdminPasswordHash,
      role: 'admin',
      isActive: true,
    },
    create: {
      name: env.FIRST_ADMIN_NAME,
      email: env.FIRST_ADMIN_EMAIL.toLowerCase(),
      phone: null,
      passwordHash: firstAdminPasswordHash,
      role: 'admin',
      isActive: true,
    },
  });

  for (const tag of propertyTags) {
    await prisma.propertyTag.upsert({
      where: { slug: tag.slug },
      update: {
        label: tag.label,
        description: tag.description,
        isActive: true,
        sortOrder: tag.sortOrder,
      },
      create: {
        ...tag,
        isActive: true,
      },
    });
  }

  await prisma.brandContent.upsert({
    where: { id: 'home' },
    update: {
      mission:
        'Conectar pessoas a imoveis em Palmas com clareza, criterio e acompanhamento humano.',
      about:
        'A Seletta atua na curadoria de oportunidades residenciais, comerciais e de investimento em Palmas e regiao.',
      contactPhone: '(63) 3000-0000',
      contactEmail: 'contato@seletta.com.br',
      contactWhatsapp: '(63) 99997-3336',
      videoProvider: 'youtube',
      videoTitle: 'Conheca a Seletta',
      videoThumbnailUrl: 'https://img.youtube.com/vi/OGEEQ9VEEmc/maxresdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=OGEEQ9VEEmc',
    },
    create: {
      id: 'home',
      mission:
        'Conectar pessoas a imoveis em Palmas com clareza, criterio e acompanhamento humano.',
      about:
        'A Seletta atua na curadoria de oportunidades residenciais, comerciais e de investimento em Palmas e regiao.',
      contactPhone: '(63) 3000-0000',
      contactEmail: 'contato@seletta.com.br',
      contactWhatsapp: '(63) 99997-3336',
      videoProvider: 'youtube',
      videoTitle: 'Conheca a Seletta',
      videoThumbnailUrl: 'https://img.youtube.com/vi/OGEEQ9VEEmc/maxresdefault.jpg',
      videoUrl: 'https://www.youtube.com/watch?v=OGEEQ9VEEmc',
    },
  });

  for (const property of featuredProperties) {
    const propertyData = {
      ...property,
      tagSlugs: [...property.tagSlugs],
    };

    await prisma.property.upsert({
      where: { id: property.id },
      update: {
        ...propertyData,
        status: 'published',
        isFeatured: true,
        updatedAt: now,
      },
      create: {
        ...propertyData,
        status: 'published',
        isFeatured: true,
        createdAt: now,
      },
    });
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
