const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerPrestadores');
const jwt = require('../middlewares/jwtVerify.js');
const validate = require('../validations/ValidationPrestador.js');

router.post('/insert', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), validate.validateInsert, controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico', 'Funcionario'] }),  validate.validateInsert, controller.update);
router.get('/get', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.get);


module.exports = router;
