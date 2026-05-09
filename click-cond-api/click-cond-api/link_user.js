require('dotenv').config();
const mysql = require('mysql2/promise');

async function linkUserToApto() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  });

  const email = 'fui@eu.com';

  console.log(`Linking ${email} to an apartment...`);

  // Pegar o ID do usuário
  const [userRows] = await connection.execute('SELECT id FROM Users WHERE login = ?', [email]);
  if (userRows.length === 0) {
    console.log("User not found!");
    await connection.end();
    return;
  }
  const userId = userRows[0].id;

  // Pegar o primeiro apartamento disponível
  const [aptoRows] = await connection.execute('SELECT id FROM Apartamentos LIMIT 1');
  if (aptoRows.length === 0) {
    console.log("No apartments found in DB! Please create one first.");
    await connection.end();
    return;
  }
  const aptoId = aptoRows[0].id;

  // Remover se já estiver vinculado (limpeza)
  await connection.execute('DELETE FROM Apartamentos_Users WHERE id_user = ?', [userId]);

  // Vincular na tabela Apartamentos_Users (essencial para listar o condomínio)
  await connection.execute(`
    INSERT INTO Apartamentos_Users (id_apto, id_user, tipo, vencimento)
    VALUES (?, ?, 'Proprietário', DATE_ADD(NOW(), INTERVAL 365 DAY))
  `, [aptoId, userId]);

  console.log(`Success! User ${email} is now linked to Apartment ID ${aptoId}.`);
  await connection.end();
}

linkUserToApto().catch(console.error);
