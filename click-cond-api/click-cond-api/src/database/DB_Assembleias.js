const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, assembleia, user_id, listDocs) {
    assembleia.titulo = assembleia.titulo.replaceAll("'","''");
    assembleia.descricao = assembleia.descricao.replaceAll("'","''");
    assembleia.local = assembleia.local.replaceAll("'","''");

    const query = `insert into Assembleias (titulo, descricao, data, hora, local, link, id_condominio, user, anexos)
						values ('${assembleia.titulo}','${assembleia.descricao}','${assembleia.data}','${assembleia.hora}',
                    '${assembleia.local}','${assembleia.link}','${id_condominio}','${user_id}', '${listDocs.join(";")}')`;

    console.log(query);
    await db.query(query);
  },

  getAll: async function (id_cond, offset) {
    const query = `select id, titulo, descricao, DATE_FORMAT(data, '%d/%m/%Y') as data,
                      DATE_FORMAT(hora, '%H:%i') as hora
                      from Assembleias
                      where id_condominio=${id_cond}
                    order by data asc`;

    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Assembleias where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, assembleia, user_id, listDocs) {
    assembleia.titulo = assembleia.titulo.replaceAll("'","''");
    assembleia.descricao = assembleia.descricao.replaceAll("'","''");
    assembleia.local = assembleia.local.replaceAll("'","''");

    const query = `update Assembleias 
                     set titulo='${assembleia.titulo}',
                      descricao='${assembleia.descricao}',
                      data='${assembleia.data}',
                      hora='${assembleia.hora}',
                      local='${assembleia.local}',
                      link='${assembleia.link}',
                      user='${user_id}',
                      anexos='${listDocs.join(";")}'
                    where id=${assembleia.id} and id_condominio=${id_condominio}`;
    await db.query(query);
  },

  get: async function (id_cond, id) {
    const query = `select id, titulo, descricao,
                      DATE_FORMAT(data, '%d/%m/%Y') as data,
                      DATE_FORMAT(hora, '%H:%i') as hora,
                      link, local, anexos
                      from Assembleias
                      where id_condominio=${id_cond} and id=${id}`;
    const { results } = await db.query(query);
    return results[0];
  },

  insertVotacao: async function (votacao, id_condominio) {
    var query = "";
    if(votacao.is_enquete == false){
      votacao.titulo = votacao.titulo.replaceAll("'","''");
      query = `insert into Votacoes (titulo, data_inicio, data_termino, id_assembleia, id_condominio, is_enquete)
						values ('${votacao.titulo}',                   
                    '${votacao.data_inicio}',
                    '${votacao.data_termino}',
                    '${votacao.id_assembleia}',
                    '${id_condominio}',
                    false)`;  
    }else{
      votacao.titulo = votacao.titulo.replaceAll("'","''");
      votacao.descricao = votacao.descricao.replaceAll("'","''");
      query = `insert into Votacoes (titulo, descricao, data_inicio, data_termino, id_condominio, is_enquete)
						values ('${votacao.titulo}',                   
                    '${votacao.descricao}',     
                    '${votacao.data_inicio}',
                    '${votacao.data_termino}',
                    '${id_condominio}',
                    true)`;  
    }       

    console.log(query);
    await db.query(query);
  },

  insertVotacaoOpcoes: async function (opcoes) {
    let query = `insert into Votacoes_Opcoes (id_votacao, nome) values`;

    opcoes.forEach(e => {
      query += `( (select max(id) from Votacoes),'${e}' ),`
    });
            
    query = query.replace(/,(\s+)?$/, ''); 
    await db.query(query);
  },

  removeVotacao: async function (id) {
    const query = `delete from Votacoes where id=${id}`;
    await db.query(query);
  },

  finishVotacao: async function (id) {
    const query = `update Votacoes set data_termino=DATE_SUB(CURDATE(), INTERVAL 1 DAY) where id=${id}`;
    await db.query(query);
  },

  removeVotoAnterior: async function (id_votacao, user_id) {
    const query = `delete from Votacoes_Usuarios                              
                    where id_user=${user_id}
                    and id_opcao in (select id from Votacoes_Opcoes where id_votacao=${id_votacao})`;
    
    const res = await db.query(query);
  },

  insertVoto: async function (id_opcao, user_id) {
    const query = `insert into Votacoes_Usuarios (id_opcao, id_user)
						values (${id_opcao},${user_id})`;

    await db.query(query);
  },

  getAllVotacoes: async function (id_assembleia) {
    const query = `
                  select v.id, v.titulo, 
                      DATE_FORMAT(v.data_inicio, '%d/%m/%Y') as data_inicio,
                      DATE_FORMAT(v.data_termino, '%d/%m/%Y') as data_termino,
                      vo.nome,
                      group_concat(concat(vo.id, ";", vo.nome, ";", (select count(*) from Votacoes_Usuarios where id_opcao=vo.id)) order by vo.id asc SEPARATOR '*' ) as opcoes
                  from Votacoes v inner join Votacoes_Opcoes vo on v.id=vo.id_votacao
                      where v.id_assembleia=${id_assembleia} 
                      group by v.id`;

    const { results } = await db.query(query);   
    results.forEach(r => {
      r.opcoes = r.opcoes.split('*');
    });
        return results;
  },

  getAllMyVotos: async function (id_assembleia, id_user) {
    const query = `
                  select GROUP_CONCAT(id_opcao SEPARATOR ',') as meus_votos
                  from Votacoes_Usuarios vu 
                    inner join Votacoes_Opcoes vo on vu.id_opcao=vo.id
                    inner join Votacoes v on vo.id_votacao=v.id
                      where v.id_assembleia=${id_assembleia} 
                      and vu.id_user=${id_user}`;

    const { results } = await db.query(query);   
    return results[0].meus_votos != null ? results[0].meus_votos.split(",") : [];
  },

  getAllVotacoesEnquetes: async function (id_condominio) {
    const query = `
                  select v.id, v.titulo, v.descricao,
                      DATE_FORMAT(v.data_inicio, '%d/%m/%Y') as data_inicio, 
                      DATE_FORMAT(v.data_termino, '%d/%m/%Y') as data_termino,
                      vo.nome,
                      group_concat(concat(vo.id, ";", vo.nome, ";", (select count(*) from Votacoes_Usuarios where id_opcao=vo.id)) order by vo.id asc SEPARATOR '*' ) as opcoes
                  from Votacoes v inner join Votacoes_Opcoes vo on v.id=vo.id_votacao
                      where v.is_enquete = 1 and id_condominio=${id_condominio}
                      group by v.id`;
                      console.log(query);

    const { results } = await db.query(query);   
    results.forEach(r => {
      r.opcoes = r.opcoes.split('*');
    });
        return results;
  },

  getVotacaoEnquete: async function (id) {
    const query = `
                  select v.id, v.titulo, v.descricao,
                      DATE_FORMAT(v.data_inicio, '%d/%m/%Y') as data_inicio, 
                      DATE_FORMAT(v.data_termino, '%d/%m/%Y') as data_termino, 
                      vo.nome,
                      group_concat(concat(vo.id, ";", vo.nome, ";", (select count(*) from Votacoes_Usuarios where id_opcao=vo.id)) order by vo.id asc SEPARATOR '*' ) as opcoes
                  from Votacoes v inner join Votacoes_Opcoes vo on v.id=vo.id_votacao
                      where v.id = ${id}
                      group by v.id`;

    const { results } = await db.query(query);   
    results.forEach(r => {
      r.opcoes = r.opcoes.split('*');
    });
        return results[0];
  },

  getMyVoto: async function (id_votacao, id_user) {
    const query = `
                  select id_opcao
                  from Votacoes_Usuarios vu 
                    inner join Votacoes_Opcoes vo on vu.id_opcao=vo.id
                    inner join Votacoes v on vo.id_votacao=v.id
                      where v.id=${id_votacao} 
                      and vu.id_user=${id_user}`;

    const { results } = await db.query(query);
    return results[0] != null ? [results[0].id_opcao+""] : [];
  },
    
};
