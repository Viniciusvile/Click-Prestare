const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerManutencoes');
const jwt = require('../middlewares/jwtVerify.js');

router.post('/insert', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.remove);
router.post('/update', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.update);
router.get('/get', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.get);
router.post('/update-status', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.updateStatus);

module.exports = router;
