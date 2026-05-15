import { Body, Controller, Get, HttpCode, Post, Query } from '@nestjs/common';
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

  @Get('get-all')
  getAllMoradores(@Query('id_condominio') idCond: string) {
    return this.service.getAllMoradores(Number(idCond));
  }

  @Get('get')
  getMorador(@Query('id') id: string) {
    return this.service.getMoradorById(Number(id));
  }

  @Post('insert')
  @HttpCode(200)
  insertMorador(@Body() body: any) {
    return this.service.saveMorador(body, false);
  }

  @Post('update')
  @HttpCode(200)
  updateMorador(@Body() body: any) {
    return this.service.saveMorador(body, true);
  }

  @Post('remove')
  @HttpCode(200)
  removeMorador(@Body() body: { id: number }) {
    return this.service.removeMorador(Number(body.id));
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

  @Get('get-all')
  getAllFuncionarios(@Query('id_condominio') idCond: string) {
    return this.service.getAllFuncionarios(Number(idCond));
  }

  @Get('get')
  getFuncionario(@Query('id') id: string) {
    return this.service.getFuncionarioById(Number(id));
  }

  @Post('insert')
  @HttpCode(200)
  insertFuncionario(@Body() body: any) {
    return this.service.saveFuncionario(body, false);
  }

  @Post('update')
  @HttpCode(200)
  updateFuncionario(@Body() body: any) {
    return this.service.saveFuncionario(body, true);
  }

  @Post('remove')
  @HttpCode(200)
  removeFuncionario(@Body() body: { id: number }) {
    return this.service.removeFuncionario(Number(body.id));
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

// ==========================================
// CONDOMÍNIO GERAL
// ==========================================
@Controller('condominio')
export class CondominioMobileController {
  constructor(private readonly service: MobileAuthService) {}

  @Get('get-condominio')
  getCondominio(@Query('id_condominio') idCond: string) {
    return this.service.getCondominioById(Number(idCond));
  }

  @Post('register')
  @HttpCode(200)
  register(@Body() body: any, @ReqUser() payload: JwtPayload) {
    const idUser = payload.user?.id ?? payload.sub;
    return this.service.registerCondominio(body, Number(idUser));
  }
}

// ==========================================
// APARTAMENTOS MOBILE
// ==========================================
@Controller('apartamentos')
export class ApartamentosMobileController {
  constructor(private readonly service: MobileAuthService) {}

  @Get('get-all')
  getAllApartamentos(@Query('id_condominio') idCond: string) {
    return this.service.getAllApartamentos(Number(idCond));
  }

  @Get('get-moradores')
  getMoradoresApto(@Query('id_apto') idApto: string, @Query('tipo') tipo?: string) {
    return this.service.getMoradoresApto(Number(idApto), tipo);
  }

  @Post('insert')
  insertApto(@Body() body: any) {
    return this.service.saveApto(body, false);
  }

  @Post('update')
  updateApto(@Body() body: any) {
    return this.service.saveApto(body, true);
  }

  @Post('remove')
  removeApto(@Body() body: any) {
    return this.service.removeApto(Number(body.id));
  }
}
