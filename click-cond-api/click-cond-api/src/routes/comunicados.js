const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerComunicados');
const jwt = require('../middlewares/jwtVerify.js');
const validate = require('../validations/ValidationComunicados.js');

router.post('/insert', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), validate.validateInsertComunicado, controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), validate.validateInsertComunicado, controller.update);
router.get('/get', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.get);


module.exports = router;
