import { Injectable, Logger } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private transporter: nodemailer.Transporter | null = null;
  private readonly fromAddress: string;

  constructor() {
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASS;
    this.fromAddress = process.env.SMTP_FROM || user || 'nao.responder.click@gmail.com';

    if (!user || !pass) {
      this.logger.warn('SMTP_USER/SMTP_PASS não definidos — envio de e-mails desabilitado.');
      return;
    }

    this.transporter = nodemailer.createTransport({
      service: process.env.SMTP_SERVICE || 'gmail',
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT ? Number(process.env.SMTP_PORT) : 465,
      secure: process.env.SMTP_SECURE !== 'false',
      auth: { user, pass },
    });
  }

  async sendWelcomeMorador(email: string, nome: string, senhaInicial: string): Promise<void> {
    if (!this.transporter) {
      this.logger.warn(`E-mail de boas-vindas para ${email} ignorado (SMTP não configurado).`);
      return;
    }

    const html = `
      Olá, <b>${this.escape(nome)}</b>!<br><br>
      O seu acesso ao aplicativo <b>CLICK Condomínios</b> foi criado com sucesso.<br><br>
      Para acessar sua conta como <b>Morador</b>, baixe o aplicativo e utilize as credenciais abaixo:<br><br>
      <b>Login (E-mail):</b> ${this.escape(email)}<br>
      <b>Senha Inicial:</b> ${this.escape(senhaInicial)}<br><br>
      <i>Recomendamos que você altere sua senha após o primeiro acesso no menu de Configurações do App.</i><br><br>
      Seja muito bem-vindo(a)!<br>
      Equipe CLICK
    `;

    await this.transporter.sendMail({
      from: this.fromAddress,
      to: email,
      subject: 'CLICK - Bem-vindo(a)! Suas credenciais de acesso',
      html,
    });
  }

  async sendForgotPassword(email: string, novaSenha: string, tipoUsuario: string): Promise<void> {
    if (!this.transporter) {
      this.logger.warn(`E-mail de recuperação para ${email} ignorado (SMTP não configurado).`);
      return;
    }

    const html = `
      Olá,<br><br>
      Você ou alguém solicitou a recuperação de senha do App CLICK.<br><br>
      Utilize a senha abaixo para entrar na sua conta como ${this.escape(tipoUsuario)}:<br>
      <b>${this.escape(novaSenha)}</b><br><br>
      Atenciosamente,<br>
      Equipe CLICK
    `;

    await this.transporter.sendMail({
      from: this.fromAddress,
      to: email,
      subject: 'CLICK - Recuperação de Senha',
      html,
    });
  }

  private escape(value: string): string {
    return String(value ?? '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }
}
