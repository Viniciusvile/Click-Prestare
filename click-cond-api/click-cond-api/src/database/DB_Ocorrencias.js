const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, ocorrencia, user_id, listDocs) {
    ocorrencia.descricao = ocorrencia.descricao.replaceAll("'","''");
   
    const query = `insert into Ocorrencias (descricao, anexos, user, id_condominio, tipo)
						values ('${ocorrencia.descricao}','${listDocs.join(";")}', ${user_id}, ${id_condominio}, '${ocorrencia.tipo}')`;
    await db.query(query);
  },

  getAll: async function (id_cond, offset, status, idUser) {
    const query = `select o.id, o.descricao, o.anexos, o.status, COALESCE(oc.nome, 'Outros') as tipo, o.resposta, u.login,
                    DATE_FORMAT(o.created_at, '%d/%m/%Y às %H:%i') as created_at,
                    DATE_FORMAT(o.resposta_at, '%d/%m/%Y às %H:%i') as resposta_at
                    from Ocorrencias o
                      left join Ocorrencias_Categorias oc on o.tipo = oc.id
                      left join Users u on u.id=o.\`user\`
                    where o.id_condominio=${id_cond}
                      ${status == 'pendente' ? ` and o.status='Pendente'` : ''}
                      ${idUser != null ? ` and (o.\`user\`=${idUser} OR o.\`user\` IS NULL)` : ''}
                    order by COALESCE(oc.prioridade, 99), FIELD(o.status, 'Pendente', 'Ciente', 'Solucionado'), o.created_at desc
                    limit 30 offset ${offset || 0}`;
    console.log('[DB_Ocorrencias.getAll] Query:', query.substring(0, 300));
    const result = await db.query(query);
    console.log('[DB_Ocorrencias.getAll] Status:', result.status, 'Count:', result.results?.length);
    if (result.status === 'Error') {
      console.error('[DB_Ocorrencias.getAll] SQL Error:', result.error?.sqlMessage || result.error?.message);
    }
    return result.results;
  },

  remove: async function (id) {
    const query = `delete from Ocorrencias where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, ocorrencia, user_id, listDocs) {
    ocorrencia.descricao = ocorrencia.descricao.replaceAll("'","''");

    const query = `update Ocorrencias 
                     set descricao='${ocorrencia.descricao}',
                      anexos='${listDocs.join(";")}',
                      user='${user_id}'  
                    where id=${ocorrencia.id} and id_condominio=${id_condominio}`;
                    console.log(query);

    await db.query(query);
  },

  setResposta: async function (id_condominio, ocorrencia, user_id) {
    ocorrencia.descricao = ocorrencia.descricao.replaceAll("'","''");
    
    const query = `update Ocorrencias 
                     set resposta='${ocorrencia.descricao}',
                         status='${ocorrencia.status}',
                         resposta_at=now()
                    where id=${ocorrencia.id} and id_condominio=${id_condominio}`;
                    console.log(query);

    await db.query(query);
  },
    
  get: async function (id_cond, id) {
    const query = `select o.id, o.descricao, o.anexos, o.status, COALESCE(oc.nome, 'Outros') as tipo, oc.id as tipoId, o.resposta,
                    DATE_FORMAT(o.created_at, '%d/%m/%Y às %H:%i') as created_at,
                    DATE_FORMAT(o.resposta_at, '%d/%m/%Y às %H:%i') as resposta_at
                    from Ocorrencias o
                      left join Ocorrencias_Categorias oc on o.tipo = oc.id
                    where o.id_condominio=${id_cond} and o.id=${id}`;
                    console.log(query);
    const { results } = await db.query(query);
    return results[0];
  },

  updateStatus: async function (id_condominio, id, status) {
    const query = `update Ocorrencias 
                     set status='${status}'
                     where id=${id} and id_condominio=${id_condominio}`;
    await db.query(query);
  },

  getAllCategorias: async function () {
    const query = `select * from Ocorrencias_Categorias`;
    const { results } = await db.query(query);
    return results;
  },

  getCreatorId: async function (id) {
    const query = `SELECT user FROM Ocorrencias WHERE id = ${id}`;
    const { results } = await db.query(query);
    return results[0]?.user;
  },
};
