require('dotenv').config();
const mysql = require('mysql2/promise');

async function migrate() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    connectTimeout: 30000
  });

  try {
    console.log('Adicionando campos na tabela Visitantes...');
    try { await connection.query(`ALTER TABLE Visitantes ADD COLUMN data_entrada DATETIME NULL`); } catch(e) {}
    try { await connection.query(`ALTER TABLE Visitantes ADD COLUMN data_saida DATETIME NULL`); } catch(e) {}
    console.log('Sucesso (ou campos já existem)!');
  } catch (err) {
    console.error('Erro:', err);
  } finally {
    await connection.end();
  }
}

migrate();
