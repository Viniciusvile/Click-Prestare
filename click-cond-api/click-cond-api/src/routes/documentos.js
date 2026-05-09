const { Router } = require('express');
const router = Router();
const controller = require('../controller/ControllerDocuments');
const jwt = require('../middlewares/jwtVerify.js');

router.post('/insert', jwt({ typeAccess: ['Sindico'] }), controller.insert);
router.get('/get-all', jwt({ typeAccess: ['Sindico', 'Morador'] }), controller.getAll);
router.post('/remove', jwt({ typeAccess: ['Sindico'] }), controller.remove);

module.exports = router;
