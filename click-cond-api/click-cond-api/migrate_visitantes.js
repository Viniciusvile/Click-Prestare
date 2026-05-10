const db = require('./src/database/MySQL.js');

async function migrate() {
  try {
    console.log('Adicionando campos de entrada e saída na tabela Visitantes...');
    
    await db.query(`ALTER TABLE Visitantes ADD COLUMN IF NOT EXISTS data_entrada DATETIME NULL`);
    await db.query(`ALTER TABLE Visitantes ADD COLUMN IF NOT EXISTS data_saida DATETIME NULL`);
    
    console.log('Migração concluída com sucesso!');
    process.exit(0);
  } catch (err) {
    console.error('Erro na migração:', err);
    process.exit(1);
  }
}

migrate();
