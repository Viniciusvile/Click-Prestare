require('dotenv').config();
const mysql = require('mysql2/promise');

async function testInside() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  try {
    console.log('Marcando o primeiro visitante como "Dentro do Condomínio" para teste...');
    const [rows] = await connection.query('SELECT id FROM Visitantes LIMIT 1');
    if (rows.length > 0) {
      await connection.query(`UPDATE Visitantes SET data_entrada=NOW(), data_saida=NULL WHERE id=${rows[0].id}`);
      console.log(`Sucesso! Visitante ID ${rows[0].id} está agora "No Local".`);
    } else {
      console.log('Nenhum visitante encontrado para testar.');
    }
  } catch (err) {
    console.error('Erro:', err);
  } finally {
    await connection.end();
  }
}

testInside();
