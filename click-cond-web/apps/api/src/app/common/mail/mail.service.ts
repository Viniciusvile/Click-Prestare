import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import * as dns from 'dns';
import { promisify } from 'util';

// Railway egress nao tem rota IPv6 — forca IPv4 primeiro globalmente.
dns.setDefaultResultOrder('ipv4first');
const dnsLookup = promisify(dns.lookup);

@Injectable()
export class MailService implements OnModuleInit {
  private readonly logger = new Logger(MailService.name);
  private transporter: nodemailer.Transporter | null = null;
  private readonly fromAddress: string;
  private readonly user?: string;
  private readonly pass?: string;

  constructor() {
    this.user = process.env.SMTP_USER;
    this.pass = process.env.SMTP_PASS;
    const fromEmail = process.env.SMTP_FROM || this.user || 'nao.responder.click@gmail.com';
    const fromName = process.env.SMTP_FROM_NAME || 'Click Condomínios';
    this.fromAddress = `"${fromName}" <${fromEmail}>`;

    this.logger.log(`MailService construido: SMTP_USER=${this.user ?? 'UNDEFINED'} SMTP_PASS_LEN=${this.pass ? this.pass.length : 0}`);
  }

  async onModuleInit() {
    if (!this.user || !this.pass) {
      this.logger.warn('SMTP_USER/SMTP_PASS não definidos — envio de e-mails desabilitado.');
      return;
    }

    const hostFromEnv = process.env.SMTP_HOST || 'smtp.gmail.com';
    let resolvedHost = hostFromEnv;
    try {
      const { address } = await dnsLookup(hostFromEnv, { family: 4 });
      resolvedHost = address;
      this.logger.log(`SMTP host ${hostFromEnv} resolvido para ${address} (IPv4).`);
    } catch (err: any) {
      this.logger.warn(`Falha ao resolver ${hostFromEnv} via IPv4: ${err?.message ?? err}. Usando hostname original.`);
    }

    const port = process.env.SMTP_PORT ? Number(process.env.SMTP_PORT) : 587;
    const secure = process.env.SMTP_SECURE === 'true' ? true : port === 465;

    this.transporter = nodemailer.createTransport({
      host: resolvedHost,
      port,
      secure,
      requireTLS: !secure,
      auth: { user: this.user, pass: this.pass.replace(/\s+/g, '') },
      connectionTimeout: 15000,
      greetingTimeout: 15000,
      socketTimeout: 30000,
      tls: { servername: hostFromEnv },
    });

    this.logger.log(`SMTP transporter pronto: host=${resolvedHost} port=${port} secure=${secure}`);

    try {
      await this.transporter.verify();
      this.logger.log('SMTP transporter verificado com sucesso.');
    } catch (err: any) {
      this.logger.error(`Falha ao verificar SMTP: ${err?.message ?? err}`);
    }
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
    } catch (err: any) {
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
