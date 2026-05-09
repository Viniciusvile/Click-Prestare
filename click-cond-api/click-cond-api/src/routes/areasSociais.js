const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerAreasSociais');
const jwt = require('../middlewares/jwtVerify.js');
const validate = require('../validations/ValidationAreaSocial.js');

router.post('/insert', jwt({ typeAccess: ['Sindico'] }), validate.validateInsertAreaSocial, controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico'] }), validate.validateInsertAreaSocial, controller.update);
router.get('/get', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.get);

router.post('/agendamento/insert', jwt({ typeAccess: ['Sindico', 'Morador'] }), validate.validateInsertAgendamento, controller.insertAgendamento);
router.get('/agendamentos/get-all', jwt({ typeAccess: ['Sindico'] }), controller.getAllAgendamentos);
router.get('/meus-agendamentos/get-all', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.getAllMeusAgendamentos);
router.post('/agendamento/remove', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.removeAgendamento);
// router.post('/agendamento/update', jwt({ typeAccess: ['Sindico'] }), validate.validateInsertAgendamento, controller.updateAgendamento);
router.post('/agendamento/update-status', jwt({ typeAccess: ['Sindico'] }), controller.updateStatusAgendamento);

router.post('/manutencao/insert', jwt({ typeAccess: ['Sindico'] }), controller.insertManutencao);
router.post('/manutencao/remove', jwt({ typeAccess: ['Sindico'] }), controller.removeManutencao);
router.post('/manutencao/update', jwt({ typeAccess: ['Sindico'] }), controller.updateManutencao);

// router.get('/manutencoes/get-all', jwt({ typeAccess: 'Sindico' }), controller.getAllManutencoes);


module.exports = router;
