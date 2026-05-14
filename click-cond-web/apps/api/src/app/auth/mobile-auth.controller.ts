import { Body, Controller, Get, HttpCode, Post } from '@nestjs/common';
import { MobileAuthService } from './mobile-auth.service';
import { Public } from './public.decorator';
import { ReqUser } from './req-user.decorator';
import { JwtPayload } from './jwt-payload.interface';

// ==========================================
// SÍNDICO
// ==========================================
@Controller('sindico')
export class SindicoMobileController {
  constructor(private readonly service: MobileAuthService) {}

  @Public()
  @Post('login')
  @HttpCode(200)
  login(@Body() body: { login: string; password?: string; senha?: string }) {
    const pwd = body.password ?? body.senha ?? '';
    return this.service.loginSindico(body.login, pwd);
  }

  @Get('list-condominios')
  listCondominios(@ReqUser() payload: JwtPayload) {
    const idUser = payload.user?.id ?? payload.sub;
    return this.service.listCondominiosSindico(Number(idUser));
  }
}

// ==========================================
// MORADORES
// ==========================================
@Controller('moradores')
export class MoradoresMobileController {
  constructor(private readonly service: MobileAuthService) {}

  @Public()
  @Post('login')
  @HttpCode(200)
  login(@Body() body: { login: string; password?: string; senha?: string }) {
    const pwd = body.password ?? body.senha ?? '';
    return this.service.loginMorador(body.login, pwd);
  }

  @Get('list-condominios')
  listCondominios(@ReqUser() payload: JwtPayload) {
    const idUser = payload.user?.id ?? payload.sub;
    return this.service.listCondominiosMorador(Number(idUser));
  }
}

// ==========================================
// FUNCIONÁRIOS
// ==========================================
@Controller('funcionarios')
export class FuncionariosMobileController {
  constructor(private readonly service: MobileAuthService) {}

  @Public()
  @Post('login')
  @HttpCode(200)
  login(@Body() body: { login: string; password?: string; senha?: string }) {
    const pwd = body.password ?? body.senha ?? '';
    return this.service.loginFuncionario(body.login, pwd);
  }

  @Get('list-condominios')
  listCondominios(@ReqUser() payload: JwtPayload) {
    const idUser = payload.user?.id ?? payload.sub;
    return this.service.listCondominiosFuncionario(Number(idUser));
  }
}

// ==========================================
// DASHBOARD
// ==========================================
@Controller('dashboard')
export class DashboardMobileController {
  constructor(private readonly service: MobileAuthService) {}

  @Get('summary')
  summary(@ReqUser() payload: JwtPayload) {
    const idUser = payload.user?.id ?? payload.sub;
    const typeAccess = payload.typeAccess ?? payload.user?.typeAccess ?? 'Sindico';
    return this.service.getSummary(Number(idUser), typeAccess);
  }
}
