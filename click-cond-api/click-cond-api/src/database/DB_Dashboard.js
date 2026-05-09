const db = require('./MySQL.js');
const doubleToReal = require('../utils/doubleToReal.js');


module.exports = {
  getAllCondominios: async function () {
    var query = `select distinct c.id, c.nome, c.identificacao, c.num_aptos, c.num_blocos, c.photo,
                    concat(e.pais, " - ", e.uf, ', ', e.rua, ' - ', e.numero) as endereco,
                      count(distinct ap.id) as count_aps, count(distinct ap.bloco) as count_blocos,
                      s.name as sindico_nome, s.email as sindico_email, s.phone as sindico_phone,
                      count(distinct doc.id) as count_doc,
                      count(distinct comu.id) as count_comunicados,
                      count(distinct finan.id) as count_financeiro, 
                      count(distinct func.id_user) as count_funcionarios, 
                      count(distinct manut.id) as count_manutencoes,
                      count(distinct visit.id) as count_visitantes, 
                      count(distinct ass.id) as count_assembleias, 
                      count(distinct prest.id) as count_prestadores,
                      count(distinct ocor.id) as count_ocorrencias,
                      count(distinct ap_users.id_user) as count_moradores
                                            
                    from Condominios c
                            inner join Endereco e on e.id = c.endereco
                            inner join Apartamentos ap on ap.id_condominio = c.id
                            left join Sindicos_Condominios sc on sc.id_condominio = c.id
                            left join Sindicos s on s.id_user = sc.id_user
                                
                            left join Documentos doc on doc.id_condominio = c.id
                            left join Areas_Sociais areas on areas.id_condominio = c.id
                            left join Comunicados comu on comu.id_condominio = c.id
                            left join Financeiro finan on finan.id_condominio = c.id
                            left join Funcionarios func on func.id_condominio = c.id
                            left join Manutencoes manut on manut.id_condominio = c.id
                            left join Visitantes visit on visit.id_condominio = c.id
                            left join Assembleias ass on ass.id_condominio = c.id
                            left join Prestadores_servico prest on prest.id_condominio = c.id
                            left join Ocorrencias ocor on ocor.id_condominio = c.id
                            left join Apartamentos_Users ap_users on ap_users.id_apto = ap.id
                                
                    group by c.id`;
    const { results } = await db.query(query);
    return results;             
  },

  getCountCondominio: async function () {
    var query = `select count(id) as count from Condominios`;
    const { results } = await db.query(query);
    return results[0];         
  },

  getCountApartamentos: async function () {
    var query = `select count(ap.id) as count from Apartamentos ap`;
    const { results } = await db.query(query);
    return results[0];     
  },

  getCountMoradores: async function () {
    var query = `select count(ap.id_apto) as count from Apartamentos_Users ap`;
    const { results } = await db.query(query);
    return results[0];           
  },

  getCondominiosDia: async function () {
    var query = `select DATE_FORMAT(c.created_at, '%d/%m/%Y') as 'Dia', count(*) as 'Quantidade'
                  from Condominios c
                  group by Dia 
                  order by c.created_at DESC`;
    const { results } = await db.query(query);
    return results;             
  },

  getCondominiosLocalidade: async function () {
    var query = `select concat(e.pais, " - ", e.uf) as 'local', count(*) as 'Quantidade'
                    from Condominios c
                        inner join Endereco e on e.id = c.endereco
                    group by local`;
    const { results } = await db.query(query);
    return results;             
  },

};
