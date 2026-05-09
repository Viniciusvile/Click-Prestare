const db = require('../database/DB_Documents.js');
const saveToAWS = require('../utils/saveToAWS');

module.exports = {
  async insert(req, res) {
    try {
      if(req.body.documento.doc){
        const urlPhotoProfile = await saveToAWS(req.body.documento.doc, `condominios/${req.body.id_condominio}/docs`, req.body.documento.is_ata ? 'ata' : 'doc');
        req.body.documento.link_doc = urlPhotoProfile.url;
      }      
      await db.insert(req.body.id_condominio, req.body.documento);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      const cond = await db.getAll(req.query.id_condominio, req.query.is_ata);
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

};