const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, agenda, user_id) {
    agenda.titulo = agenda.titulo.replaceAll("'","''");
    agenda.descricao = agenda.descricao.replaceAll("'","''");
    const query = `insert into Agenda (titulo, descricao, data_inicio, data_termino, hora_inicio, hora_termino, alertar_moradores, user, id_condominio)
						values ('${agenda.titulo}','${agenda.descricao}','${agenda.data_inicio}','${agenda.data_termino}','${agenda.hora_inicio}','${agenda.hora_termino}',${agenda.alertar}, ${user_id}, ${id_condominio})`;
            
    await db.query(query).then((response) => {  
      if(response.status == 'Error'){
        if(response.error.sqlMessage.includes("date value")){
          throw new Error("Data inválida! Revise a data inserida e tente novamente!");
        }
        throw new Error("Revise os dados inseridos e tente novamente!");
      }
    });
  },

  getAll: async function (id_cond, offset) {
    const query = `select id, titulo, descricao, 
                    DATE_FORMAT(data_inicio, '%d/%m/%Y') as data_inicio,
                    DATE_FORMAT(hora_inicio, '%H:%i') as hora_inicio 
                    from Agenda
                      where id_condominio=${id_cond}
                    order by created_at desc`;
    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Agenda where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, agenda, user_id) {
    agenda.titulo = agenda.titulo.replaceAll("'","''");
    agenda.descricao = agenda.descricao.replaceAll("'","''");
    const query = `update Agenda 
                     set titulo='${agenda.titulo}',
                      descricao='${agenda.descricao}',
                      user='${user_id}',
                      data_inicio='${agenda.data_inicio}',
                      data_termino='${agenda.data_termino}',
                      hora_inicio='${agenda.hora_inicio}',
                      hora_termino='${agenda.hora_termino}',
                      alertar_moradores=${agenda.alertar}
                    where id=${agenda.id} and id_condominio=${id_condominio}`;
    
    await db.query(query).then((response) => {  
      if(response.status == 'Error'){
        if(response.error.sqlMessage.includes("date value")){
          throw new Error("Data inválida! Revise a data inserida e tente novamente!");
        }
        throw new Error("Revise os dados inseridos e tente novamente!");
      }
    });
    
  },
    
  get: async function (id_cond, id) {
    const query = `select id, titulo, descricao, alertar_moradores,
                    DATE_FORMAT(data_inicio, '%d/%m/%Y') as data_inicio,
                    DATE_FORMAT(data_termino, '%d/%m/%Y') as data_termino,
                    DATE_FORMAT(hora_inicio, '%H:%i') as hora_inicio,
                    DATE_FORMAT(hora_termino, '%H:%i') as hora_termino
                    from Agenda
                      where id_condominio=${id_cond} and id=${id}`;
    const { results } = await db.query(query);
    return results[0];
  },
};
