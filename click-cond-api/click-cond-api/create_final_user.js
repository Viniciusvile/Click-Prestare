require('dotenv').config();
const mysql = require('mysql2/promise');

async function createFinalUser() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  });

  const email = 'fui@eu.com';
  const pass = '999888';

  console.log(`Creating final test user ${email}...`);

  await connection.execute('DELETE FROM Users WHERE login = ?', [email]);

  const [result] = await connection.execute(`
    INSERT INTO Users (login, email, password, is_morador, name)
    VALUES (?, ?, MD5(?), 1, 'Teste Terminal')
  `, [email, email, pass]);

  const userId = result.insertId;

  await connection.execute(`
    INSERT INTO Moradores (nome, email, id_user, id_condominio, documento)
    VALUES (?, ?, ?, (SELECT id FROM Condominios LIMIT 1), '999888777')
  `, ['Teste Terminal', email, userId]);

  console.log("Final user created! Now run 'flutter run' in your terminal.");
  await connection.end();
}

createFinalUser().catch(console.error);
