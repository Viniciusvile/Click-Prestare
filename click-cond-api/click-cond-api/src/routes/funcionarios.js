const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerFuncionarios');
const jwt = require('../middlewares/jwtVerify.js');
const validate = require('../validations/ValidationFuncionario.js');

router.post('/login', controller.login);
router.post('/insert', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), validate.validateInsert, controller.insert);
router.post('/recovery-password', validate.validateRecovery, controller.recoveryPassword);
router.post('/new-password', jwt({ typeAccess: ['Funcionario'] }), controller.newPassword);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), validate.validateInsert, controller.update);
router.post('/update-infos', jwt({ typeAccess: ['Funcionario'] }), validate.validateUpdateInfos, controller.updateInfos);
router.get('/get', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.get);
router.get('/list-condominios', jwt({ typeAccess: ['Funcionario'] }), controller.listCondominios);

module.exports = router;
