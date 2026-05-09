const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, comunicado, user_id) {
    comunicado.titulo = comunicado.titulo.replaceAll("'","''");
    comunicado.descricao = comunicado.descricao.replaceAll("'","''");

    const query = `insert into Comunicados (titulo, descricao, user, id_condominio)
						values ('${comunicado.titulo}','${comunicado.descricao}','${user_id}','${id_condominio}')`;
    await db.query(query);
  },

  getAll: async function (id_cond, offset) {
    const query = `select id, titulo, descricao, DATE_FORMAT(created_at, '%d/%m/%Y %H:%i') as created_at from Comunicados
                      where id_condominio=${id_cond}
                    order by created_at asc`;

    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Comunicados where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, comunicado, user_id) {
    comunicado.titulo = comunicado.titulo.replaceAll("'","''");
    comunicado.descricao = comunicado.descricao.replaceAll("'","''");
    
    const query = `update Comunicados 
                     set titulo='${comunicado.titulo}',
                      descricao='${comunicado.descricao}',
                      user='${user_id}'
                    where id=${comunicado.id} and id_condominio=${id_condominio}`;
    await db.query(query);
  },

  get: async function (id_cond, id) {
    const query = `select id, titulo, descricao, DATE_FORMAT(created_at, '%d/%m/%Y %H:%i') as created_at from Comunicados
                      where id_condominio=${id_cond} and id=${id}`;
    const { results } = await db.query(query);
    return results[0];
  },
    
};
