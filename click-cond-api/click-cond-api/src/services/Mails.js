var nodemailer = require('nodemailer');

module.exports = {

    mailForgotPassword: async function(emailToSend, newPassword, login_type){
      return new Promise( (resolve, reject) => {
        message = `
                    Olá,<br><br>
                    Você ou alguém solicitou a recuperação de senha do App CLICK.<br><br>
                    Utilize a senha abaixo para entrar na sua conta como ${login_type}:<br>
                    <b>${newPassword}</b>
                    <br><br>
                    Atenciosamente,<br>
                    Equipe CLICK
                    `;        

        var remetente = nodemailer.createTransport({
            service: "gmail",
            port: 465,
            secure: true,
            auth: {
              user: "nao.responder.click@gmail.com",
              pass: "ckwx hqdm vabv rdre"
            }
          });
          var emailASerEnviado = {
            from: 'nao.responder.click@gmail.com',
            to: emailToSend,
            subject: `CLICK - Recuperação de Senha`,
            text: '',
            html: message,
          };
          remetente.sendMail(emailASerEnviado, function(error){
            console.log(error);
              if (error) {
                reject(Error("Falha no envio do e-mail"))
              } else {
                resolve(true)
              }
          });
      })    
    },

}