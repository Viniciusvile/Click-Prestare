const mysql = require('mysql2/promise');

async function populateRailway() {
  const config = {
    host: 'turntable.proxy.rlwy.net',
    port: 54654,
    user: 'root',
    password: 'dwhGSPBYLxNVOAOdhshsGoLXPTSPqhwr',
    database: 'railway'
  };

  console.log("Connecting to Railway MySQL...");
  const connection = await mysql.createConnection(config);

  const email = 'fui@eu.com';
  const pass = '999888';

  try {
    // 1. Garantir que existe pelo menos um Condomínio
    console.log("Checking for Condominios...");
    const [condos] = await connection.execute('SELECT id FROM Condominios LIMIT 1');
    let condoId;
    if (condos.length === 0) {
      console.log("Creating a test Condominio...");
      const [result] = await connection.execute("INSERT INTO Condominios (nome, ativo) VALUES ('Condominio Railway Teste', 1)");
      condoId = result.insertId;
    } else {
      condoId = condos[0].id;
    }

    // 2. Garantir que existe pelo menos um Apartamento
    console.log("Checking for Apartamentos...");
    const [aptos] = await connection.execute('SELECT id FROM Apartamentos WHERE id_condominio = ? LIMIT 1', [condoId]);
    let aptoId;
    if (aptos.length === 0) {
      console.log("Creating a test Apartamento...");
      const [result] = await connection.execute("INSERT INTO Apartamentos (apto, bloco, id_condominio) VALUES ('101', 'A', ?)", [condoId]);
      aptoId = result.insertId;
    } else {
      aptoId = aptos[0].id;
    }

    // 3. Criar ou Atualizar Usuário
    console.log(`Creating user ${email}...`);
    await connection.execute('DELETE FROM Users WHERE login = ?', [email]);
    const [userResult] = await connection.execute(`
      INSERT INTO Users (login, email, password, is_morador, name)
      VALUES (?, ?, MD5(?), 1, 'Teste Railway')
    `, [email, email, pass]);
    const userId = userResult.insertId;

    // 4. Criar Morador
    console.log("Creating Morador entry...");
    await connection.execute('DELETE FROM Moradores WHERE id_user = ?', [userId]);
    await connection.execute(`
      INSERT INTO Moradores (nome, email, id_user, id_condominio, documento)
      VALUES (?, ?, ?, ?, '123456789')
    `, ['Teste Railway', email, userId, condoId]);

    // 5. Vincular ao Apartamento (para aparecer na lista)
    console.log("Linking to Apartamento...");
    await connection.execute('DELETE FROM Apartamentos_Users WHERE id_user = ?', [userId]);
    await connection.execute(`
      INSERT INTO Apartamentos_Users (id_apto, id_user, tipo, vencimento)
      VALUES (?, ?, 'Proprietário', DATE_ADD(NOW(), INTERVAL 365 DAY))
    `, [aptoId, userId]);

    console.log("\nSUCCESS! User 'fui@eu.com' / '999888' is now ready on Railway cloud.");
    console.log("You can now test the app on any device!");

  } catch (err) {
    console.error("Error during Railway population:", err);
  } finally {
    await connection.end();
  }
}

populateRailway();
