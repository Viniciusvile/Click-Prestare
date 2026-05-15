const { PrismaClient } = require('./apps/api/src/app/prisma/generated');
const prisma = new PrismaClient();

async function cleanup() {
  try {
    const deleted = await prisma.assembleias.deleteMany({
      where: {
        titulo: {
          contains: 'Antigravity'
        }
      }
    });
    console.log('Deleted assembleias:', deleted.count);
  } catch (e) {
    console.error(e);
  } finally {
    await prisma.$disconnect();
  }
}

cleanup();
