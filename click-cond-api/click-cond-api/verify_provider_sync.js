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
    const [providers] = await connection.execute('SELECT * FROM Prestadores_servico WHERE nome LIKE ?', ['%PRESTADOR TESTE WEB%']);
    console.log(JSON.stringify(providers, null, 2));
  } catch (err) {
    console.error(err);
  } finally {
    await connection.end();
  }
}

checkSync();
