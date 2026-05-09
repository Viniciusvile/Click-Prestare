const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerAssembleias');
const jwt = require('../middlewares/jwtVerify.js');
const validate = require('../validations/ValidationAssembleia.js');

router.post('/insert', jwt({ typeAccess: ['Sindico'] }), validate.validateInsertAssembleia, controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico'] }), validate.validateInsertAssembleia, controller.update);
router.get('/get', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.get);
router.post('/finish/insert', jwt({ typeAccess: ['Sindico'] }), controller.finish);

router.post('/votacoes/insert', jwt({ typeAccess: ['Sindico'] }), validate.validateInsertVotacao, controller.insertVotacao);
router.post('/votacoes/remove', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.removeVotacao);
router.post('/votacoes/finish', jwt({ typeAccess: ['Sindico'] }), controller.finishVotacao);
router.post('/votacoes/voto/insert', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.registerVoto);
router.get('/votacoes/enquetes/get-all', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.enqueteGetAll);
router.get('/votacoes/enquetes/get', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.enqueteGetDetails);


module.exports = router;
