const mysql = require('mysql2/promise');

async function checkWebTables() {
  const config = {
    host: 'turntable.proxy.rlwy.net',
    port: 54654,
    user: 'root',
    password: 'dwhGSPBYLxNVOAOdhshsGoLXPTSPqhwr',
    database: 'railway'
  };

  const connection = await mysql.createConnection(config);

  try {
    console.log("--- AUDITORIA DE TABELAS (APP + WEB) ---");
    const [tables] = await connection.execute("SHOW TABLES");
    const tableList = tables.map(t => Object.values(t)[0]);
    
    console.log("Tabelas encontradas no Railway:", tableList);

    const requiredWebTables = ['Users', 'Addresses', 'Condominios', 'Financeiro', 'Ocorrencias', 'Comunicados'];
    const missing = requiredWebTables.filter(t => !tableList.includes(t));

    if (missing.length > 0) {
      console.log("\n⚠️ ATENÇÃO: Faltam tabelas essenciais para o Sistema Web:", missing);
    } else {
      console.log("\n✅ Todas as tabelas base para o Sistema Web foram localizadas!");
    }

  } catch (err) {
    console.error("Erro na auditoria:", err);
  } finally {
    await connection.end();
  }
}

checkWebTables();
