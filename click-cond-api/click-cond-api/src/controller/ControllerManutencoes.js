const db = require('../database/DB_Manutencoes.js');
const saveToAWS = require('../utils/saveToAWS');

module.exports = {
  async insert(req, res) {
    try {
      var listDocs = [];
      for (var i = 0; i < req.body.manutencao.docs.length; i++) {      
        const doc = req.body.manutencao.docs[i];
        const urlPhotoProfile = await saveToAWS(doc, `condominios/${req.body.id_condominio}/manutencoes`, '');
        listDocs.push(urlPhotoProfile.url);
      }
      await db.insert(req.body.id_condominio, req.body.manutencao, req.session.user.id, listDocs);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      const result = await db.getAll(req.query.id_condominio, req.query.offset);
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
      var listDocs = [];
      for (var i = 0; i < req.body.manutencao.docs.length; i++) {      
        const doc = req.body.manutencao.docs[i];
        const urlPhotoProfile = await saveToAWS(doc, `condominios/${req.body.id_condominio}/manutencoes`, '');
        listDocs.push(urlPhotoProfile.url);
      }
      await db.update(req.body.id_condominio, req.body.manutencao, req.session.user.id, listDocs);
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