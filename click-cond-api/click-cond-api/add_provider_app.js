const mysql = require('mysql2/promise');

async function addProvider() {
  const connection = await mysql.createConnection({
    host: 'turntable.proxy.rlwy.net',
    port: 54654,
    user: 'root',
    password: 'dwhGSPBYLxNVOAOdhshsGoLXPTSPqhwr',
    database: 'railway'
  });

  try {
    const [result] = await connection.execute(
      'INSERT INTO Prestadores_servico (nome, telefone, categorias, id_condominio, created_at) VALUES (?, ?, ?, ?, ?)',
      ['PRESTADOR VINDO DO APP', '11888888888', 'Limpeza', 1, new Date()]
    );
    console.log('Inserido com sucesso, ID:', result.insertId);
  } catch (err) {
    console.error(err);
  } finally {
    await connection.end();
  }
}

addProvider();
