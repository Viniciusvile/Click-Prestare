const { PrismaClient } = require('./prisma/generated');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.users.findMany({
    where: { login: 'sindico_novo@click.com' },
    include: {
      sindicosCondominios: {
        include: { condominio: true }
      }
    }
  });
  console.log('Dados do Usuário:', JSON.stringify(users, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
