import { Body, Controller, Get, HttpCode, Post, Query } from '@nestjs/common';
import { AreasSociaisService } from './areas-sociais.service';
import { ReqUser } from '../auth/req-user.decorator';
import { JwtPayload } from '../auth/jwt-payload.interface';

@Controller(['areasSociais', 'areas-sociais'])
export class AreasSociaisController {
  constructor(private readonly service: AreasSociaisService) {}

  // ==========================================
  // ÁREAS SOCIAIS
  // ==========================================
  @Post('insert')
  @HttpCode(200)
  insert(@Body() body: { id_condominio: string | number; areaSocial: any }) {
    return this.service.insert(Number(body.id_condominio), body.areaSocial);
  }

  @Post('update')
  @HttpCode(200)
  update(@Body() body: { id_condominio: string | number; areaSocial: any }) {
    return this.service.update(Number(body.id_condominio), body.areaSocial);
  }

  @Post('remove')
  @HttpCode(200)
  remove(@Body() body: { id: string | number }) {
    return this.service.remove(Number(body.id));
  }

  @Get('get-all')
  getAll(@Query('id_condominio') idCondominio: string) {
    return this.service.getAll(Number(idCondominio));
  }

  @Get('get')
  get(@Query('id_condominio') idCondominio: string, @Query('id') id: string) {
    return this.service.get(Number(idCondominio), Number(id));
  }

  // ==========================================
  // AGENDAMENTOS E RESERVAS
  // ==========================================
  @Post('agendamento/insert')
  @HttpCode(200)
  insertAgendamento(
    @Body() body: { agendamento: any },
    @ReqUser() payload: JwtPayload,
  ) {
    const idUser = payload.user?.id ?? payload.sub;
    const typeAccess = payload.typeAccess ?? payload.user?.typeAccess ?? 'Morador';
    return this.service.insertAgendamento(body.agendamento, Number(idUser), typeAccess);
  }

  @Post('agendamento/remove')
  @HttpCode(200)
  removeAgendamento(
    @Body() body: { id: string | number },
    @ReqUser() payload: JwtPayload,
  ) {
    const idUser = payload.user?.id ?? payload.sub;
    const typeAccess = payload.typeAccess ?? payload.user?.typeAccess ?? 'Morador';
    return this.service.removeAgendamento(Number(body.id), Number(idUser), typeAccess);
  }

  @Get('agendamentos/get-all')
  getAllAgendamentos(@Query('id_condominio') idCondominio: string) {
    return this.service.getAllAgendamentos(Number(idCondominio));
  }

  @Get('meus-agendamentos/get-all')
  getAllMeusAgendamentos(
    @Query('id_condominio') idCondominio: string,
    @Query('id_apto') idApto?: string,
    @ReqUser() payload?: JwtPayload,
  ) {
    const idUser = payload?.user?.id ?? payload?.sub ?? 1;
    const aptoIdNum = idApto && idApto !== 'null' && idApto !== 'undefined' ? Number(idApto) : undefined;
    return this.service.getAllMeusAgendamentos(Number(idCondominio), Number(idUser), aptoIdNum);
  }

  @Post('agendamento/update-status')
  @HttpCode(200)
  updateStatusAgendamento(
    @Body() body: {
      id: string | number;
      isAccept?: boolean;
      status?: string;
      motivo_recusa?: string;
      agendamento?: { status?: string; motivo?: string };
    },
  ) {
    const statusVal = body.isAccept ?? body.status ?? body.agendamento?.status ?? 'pendente';
    const motivoVal = body.motivo_recusa ?? body.agendamento?.motivo ?? '';
    return this.service.updateStatusAgendamento(Number(body.id), statusVal, motivoVal);
  }

  // ==========================================
  // MANUTENÇÕES
  // ==========================================
  @Post('manutencao/insert')
  @HttpCode(200)
  insertManutencao(@Body() body: { manutencao: any }) {
    return this.service.insertManutencao(body.manutencao);
  }

  @Post('manutencao/update')
  @HttpCode(200)
  updateManutencao(@Body() body: { manutencao: any }) {
    return this.service.updateManutencao(body.manutencao);
  }

  @Post('manutencao/remove')
  @HttpCode(200)
  removeManutencao(@Body() body: { id: string | number }) {
    return this.service.removeManutencao(Number(body.id));
  }
}
