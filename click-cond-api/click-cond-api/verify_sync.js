const mysql = require('mysql2/promise');

async function checkSync() {
  const connection = await mysql.createConnection({
    host: 'turntable.proxy.rlwy.net',
    port: 54654,
    user: 'root',
    password: 'dwhGSPBYLxNVOAOdhshsGoLXPTSPqhwr',
    database: 'railway'
  });

  try {
    const [visitors] = await connection.execute('SELECT * FROM Visitantes WHERE nome LIKE ?', ['%TESTE SINCRONIZACAO%']);
    console.log(JSON.stringify(visitors, null, 2));
  } catch (err) {
    console.error(err);
  } finally {
    await connection.end();
  }
}

checkSync();
