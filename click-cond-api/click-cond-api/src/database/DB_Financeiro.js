const db = require('./MySQL.js');

module.exports = {
  insert: async function (id_condominio, financeiro, name) {
    financeiro.nome = financeiro.nome.replaceAll("'","''");
    financeiro.descricao = financeiro.descricao.replaceAll("'","''");
    financeiro.tipo = financeiro.tipo.replaceAll("'","''");

    const query = `insert into Financeiro (nome, tipo, valor, data, data_vencimento, categoria, conta, descricao, cliente, forma_pagamento, parcelas, nome_operador, id_condominio, photo, pago)
						values ('${financeiro.nome}',
                    '${financeiro.tipo}',
                    '${financeiro.valor}',
                    '${financeiro.data != null ? financeiro.data : financeiro.data_vencimento != null ? financeiro.data_vencimento : null}',
                    ${financeiro.data_vencimento != null ? `'${financeiro.data_vencimento}'` : null},
                    '${financeiro.categoria}',
                    ${financeiro.conta != null ? `'${financeiro.conta}'` : null},
                    ${financeiro.descricao != null ? `'${financeiro.descricao}'` : null},
                    ${financeiro.cliente != null ? `'${financeiro.cliente}'` : null},
                    ${financeiro.forma_pagamento != null ? `'${financeiro.forma_pagamento}'` : null},
                    ${financeiro.parcelas != null ? `'${financeiro.parcelas}'` : null},
                    '${name}',
                    ${id_condominio},
                    '${financeiro.photo}',
                    ${financeiro.data == null || financeiro.data=="" ? 0 : 1}
                  )`;
    await db.query(query);
  },

  getAll: async function (id_cond, mes, ano, getPendentes) {
    const query = `select t1.id, t1.nome, t1.tipo, t1.valor, t1.categoria, t1.nome_operador, t1.pago,
                      DATE_FORMAT(t1.data, '%d') as dia,
                      DATE_FORMAT(t1.data, '%m') as mes,
                      DATE_FORMAT(t1.data, '%Y') as ano
                    from Financeiro as t1
                    where t1.id_condominio=${id_cond} 
                      and t1.data<='${ano}-${mes}-31'
                      ${getPendentes == false ? 'and t1.pago=1' : ''}
                    group by t1.data, t1.created_at
                    order by t1.data asc`;
    const { results } = await db.query(query);
    return results;
  },

  getAllGrafico: async function (id_cond, mes, ano) {
    const query = `select t1.id, t1.nome, t1.tipo, t1.valor, t1.categoria, t1.pago,
                      DATE_FORMAT(t1.data, '%d') as dia,
                      DATE_FORMAT(t1.data, '%m') as mes,
                      DATE_FORMAT(t1.data, '%Y') as ano
                    from Financeiro as t1
                    where t1.id_condominio=${id_cond} 
                      and t1.data<='${ano}-${mes}-31' 
                      and t1.data>='${ano}-${mes}-01' 
                      and t1.pago = 1
                    order by t1.categoria asc`;
    const { results } = await db.query(query);
    return results;
  },

  getAllMoradores: async function (id_cond, mes, ano) {
    const query = `select a.id as apto_id, a.bloco, a.apto, 
                      f.valor, f.id as financeiro_id, DATE_FORMAT(f.data, '%d/%m/%Y') as data, DATE_FORMAT(f.data_vencimento, '%d/%m/%Y') as data_vencimento, f.conta, f.descricao, f.pago
                    from Apartamentos a
                    left join Financeiro f on (f.nome=concat('Apto ',a.apto,' Bloco ', a.bloco, ' - Ref. ', '${mes}', '/', '${ano}') and f.id_condominio=a.id_condominio)
                      where a.id_condominio=${id_cond} 
                    group by a.bloco, a.apto 
                    order by a.bloco, a.apto asc`;
    const { results } = await db.query(query);
    return results;
  },

  getAllInadimplentes: async function (id_cond, meses) {
    const query = `select a.bloco, a.apto, ${meses.length} - count(distinct f.nome) as qtd
                    from Apartamentos a
                    left join Financeiro f on (
                      f.nome in (
                          ${ meses.map(mes =>
                            `concat('Apto ',a.apto,' Bloco ', a.bloco, ' - Ref. ', '${mes.mes}', '/', '${mes.ano}')`
                          )}                       
                        ) 
                      and 
                      f.id_condominio=${id_cond}
                      and f.pago=1
                    )
                      where a.id_condominio=${id_cond}
                    group by a.bloco, a.apto 
                    having count(distinct f.nome)!=${meses.length}`;
                    console.log(query);
    const { results } = await db.query(query);
    return results;
  },

  getInadimplenteDetail: async function (id_cond, meses, apto, bloco) {
    // meses.pop();
    console.log(meses);
    const query = `select a.bloco, a.apto, f.nome
                    from Apartamentos a
                    left join Financeiro f on(
                        f.nome in (
                            ${ meses.map(mes =>
                              `concat('Apto ',a.apto,' Bloco ', a.bloco, ' - Ref. ', '${mes.mes}', '/', '${mes.ano.slice(-2)}')`
                            )}                       
                          ) 
                        and 
                        f.id_condominio=${id_cond}
                      )
                      where a.id_condominio=${id_cond} and a.apto='${apto}' and a.bloco='${bloco}'
                    `;
                    console.log(query);
    const { results } = await db.query(query);
    console.log(results);
    var arr = [];
    meses.forEach(mes => {
      var contains = false;
      results.forEach(result => {
        if(result.nome != null && result.nome.includes(mes.mes+'/'+mes.ano.slice(-2))){
          contains = true;
        }        
      })
      if(!contains){
        arr.push(mes);
      }
    });
    return arr;
  },

  getAllMeses: async function (id_cond) {
    const query = `select 
                      distinct DATE_FORMAT(t1.data, '%m/%y') as periodo,
                      DATE_FORMAT(t1.data, '%m') as mes,
                      DATE_FORMAT(t1.data, '%Y') as ano
                    from Financeiro as t1
                    where t1.id_condominio=${id_cond}
                    order by t1.data asc `;
    const { results } = await db.query(query);
    return results;
  },

  remove: async function (id) {
    const query = `delete from Financeiro where id=${id}`;
    await db.query(query);
  },

  update: async function (id_condominio, financeiro, name) {
    financeiro.nome = financeiro.nome.replaceAll("'","''");
    financeiro.descricao = financeiro.descricao.replaceAll("'","''");
    financeiro.tipo = financeiro.tipo.replaceAll("'","''");
    
    const query = `update Financeiro 
                     set nome='${financeiro.nome}',
                      tipo='${financeiro.tipo}',
                      valor='${financeiro.valor}',
                      data='${financeiro.data != null ? financeiro.data : financeiro.data_vencimento != null ? financeiro.data_vencimento : null}',
                      data_vencimento=${financeiro.data_vencimento != null ? `'${financeiro.data_vencimento}'` : null},
                      categoria='${financeiro.categoria}',
                      conta=${financeiro.conta != null ? `'${financeiro.conta}'` : null},
                      descricao=${financeiro.descricao != null ? `'${financeiro.descricao}'` : null},
                      cliente=${financeiro.cliente != null ? `'${financeiro.cliente}'` : null},
                      forma_pagamento=${financeiro.forma_pagamento != null ? `'${financeiro.forma_pagamento}'` : null},
                      parcelas=${financeiro.parcelas != null ? `'${financeiro.parcelas}'` : null},
                      nome_operador='${name}',
                      pago=${financeiro.data == null || financeiro.data=="" ? 0 : 1}
                    where id=${financeiro.id} and id_condominio=${id_condominio}`;
    await db.query(query);
  },

  updatePhoto: async function (url, id){
    const query = `update Financeiro set photo='${url}' where id='${id}' `;
    await db.query(query);
  },

  get: async function (id_cond, id) {
    const query = `select id, 
                        nome, 
                        tipo,
                        valor, 
                        DATE_FORMAT(data_vencimento, '%d/%m/%Y') as data_vencimento,
                        DATE_FORMAT(data, '%d/%m/%Y') as data,
                        categoria, 
                        conta,
                        descricao, 
                        cliente,
                        forma_pagamento,
                        parcelas,
                        photo,
                        pago
                      from Financeiro
                      where id_condominio=${id_cond} and id=${id}`;
    const { results } = await db.query(query);
    return results[0];
  },

  getLastUpdate: async function (id_cond) {
    const query = `select DATE_FORMAT(created_at, '%d/%m/%Y') as data
                      from Financeiro
                    where id_condominio=${id_cond}
                    order by id desc limit 1`;
    const { results } = await db.query(query);
    if(results.length == 0){
      return "-";
    }
    return results[0].data;
  },
    
};
