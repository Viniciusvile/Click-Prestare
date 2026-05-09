require('dotenv').config();
const mysql = require('mysql2/promise');

async function createFreshUser() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  });

  const email = 'teste@click.com';
  const pass = '123456';

  console.log(`Creating fresh user ${email} with password ${pass}...`);

  // Remover se já existir
  await connection.execute('DELETE FROM Users WHERE login = ?', [email]);

  // Inserir no Users
  const [result] = await connection.execute(`
    INSERT INTO Users (login, email, password, is_morador, name)
    VALUES (?, ?, MD5(?), 1, 'Usuario Teste')
  `, [email, email, pass]);

  const userId = result.insertId;

  // Inserir no Moradores
  await connection.execute(`
    INSERT INTO Moradores (nome, email, id_user, id_condominio, documento)
    VALUES (?, ?, ?, (SELECT id FROM Condominios LIMIT 1), '123456789')
  `, ['Usuario Teste', email, userId]);

  console.log("Fresh user created successfully!");
  await connection.end();
}

createFreshUser().catch(console.error);
