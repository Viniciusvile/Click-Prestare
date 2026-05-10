require('dotenv').config();
const mysql = require('mysql2/promise');

async function checkData() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  try {
    const [rows] = await connection.query('SELECT data_entrada, data_saida FROM Visitantes LIMIT 1');
    console.log(JSON.stringify(rows[0]));
  } catch (err) {
    console.error('Erro:', err);
  } finally {
    await connection.end();
  }
}

checkData();
