const db = require('../database/DB_Ocorrencias.js');
const saveToAWS = require('../utils/saveToAWS');

module.exports = {
  async insert(req, res) {
    try {
      var listDocs = [];

      for (var i = 0; i < req.body.ocorrencia.docs.length; i++) {      
        const doc = req.body.ocorrencia.docs[i];
        const urlPhotoProfile = await saveToAWS(doc, `condominios/${req.body.id_condominio}/ocorrencias`, '');
        listDocs.push(urlPhotoProfile.url);
      }
      await db.insert(req.body.id_condominio, req.body.ocorrencia, req.session.user.id, listDocs);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      console.log('[ControllerOcorrencias.getAll] User:', req.session.user?.typeAccess, 'ID:', req.session.user?.id);
      if(req.session.user.typeAccess == 'Sindico' || req.session.user.typeAccess == 'Funcionario'){
        const result = await db.getAll(req.query.id_condominio, req.query.offset, '', null);
        return res.status(200).json(result);
      }else if(req.session.user.typeAccess == 'Morador'){
        const result = await db.getAll(req.query.id_condominio, req.query.offset, '', req.session.user.id);
        return res.status(200).json(result);
      } else {
        console.warn('[ControllerOcorrencias.getAll] Unknown typeAccess:', req.session.user.typeAccess);
        return res.status(200).json([]);
      }
    } catch (err) {
      console.error('[ControllerOcorrencias.getAll] Error:', err);
      return res.status(500).json({ message: err.message });
    }
  },

  async getAllPendentes(req, res) {
    try {
      if(req.session.user.typeAccess == 'Sindico' || req.session.user.typeAccess == 'Funcionario'){
        const result = await db.getAll(req.query.id_condominio, req.query.offset, 'pendente');
        return res.status(200).json(result);
      }else if(req.session.user.typeAccess == 'Morador'){
        const result = await db.getAll(req.query.id_condominio, req.query.offset, 'pendente', req.session.user.id);
        return res.status(200).json(result);
      } 
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAllCategorias(req, res) {
    try {
      const result = await db.getAllCategorias();
      return res.status(200).json(result);
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
      if(req.body.ocorrencia.isResposta && req.body.ocorrencia.isResposta == true){
        await db.setResposta(req.body.id_condominio, req.body.ocorrencia, req.session.user.id); 
      }else{
        var listDocs = [];
        for (var i = 0; i < req.body.ocorrencia.docs.length; i++) {      
          const doc = req.body.ocorrencia.docs[i];
          const urlPhotoProfile = await saveToAWS(doc, `condominios/${req.body.id_condominio}/ocorrencias`, '');
          listDocs.push(urlPhotoProfile.url);
        }
        await db.update(req.body.id_condominio, req.body.ocorrencia, req.session.user.id, listDocs); 
      } 
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async get(req, res) {
    try {
      const result = await db.get(req.query.id_condominio, req.query.id);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async updateStatus(req, res) {
    try {
      await db.updateStatus(req.body.id_condominio, req.body.id, req.body.status);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

};