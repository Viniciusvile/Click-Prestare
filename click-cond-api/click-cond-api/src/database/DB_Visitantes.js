const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, visitante, user_id) {
    visitante.nome = visitante.nome.replaceAll("'","''");
    
    const query = `insert into Visitantes (nome, doc_identificacao, data_hora_inicio, data_hora_termino, is_visitante, is_prestador, user, id_apartamento, id_condominio, avisar, foto_documento, foto_pessoa)
						values ('${visitante.nome}','${visitante.doc_identificacao}','${visitante.data_inicio}','${visitante.data_termino}',${visitante.is_visitante}, ${visitante.is_prestador}, ${user_id}, ${visitante.id_apartamento}, ${id_condominio}, 1, '${visitante.foto_documento || ''}', '${visitante.foto_pessoa || ''}')`;
            console.log(query);
    await db.query(query);
  },

  getAll: async function (id_cond, offset, id_apto, search) {
    const query = `select v.id, v.nome, v.doc_identificacao, 
                    DATE_FORMAT(v.data_hora_inicio, '%d/%m/%Y') as data_hora,
                    v.is_visitante, v.is_prestador, u.login,
                    apto.apto, apto.bloco as apto_bloco, apto.id as apto_id,
                    v.foto_documento, v.foto_pessoa
                    from Visitantes v
                    inner join Apartamentos apto on apto.id=v.id_apartamento
                    left join Users u on u.id=v.user
                    where v.id_condominio=${id_cond}
                      ${id_apto ? ` and v.id_apartamento=${id_apto}` : ''}    
                      ${search ? ` and (v.nome like '%${search}%' or v.doc_identificacao like '%${search}%' or apto.apto like '%${search}%')` : ''}                   
                    order by data_hora_inicio desc
                    limit 30 offset ${offset}`;
    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Visitantes where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, visitante) {
    visitante.nome = visitante.nome.replaceAll("'","''");

    const query = `update Visitantes 
                     set nome='${visitante.nome}',
                      doc_identificacao='${visitante.doc_identificacao}',
                      data_hora_inicio='${visitante.data_inicio}',
                      data_hora_termino='${visitante.data_termino}',
                      is_visitante=${visitante.is_visitante},
                      is_prestador=${visitante.is_prestador},
                      id_apartamento=${visitante.id_apartamento},
                      foto_documento='${visitante.foto_documento || ''}',
                      foto_pessoa='${visitante.foto_pessoa || ''}'
                    where id=${visitante.id} `;
                    console.log(query);
    await db.query(query);
  },
    
  get: async function (id_cond, id) {
    const query = `select v.id, v.nome, v.doc_identificacao, 
                      DATE_FORMAT(v.data_hora_inicio, '%d/%m/%Y %H:%i') as data_inicio, 
                      DATE_FORMAT(v.data_hora_termino, '%d/%m/%Y %H:%i') as data_termino, 
                      v.is_visitante, v.is_prestador,
                      v.foto_documento, v.foto_pessoa,
                      apto.apto, apto.bloco as apto_bloco, apto.id as apto_id
                    from Visitantes v
                    inner join Apartamentos apto on apto.id=v.id_apartamento
                      where v.id_condominio=${id_cond} and v.id=${id}`;
    const { results } = await db.query(query);
    return results[0];
  },
};
