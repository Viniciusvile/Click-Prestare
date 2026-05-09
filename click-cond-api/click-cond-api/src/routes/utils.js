var express = require("express");
var router = express.Router();
var controlUsers = require("../controller/ControllerUsers");
var validateUsers = require("../validations/ValidationUser");

module.exports = router;

router.get("/recovery/userResetPassword", function (req, res){res.render('UserResetPassword.html');});
router.post("/recovery/userResetPassword", validateUsers.validateNewPassword, controlUsers.newPassword);

