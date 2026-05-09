const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, manutencao, user_id, listDocs) {
    manutencao.descricao = manutencao.descricao.replaceAll("'","''");
    const query = `insert into Manutencoes (descricao, anexos, user, id_condominio)
						values ('${manutencao.descricao}','${listDocs.join(";")}', ${user_id}, ${id_condominio})`;
            console.log(query);
    await db.query(query);
  },

  getAll: async function (id_cond, offset) {
    const query = `select id, descricao, anexos, status,
                    DATE_FORMAT(created_at, '%d/%m/%Y às %h:%i') as created_at
                    from Manutencoes
                      where id_condominio=${id_cond}
                    order by created_at desc`;
                    console.log(query);
    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Manutencoes where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, manutencao, user_id, listDocs) {
    manutencao.descricao = manutencao.descricao.replaceAll("'","''");
    
    const query = `update Manutencoes 
                     set descricao='${manutencao.descricao}',
                      anexos='${listDocs.join(";")}',
                      user='${user_id}'  
                    where id=${manutencao.id} and id_condominio=${id_condominio}`;
    await db.query(query);
  },
    
  get: async function (id_cond, id) {
    const query = `select id, descricao, anexos, created_at from Manutencoes
                      where id_condominio=${id_cond} and id=${id}`;
    const { results } = await db.query(query);
    return results[0];
  },

  updateStatus: async function (id_condominio, id, status) {
    const query = `update Manutencoes 
                     set status='${status}'
                     where id=${id} and id_condominio=${id_condominio}`;
    await db.query(query);
  },
};
