import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { createHash } from 'crypto';
import { JwtPayload } from './jwt-payload.interface';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async loginPortaria(login: string, senha: string) {
    const funcionario = await this.prisma.funcionarios_Portaria.findFirst({
      where: { login, ativo: 1 },
    });

    if (!funcionario) {
      throw new UnauthorizedException('Login ou senha inválidos');
    }

    const bcrypt = require('bcrypt');
    const md5Password = createHash('md5').update(senha).digest('hex');
    let isMatch = false;

    if (funcionario.password.startsWith('$2')) {
      isMatch = await bcrypt.compare(senha, funcionario.password);
    } else {
      isMatch = (funcionario.password === md5Password);
      if (isMatch) {
        const newHash = await bcrypt.hash(senha, 10);
        await this.prisma.funcionarios_Portaria.update({
          where: { id: funcionario.id },
          data: { password: newHash },
        });
      }
    }

    if (!isMatch) {
      throw new UnauthorizedException('Login ou senha inválidos');
    }

    const payload: JwtPayload = {
      sub: funcionario.id,
      nome: funcionario.nome,
      id_condominio: funcionario.id_condominio,
      turno: funcionario.turno,
    };

    return {
      access_token: this.jwt.sign(payload),
      nome: funcionario.nome,
      turno: funcionario.turno,
      id_condominio: funcionario.id_condominio,
    };
  }
}
