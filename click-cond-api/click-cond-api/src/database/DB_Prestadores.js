const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, prestador) {
    prestador.nome = prestador.nome.replaceAll("'","''");

    const query = `insert into Prestadores_servico (nome, telefone, categorias, id_condominio)
						values ('${prestador.nome}','${prestador.telefone}', '${prestador.categorias}', ${id_condominio})`;

    console.log(query);
    await db.query(query);
  },

  getAll: async function (id_cond, offset) {
    const query = `select id, nome, telefone, categorias from Prestadores_servico
                      where id_condominio=${id_cond}
                    order by created_at desc`;
    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Prestadores_servico where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, prestador) {
    prestador.nome = prestador.nome.replaceAll("'","''");
    
    const query = `update Prestadores_servico 
                     set nome='${prestador.nome}',
                     telefone='${prestador.telefone}',
                     categorias='${prestador.categorias}'  
                    where id=${prestador.id} and id_condominio=${id_condominio}`;
                    console.log(query);

    await db.query(query);
  },
    
  get: async function (id_cond, id) {
    const query = `select id, nome, telefone, categorias from Prestadores_servico
                      where id_condominio=${id_cond} and id=${id}`;
    const { results } = await db.query(query);
    return results[0];
  },
};
