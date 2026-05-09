const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerFinanceiro');
const jwt = require('../middlewares/jwtVerify.js');

router.post('/insert', jwt({ typeAccess: ['Sindico'] }), controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico'] }), controller.update);
router.get('/get', jwt({ typeAccess: ['Sindico'] }), controller.get);
router.get('/moradores/get-all', jwt({ typeAccess: ['Sindico'] }), controller.getAllMoradores);
router.get('/inadimplentes/get-all', jwt({ typeAccess: ['Sindico'] }), controller.getAllInadimplentes);
router.get('/inadimplente/get', jwt({ typeAccess: ['Sindico'] }), controller.getInadimplenteDetail);
router.get('/grafico/get-all', jwt({ typeAccess: ['Sindico'] }), controller.getGrafico);


module.exports = router;