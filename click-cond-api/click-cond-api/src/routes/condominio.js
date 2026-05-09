const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerCondominio');
const jwt = require('../middlewares/jwtVerify.js');

router.post('/register', jwt({ typeAccess: ['Sindico'] }), controller.register);
router.post('/update', jwt({ typeAccess: ['Sindico'] }), controller.update);
router.post('/update-address', jwt({ typeAccess: ['Sindico'] }), controller.updateAddress);
router.post('/update-moeda', jwt({ typeAccess: ['Sindico'] }), controller.updateMoeda);
router.post('/update-assinatura', jwt({ typeAccess: ['Sindico'] }), controller.updateAssinatura);
router.get('/get-condominio', jwt({ typeAccess: ['Sindico', 'Morador', 'Funcionario'] }), controller.getCondominio);
router.get('/aptos/get-all', jwt({ typeAccess: ['Sindico', 'Funcionario'] }), controller.getAllAptos);
router.get('/infos/get', jwt({ typeAccess: ['Sindico'] }), controller.getInfos);
router.get('/address/get', jwt({ typeAccess: ['Sindico'] }), controller.getAddress);
router.post('/remove', jwt({ typeAccess: ['Sindico'] }), controller.remove);


module.exports = router;
