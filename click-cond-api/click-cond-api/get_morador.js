require('dotenv').config();
const mysql = require('mysql2/promise');

async function findValidMorador() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  });

  // Executando exatamente o JOIN que o backend faz para o login
  const [rows] = await connection.execute(`
    SELECT u.login, m.documento, u.password as hash
    FROM Moradores m
    INNER JOIN Users u ON u.id = m.id_user
    WHERE u.is_morador = 1
    LIMIT 10
  `);
  
  console.log(JSON.stringify(rows, null, 2));
  await connection.end();
}

findValidMorador().catch(console.error);
