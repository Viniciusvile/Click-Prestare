const { PrismaClient } = require('./apps/api/src/app/prisma/generated');
const prisma = new PrismaClient();

async function check() {
  try {
    const userCount = await prisma.users.count();
    console.log('Total users:', userCount);
    const firstUser = await prisma.users.findFirst();
    console.log('First user:', firstUser);
    
    const condCount = await prisma.condominios.count();
    console.log('Total condominios:', condCount);
    const firstCond = await prisma.condominios.findFirst();
    console.log('First cond:', firstCond);
  } catch (e) {
    console.error(e);
  } finally {
    await prisma.$disconnect();
  }
}

check();
