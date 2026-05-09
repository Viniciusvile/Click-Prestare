const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, mudanca, user_id) {
    const query = `insert into Mudancas (data, hora_inicio, user, id_apartamento, id_condominio)
						values ('${mudanca.data}','${mudanca.hora_inicio}', ${user_id}, '${mudanca.id_apartamento}', ${id_condominio})`;
    await db.query(query);
  },

  getAll: async function (id_cond, offset, id_apto) {
    const query = `select m.id, 
                      DATE_FORMAT(m.data, '%d/%m/%Y') as data, 
                      DATE_FORMAT(m.hora_inicio, '%H:%i') as hora, 
                      m.motivo_recusa, m.status,
                      apto.apto, apto.bloco as apto_bloco, apto.id as apto_id
                    from Mudancas m
                      inner join Apartamentos apto on apto.id=m.id_apartamento
                      where m.id_condominio=${id_cond}
                        ${id_apto ? ` and m.id_apartamento=${id_apto}` : ''}
                        and m.data>DATE_SUB(NOW(), INTERVAL 1 DAY)
                    order by m.data asc`;
    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Mudancas where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, mudanca) {
    const query = `update Mudancas 
                     set data='${mudanca.data}',
                      hora_inicio='${mudanca.hora_inicio}',
                      id_apartamento='${mudanca.id_apartamento}'
                    where id=${mudanca.id} and id_condominio=${id_condominio}`;
                    console.log(query);
    await db.query(query);
  },

  updateStatus: async function (id_condominio, id, isAccept, text) {
    const status = isAccept ? `aceito` : `recusado`;
    const query = `update Mudancas 
                     set status='${status}',
                     motivo_recusa= '${text}'
                    where id=${id} `;
                    console.log(query);
    await db.query(query);
  },
    
  get: async function (id_cond, id) {
    const query = `select m.id, DATE_FORMAT(m.data, '%d/%m/%Y') as data,
                    DATE_FORMAT(m.hora_inicio, '%H:%i') as hora_inicio, m.status,
                     apto.apto, apto.bloco as apto_bloco, apto.id as apto_id
                   from Mudancas m
                      inner join Apartamentos apto on apto.id=m.id_apartamento
                      where m.id_condominio=${id_cond} and m.id=${id}`;
                      console.log(query);

    const { results } = await db.query(query);
    return results[0];
  },
};
