const { PrismaClient } = require('./prisma/generated');
const prisma = new PrismaClient();

async function main() {
  const idUser = 49;
  const rels = await prisma.sindicos_Condominios.findMany({
    where: { id_user: idUser },
    include: {
      condominio: {
        include: {
          financeiro: { where: { pago: 1 } },
          apartamentos: true,
        },
      },
    },
  });
  console.log('Query Result for id_user 49:', JSON.stringify(rels, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
