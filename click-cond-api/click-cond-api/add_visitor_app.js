const mysql = require('mysql2/promise');

async function addVisitor() {
  const connection = await mysql.createConnection({
    host: 'turntable.proxy.rlwy.net',
    port: 54654,
    user: 'root',
    password: 'dwhGSPBYLxNVOAOdhshsGoLXPTSPqhwr',
    database: 'railway'
  });

  try {
    const [result] = await connection.execute(
      'INSERT INTO Visitantes (nome, doc_identificacao, id_apartamento, id_condominio, is_visitante, created_at) VALUES (?, ?, ?, ?, ?, ?)',
      ['VISITANTE VINDO DO APP', '999888777', 1, 1, 1, new Date()]
    );
    console.log('Inserido com sucesso, ID:', result.insertId);
  } catch (err) {
    console.error(err);
  } finally {
    await connection.end();
  }
}

addVisitor();
