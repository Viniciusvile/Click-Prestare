import { Injectable, ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { createHash } from 'crypto';
import * as bcrypt from 'bcrypt';
import { JwtPayload } from './jwt-payload.interface';
import { QrSessionStore } from './qr-session.store';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly qrStore: QrSessionStore,
  ) {}

  async loginPortaria(login: string, senha: string) {
    if (!this.prisma.isConnected) {
      throw new ServiceUnavailableException('Banco de dados indisponível. Tente novamente em instantes.');
    }

    const funcionario = await this.prisma.funcionarios_Portaria.findFirst({
      where: { login, ativo: 1 },
    });

    if (!funcionario) {
      throw new UnauthorizedException('Credenciais inválidas.');
    }

    const isBcrypt = funcionario.password.startsWith('$2');
    let isMatch = false;

    if (isBcrypt) {
      isMatch = await bcrypt.compare(senha, funcionario.password);
    } else {
      const md5Password = createHash('md5').update(senha).digest('hex');
      isMatch = funcionario.password === md5Password;
      if (isMatch) {
        const newHash = await bcrypt.hash(senha, 10);
        await this.prisma.funcionarios_Portaria.update({
          where: { id: funcionario.id },
          data: { password: newHash },
        });
      }
    }

    if (!isMatch) {
      throw new UnauthorizedException('Credenciais inválidas.');
    }

    // Busca o nome do condomínio associado
    const cond = await this.prisma.condominios.findUnique({
      where: { id: funcionario.id_condominio },
      select: { nome: true },
    });

    const payload: JwtPayload = {
      sub: funcionario.id,
      nome: funcionario.nome,
      id_condominio: funcionario.id_condominio,
      turno: funcionario.turno,
    };

    return {
      access_token: this.jwt.sign(payload),
      id: funcionario.id,
      nome: funcionario.nome,
      turno: funcionario.turno,
      id_condominio: funcionario.id_condominio,
      condominio_nome: cond?.nome || 'Click Condomínio',
    };
  }

  async changePassword(id: number, senhaAtual: string, novaSenha: string) {
    if (!this.prisma.isConnected) {
      throw new ServiceUnavailableException('Banco de dados indisponível. Tente novamente em instantes.');
    }

    const funcionario = await this.prisma.funcionarios_Portaria.findUnique({
      where: { id },
    });

    if (!funcionario) {
      throw new UnauthorizedException('Funcionário não encontrado.');
    }

    const isBcrypt = funcionario.password.startsWith('$2');
    let isMatch = false;

    if (isBcrypt) {
      isMatch = await bcrypt.compare(senhaAtual, funcionario.password);
    } else {
      const md5Password = createHash('md5').update(senhaAtual).digest('hex');
      isMatch = funcionario.password === md5Password;
    }

    if (!isMatch) {
      throw new UnauthorizedException('Senha atual incorreta.');
    }

    const newHash = await bcrypt.hash(novaSenha, 10);
    await this.prisma.funcionarios_Portaria.update({
      where: { id },
      data: { password: newHash },
    });

    return { success: true, message: 'Senha updated com sucesso.' };
  }

  async getCondominioNome(id: number) {
    if (!this.prisma.isConnected) {
      return { nome: 'Click Condomínio' };
    }
    const cond = await this.prisma.condominios.findUnique({
      where: { id },
      select: { nome: true },
    });
    return { nome: cond?.nome || 'Click Condomínio' };
  }

  createQrSession() {
    const session = this.qrStore.create();
    return { qrToken: session.qrToken, expiresAt: session.expiresAt };
  }

  async getQrStatus(qrToken: string) {
    const session = this.qrStore.get(qrToken);
    if (!session) {
      return { status: 'expired' };
    }

    if (session.status === 'confirmed') {
      return {
        status: 'confirmed',
        access_token: session.access_token,
        id: session.idUser,
        nome: session.nome,
        turno: session.typeAccess === 'Sindico' ? 'Síndico' : 'Porteiro (App)',
        id_condominio: session.id_condominio,
        condominio_nome: session.condominio_nome,
      };
    }

    return { status: 'pending' };
  }

  async authorizeQrSession(payload: JwtPayload, qrToken: string, idCondominio: number) {
    const session = this.qrStore.get(qrToken);
    if (!session) {
      throw new UnauthorizedException('QR Code expirado ou inválido.');
    }

    if (session.status !== 'pending') {
      throw new UnauthorizedException('Sessão QR Code já processada.');
    }

    const cond = await this.prisma.condominios.findUnique({
      where: { id: idCondominio },
      select: { nome: true },
    });

    if (!cond) {
      throw new UnauthorizedException('Condomínio não encontrado.');
    }

    const userId = payload.sub;
    const typeAccess = payload.typeAccess ?? 'Sindico';
    const nomeUsuario = payload.nome;

    const portariaPayload: JwtPayload = {
      sub: userId,
      nome: nomeUsuario,
      id_condominio: idCondominio,
      turno: typeAccess === 'Sindico' ? 'Síndico' : 'Porteiro (App)',
    };

    const accessToken = this.jwt.sign(portariaPayload);

    this.qrStore.confirm(qrToken, {
      idUser: userId,
      nome: nomeUsuario,
      typeAccess,
      id_condominio: idCondominio,
      condominio_nome: cond.nome,
      access_token: accessToken,
    });

    return { success: true };
  }
}
