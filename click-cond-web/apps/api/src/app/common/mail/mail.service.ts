import { Injectable, Logger } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import * as dns from 'dns';

// Railway egress nao tem rota IPv6 — for ce o Node a usar IPv4 primeiro
// em TODAS as resolucoes DNS deste processo, evitando ENETUNREACH em
// smtp.gmail.com e outros servicos que tem AAAA records.
dns.setDefaultResultOrder('ipv4first');

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private transporter: nodemailer.Transporter | null = null;
  private readonly fromAddress: string;

  constructor() {
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASS;
    const fromEmail = process.env.SMTP_FROM || user || 'nao.responder.click@gmail.com';
    const fromName = process.env.SMTP_FROM_NAME || 'Click Condomínios';
    this.fromAddress = `"${fromName}" <${fromEmail}>`;

    this.logger.log(`MailService init: SMTP_USER=${user ? user : 'UNDEFINED'} SMTP_PASS_LEN=${pass ? pass.length : 0} SERVICE=${process.env.SMTP_SERVICE || 'gmail'}`);

    if (!user || !pass) {
      this.logger.warn('SMTP_USER/SMTP_PASS não definidos — envio de e-mails desabilitado.');
      return;
    }

    const normalizedPass = pass.replace(/\s+/g, '');

    // Resolve hostname manualmente forcando IPv4, evita IPv6 do Gmail
    // que falha com ENETUNREACH na rede do Railway.
    const lookupIPv4 = (
      hostname: string,
      options: any,
      callback: (err: NodeJS.ErrnoException | null, address: string, family: number) => void,
    ) => {
      dns.lookup(hostname, { family: 4 }, callback as any);
    };

    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || 'smtp.gmail.com',
      port: process.env.SMTP_PORT ? Number(process.env.SMTP_PORT) : 465,
      secure: process.env.SMTP_SECURE !== 'false',
      auth: { user, pass: normalizedPass },
      // Timeouts curtos para falhar rapido em vez de travar silenciosamente
      connectionTimeout: 15000,
      greetingTimeout: 15000,
      socketTimeout: 30000,
      // @ts-ignore — lookup nao esta na tipagem oficial mas e suportado
      lookup: lookupIPv4,
    });

    this.transporter.verify().then(
      () => this.logger.log('SMTP transporter verificado com sucesso.'),
      (err) => this.logger.error(`Falha ao verificar SMTP: ${err?.message ?? err}`),
    );
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

    try {
      const info = await this.transporter.sendMail({
        from: this.fromAddress,
        to: email,
        subject: 'CLICK - Bem-vindo(a)! Suas credenciais de acesso',
        html,
      });
      this.logger.log(`E-mail de boas-vindas enviado para ${email}. messageId=${info.messageId}`);
    } catch (err) {
      this.logger.error(`Falha ao enviar e-mail de boas-vindas para ${email}: ${err?.message ?? err}`);
      throw err;
    }
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
