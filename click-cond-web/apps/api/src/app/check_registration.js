const { PrismaClient } = require('./prisma/generated');
const prisma = new PrismaClient();

async function main() {
  const conds = await prisma.condominios.findMany({
    orderBy: { created_at: 'desc' },
    take: 5
  });
  console.log('Últimos Condomínios:', JSON.stringify(conds, null, 2));

  const rels = await prisma.sindicos_Condominios.findMany({
    orderBy: { created_at: 'desc' },
    take: 5,
    include: { user: true }
  });
  console.log('Últimos Vínculos de Síndico:', JSON.stringify(rels, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
