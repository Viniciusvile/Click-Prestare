const db = require('./MySQL.js');
const { default: slugify } = require('slugify');

module.exports = {
  insertUser: async function(email, password, photo){
    const query = `insert into Users (login, password, is_sindico)
                        values ('${email}',  MD5('${password}'), 1)`;

    const response = await db.query(query);
    
    if(response.status == 'Error'){
      if (response.error.sqlMessage && response.error.sqlMessage.includes('user_login')) {
        throw new Error('E-mail já cadastrado!');
      }
      throw new Error('Houve um erro ao realizar o seu cadastro. Por favor, tente novamente!');
    }

    return response.results.insertId;
  },

  insertSindico: async function (nome, email, date_birth, phone, doc_identification, userId) {
    date_birth = date_birth.split("/");
    date_birth = date_birth[2]+"-"+date_birth[1]+"-"+date_birth[0];

    nome = nome.replaceAll("'","''");

    const querySindico = `insert into Sindicos (
            name, email, date_birth, phone, doc_identification, id_user)
            values ('${nome}','${email}','${date_birth}','${phone}','${doc_identification}', '${userId}')`;
    await db.query(querySindico);
  },

  updateSindico: async function (nome, email, date_birth, phone, doc_identification, userId) {
    date_birth = date_birth.split("/");
    date_birth = date_birth[2]+"-"+date_birth[1]+"-"+date_birth[0];

    nome = nome.replaceAll("'","''");
    
    const querySindico = `update Sindicos set 
                     name='${nome}',
                     email='${email}',
                     date_birth='${date_birth}',
                     phone='${phone}',
                     doc_identification='${doc_identification}'                   
                    where id_user=${userId}`;
    await db.query(querySindico);
  },

  login: async function (login, password) {
    const query = `select u.id, s.name, u.photo                           
                    from Sindicos s 
                    inner join Users u on u.id = s.id_user
                    where u.login='${login}' and password=MD5('${password}')`;
    const result = await db.query(query);
    if (!result.results[0]) {
      throw new Error('Login ou Senha incorretos');
    }
    return result.results[0];
  },

  internalLogin: async function (login) {
    const query = `select u.id, s.name, u.photo                           
                    from Sindicos s 
                    inner join Users u on u.id = s.id_user
                    where u.login='${login}'`;
    const result = await db.query(query);
    if (!result.results[0]) {
      throw new Error('Login ou Senha incorretos');
    }
    return result.results[0];
  },

  recoveryPassword: async function (email) {
    const query = `select count(id) as count
                            from Authors  
                            where email='${email}'`;
    const result = await db.query(query);
    if (result.results[0].count == 0) {
      throw new Error('Usuário não localizado!');
    }
  },

  setNewPassword: async function (email, password) {
    const query = `update Authors set password=MD5('${password}') where email='${email}' `;
    await db.query(query);
  },  

  
  listCondominios: async function (id) {
    const query = `select c.id, c.num_blocos, c.moeda,
                    DATE_FORMAT(c.updated_at, '%d/%m/%Y às %H:%i') as updatedAt, 
                    c.nome, c.photo, sum(f.valor) as saldo,
                    (select count(id) from Apartamentos where id_condominio=c.id) as num_aptos,
                    DATE_FORMAT(c.vencimento, '%d/%m/%Y') as vencimento_condominio,
                    (DATEDIFF(c.vencimento, NOW()) + 1) as dias_restantes_condominio
                    from Sindicos_Condominios sc
                      inner join Condominios c on sc.id_condominio = c.id
                      left join Financeiro f on (f.id_condominio=c.id and f.pago=1 )
                      where sc.id_user=${id} and c.ativo=1
                    group by c.id
                    order by c.created_at desc`;
    const { results } = await db.query(query);
    return results;
  }, 
  
  getData: async function (id) {
    const query = `select name, email,  DATE_FORMAT(date_birth, '%d/%m/%Y') as date_birth, phone, doc_identification from Sindicos where id_user=${id}`;    
    const { results } = await db.query(query);
    return results[0];
  }, 
};

