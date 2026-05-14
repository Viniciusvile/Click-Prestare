const { PrismaClient } = require('./prisma/generated');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.users.findMany({
    where: { login: 'vinicius@teste.com' },
    include: {
      sindicos: true,
      sindicosCondominios: {
        include: { condominio: true }
      }
    }
  });
  console.log(JSON.stringify(users, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
