require('dotenv').config();
const db = require('./src/database/MySQL.js');

async function testQuery() {
  console.log('Testing Ocorrencias query...');
  console.log('DB Config:', {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
  });

  // First, check if Ocorrencias table has data
  const countResult = await db.query('SELECT COUNT(*) as total FROM Ocorrencias WHERE id_condominio=1');
  console.log('Ocorrencias count:', countResult);

  // Check categories
  const catResult = await db.query('SELECT * FROM Ocorrencias_Categorias');
  console.log('Categories:', catResult);

  // Test the actual query used by getAll
  const query = `select o.id, o.descricao, o.anexos, o.status, COALESCE(oc.nome, 'Outros') as tipo, o.resposta, u.login,
                    DATE_FORMAT(o.created_at, '%d/%m/%Y às %H:%i') as created_at,
                    DATE_FORMAT(o.resposta_at, '%d/%m/%Y às %H:%i') as resposta_at
                    from Ocorrencias o
                      left join Ocorrencias_Categorias oc on o.tipo = oc.id
                      left join Users u on u.id=o.\`user\`
                    where o.id_condominio=1
                    order by COALESCE(oc.prioridade, 99), FIELD(o.status, 'Pendente', 'Ciente', 'Solucionado'), o.created_at desc`;
  
  const result = await db.query(query);
  console.log('Query status:', result.status);
  console.log('Results count:', result.results?.length);
  if (result.status === 'Error') {
    console.error('SQL Error:', result.error);
  } else {
    console.log('First 3 results:', JSON.stringify(result.results?.slice(0, 3), null, 2));
  }

  process.exit(0);
}

testQuery().catch(e => { console.error(e); process.exit(1); });
