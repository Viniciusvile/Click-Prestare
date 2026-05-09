const db = require('../database/DB_Assembleias.js');
const db_docs = require('../database/DB_Documents.js');

const saveToAWS = require('../utils/saveToAWS');

module.exports = {
  async insert(req, res) {
    try {
      var listDocs = [];
      for (var i = 0; i < req.body.assembleia.docs.length; i++) {      
        const doc = req.body.assembleia.docs[i];
        const urlPhotoProfile = await saveToAWS(doc, `condominios/${req.body.id_condominio}/assembleias`, '');
        listDocs.push(urlPhotoProfile.url);
      }
      await db.insert(req.body.id_condominio, req.body.assembleia, req.session.user.id, listDocs);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async finish(req, res) {
    try {
      let doc = {is_ata:true, nome: `ATA ${req.body.assembleia.titulo} - ${req.body.assembleia.data}`, link_doc:''}
      if(req.body.assembleia.doc){
        const urlPhotoProfile = await saveToAWS(req.body.assembleia.doc, `condominios/${req.body.id_condominio}/docs`, 'ata');
        doc.link_doc = urlPhotoProfile.url;
      }
      await db_docs.insert(req.body.id_condominio, doc);
      await db.remove(req.body.assembleia.id);
      return res.json({ message: 'Assembléia Finalizada!\nA ATA se encontra disponível no menu "Docs" na tela de seu condomínio.' });
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async insertVotacao(req, res) {
    try {     
      await db.insertVotacao(req.body.votacao, req.body.id_condominio);
      await db.insertVotacaoOpcoes(req.body.votacao.opcoes);
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

  async removeVotacao(req, res) {
    try {
      await db.removeVotacao(req.body.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async finishVotacao(req, res) {
    try {
      await db.finishVotacao(req.body.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async update(req, res) {
    try {
      var listDocs = [];
      for (var i = 0; i < req.body.assembleia.docs.length; i++) {      
        const doc = req.body.assembleia.docs[i];
        const urlPhotoProfile = await saveToAWS(doc, `condominios/${req.body.id_condominio}/assembleias`, '');
        listDocs.push(urlPhotoProfile.url);
      }
      await db.update(req.body.id_condominio, req.body.assembleia, req.session.user.id, listDocs);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async get(req, res) {
    try {
      const result = await db.get(req.query.id_condominio, req.query.id);
      const votacoes = await db.getAllVotacoes(req.query.id);
      const meusVotos = await db.getAllMyVotos(req.query.id, req.session.user.id);
      for(var i=votacoes.length-1; i>=0; i--){
        votacoes[i].status = getStatusAsInt(votacoes[i]);
      }
      return res.status(200).json({assembleia: result, votacoes: votacoes, meusVotos:meusVotos});
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async registerVoto(req, res) {
    try {     
      await db.removeVotoAnterior(req.body.voto.votacao_id, req.session.user.id);
      await db.insertVoto(req.body.voto.opcao_id, req.session.user.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async enqueteGetAll(req, res) {
    try {
      const votacoes = await db.getAllVotacoesEnquetes(req.query.id_condominio);
      for(var i=votacoes.length-1; i>=0; i--){
        votacoes[i].status = getStatusAsInt(votacoes[i]);
      }

      return res.json(votacoes);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async enqueteGetDetails(req, res) {
    try {
      const votacao = await db.getVotacaoEnquete(req.query.id);
      const meusVoto = await db.getMyVoto(req.query.id, req.session.user.id);
      votacao.status = getStatusAsInt(votacao);
      return res.status(200).json({votacao: votacao, meuVoto: meusVoto ?? null});
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

};

function getStatusAsInt(enquete) {
  const partsInicio = enquete.data_inicio.split("/");
  const partsFim = enquete.data_termino.split("/");

  const diaInicio = new Date(partsInicio[1]+"/"+partsInicio[0]+"/"+partsInicio[2]);
  const diaFim = new Date(partsFim[1]+"/"+partsFim[0]+"/"+partsFim[2]);

  diaInicio.setHours(0,0,0,0);
  diaFim.setHours(0,0,0,0);

  const today = new Date();
  today.setHours(0,0,0,0);

  if(diaFim < today){
    return 2; // finalizado
  } else if(diaInicio > today){
    return 0; // agendado
  } else{
    return 1; // em andamento
  }
};