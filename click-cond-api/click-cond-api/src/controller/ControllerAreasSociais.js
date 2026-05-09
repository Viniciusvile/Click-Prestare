const { insertAgendamento } = require('../database/DB_AreasSociais.js');
const db = require('../database/DB_AreasSociais.js');
const saveToAWS = require('../utils/saveToAWS');
const stringExtension = require('../utils/stringExtension.js');

module.exports = {
  async insert(req, res) {
    try {
      if(req.body.areaSocial.imagem != null){
        const urlPhotoProfile = await saveToAWS(req.body.areaSocial.imagem, `condominios/${req.body.id_condominio}/areas-sociais`, 'area-social');
        req.body.areaSocial.imagem = urlPhotoProfile.url;
      }
      await db.insert(req.body.id_condominio, req.body.areaSocial);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      const cond = await db.getAll(req.query.id_condominio, req.query.offset);
      return res.status(200).json(cond);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async remove(req, res) {
    try {
      await db.remove(req.body.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async update(req, res) {
    try {
      if(req.body.areaSocial.imagem != null){
        const urlPhotoProfile = await saveToAWS(req.body.areaSocial.imagem, `condominios/${req.body.id_condominio}/areas-sociais`, 'area-social');
        req.body.areaSocial.imagem = urlPhotoProfile.url;
      }
      await db.update(req.body.id_condominio, req.body.areaSocial, req.session.user.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async get(req, res) {
    try {
      const result = await db.get(req.query.id_condominio, req.query.id);
      const agendamentos = await db.getAgendamentosFromArea(req.query.id);
      result.horarios = JSON.parse(result.horarios);
      result.agendamentos = agendamentos;
      
      var horariosLivres = {};
      var date = new Date(); 
      for(var i=0; i<60; i++){
        date.setDate(date.getDate() + 1);
        const dateFormat = stringExtension.formatDateToString(date);
        const weekDay = date.getDay()-1 < 0 ? 6 : date.getDay()-1;
        if(result.horarios[weekDay].horarios.length > 0){
          horariosLivres[dateFormat] = result.horarios[weekDay].horarios;          
        }
      }
      
      result.agendamentos.slice().reverse().forEach((agendamento) => {        
        const data = agendamento.data;     
        console.log(data);
        if(horariosLivres[data] != null){
          horariosLivres[data].forEach((horario, j) => {          
            if(horario.horarioDe == agendamento.horaDe && horario.horarioAte == agendamento.horaAte){             
              var aux = horariosLivres[data].slice(0);   
              aux.splice(j, 1);
              horariosLivres[data] = aux;     
            }
            if(horariosLivres[data].length == 0){
              delete horariosLivres[data];
            }
          });   
        }
      });
      
      result.horarios_livres = horariosLivres;
      
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async insertAgendamento(req, res){
    try {
      const result = await db.insertAgendamento(req.body.agendamento, req.session.user.id);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async removeAgendamento(req, res) {
    try {
      await db.removeAgendamento(req.body.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async updateAgendamento(req, res) {
    try {      
      await db.updateAgendamento(req.body.agendamento);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAllAgendamentos(req, res) {
    try {
      const cond = await db.getAllAgendamentos(req.query.id_condominio);
      return res.status(200).json(cond);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAllMeusAgendamentos(req, res) {
    try {
      const cond = await db.getAllMeusAgendamentos(req.query.id_condominio, req.query.id_apto);
      return res.status(200).json(cond);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async updateStatusAgendamento(req, res) {
    try {
      await db.updateStatusAgendamento(req.body.agendamento,id, req.body.id, req.body.agendamento.status, req.body.agendamento.motivo);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async insertManutencao(req, res){
    try {
      const result = await db.insertManutencao(req.body.manutencao);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async updateManutencao(req, res) {
    try {      
      await db.updateManutencao(req.body.manutencao);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async removeManutencao(req, res) {
    try {
      await db.removeManutencao(req.body.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

};