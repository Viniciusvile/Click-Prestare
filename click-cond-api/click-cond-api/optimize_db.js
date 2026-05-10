const mysql = require('mysql2/promise');
require('dotenv').config();

const { DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD } = process.env;

async function optimize() {
  const connection = await mysql.createConnection({
    host: DB_HOST,
    port: parseInt(DB_PORT || '3306', 10),
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME,
  });

  console.log("Starting deep database optimization...");

  const queries = [
    "ALTER TABLE Assembleias ADD INDEX idx_ass_cond (id_condominio)",
    "ALTER TABLE Votacoes ADD INDEX idx_vot_ass (id_assembleia)",
    "ALTER TABLE Votacoes ADD INDEX idx_vot_cond (id_condominio)",
    "ALTER TABLE Votacoes_Opcoes ADD INDEX idx_vo_vot (id_votacao)",
    "ALTER TABLE Votacoes_Usuarios ADD INDEX idx_vu_opc_user (id_opcao, id_user)",
    "ALTER TABLE Areas_Sociais ADD INDEX idx_as_cond (id_condominio)",
    "ALTER TABLE Agendamentos ADD INDEX idx_age_area (id_area)",
    "ALTER TABLE Agendamentos ADD INDEX idx_age_cond (id_condominio)",
    "ALTER TABLE Financeiro ADD INDEX idx_fin_cond_data (id_condominio, data, data_vencimento)",
    "ALTER TABLE Sindicos_Condominios ADD INDEX idx_sc_user_cond (id_user, id_condominio)",
    "ALTER TABLE Funcionarios ADD INDEX idx_func_user_cond (id_user, id_condominio)"
  ];

  for (const q of queries) {
    try {
      console.log(`Executing: ${q}`);
      await connection.query(q);
    } catch (e) {
      console.error(`Error: ${e.message}`);
    }
  }

  await connection.end();
  console.log("Optimization complete!");
}

optimize();
