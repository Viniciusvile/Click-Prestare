const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerAgenda');
const jwt = require('../middlewares/jwtVerify.js');
const validate = require('../validations/ValidationAgenda.js');

router.post('/insert', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), validate.validateInsertAgenda, controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), validate.validateInsertAgenda, controller.update);
router.get('/get', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.get);


module.exports = router;
