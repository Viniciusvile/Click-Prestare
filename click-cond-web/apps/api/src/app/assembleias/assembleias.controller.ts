import { Body, Controller, Get, HttpCode, Post, Query } from '@nestjs/common';
import { AssembleiasService } from './assembleias.service';
import { ReqUser } from '../auth/req-user.decorator';
import { JwtPayload } from '../auth/jwt-payload.interface';

@Controller('assembleias')
export class AssembleiasController {
  constructor(private readonly service: AssembleiasService) {}

  // ==========================================
  // ASSEMBLEIAS
  // ==========================================
  @Post('insert')
  @HttpCode(200)
  insert(
    @Body() body: { id_condominio: string | number; assembleia: any },
    @ReqUser() payload: JwtPayload,
  ) {
    const userId = payload?.user?.id ?? payload?.sub ?? 1;
    return this.service.insert(Number(body.id_condominio), body.assembleia, Number(userId));
  }

  @Post('update')
  @HttpCode(200)
  update(
    @Body() body: { id_condominio: string | number; assembleia: any },
    @ReqUser() payload: JwtPayload,
  ) {
    const userId = payload?.user?.id ?? payload?.sub ?? 1;
    return this.service.update(Number(body.id_condominio), body.assembleia, Number(userId));
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
  get(
    @Query('id_condominio') idCondominio: string,
    @Query('id') id: string,
    @ReqUser() payload: JwtPayload,
  ) {
    const userId = payload?.user?.id ?? payload?.sub ?? 1;
    return this.service.get(Number(idCondominio), Number(id), Number(userId));
  }

  @Post('finish/insert')
  @HttpCode(200)
  finish(@Body() body: { id_condominio: string | number; assembleia: any }) {
    return this.service.finish(Number(body.id_condominio), body.assembleia);
  }

  // ==========================================
  // VOTAÇÕES E ENQUETES
  // ==========================================
  @Post('votacoes/insert')
  @HttpCode(200)
  insertVotacao(@Body() body: { id_condominio: string | number; votacao: any }) {
    return this.service.insertVotacao(body.votacao, Number(body.id_condominio));
  }

  @Post('votacoes/remove')
  @HttpCode(200)
  removeVotacao(@Body() body: { id: string | number }) {
    return this.service.removeVotacao(Number(body.id));
  }

  @Post('votacoes/finish')
  @HttpCode(200)
  finishVotacao(@Body() body: { id: string | number }) {
    return this.service.finishVotacao(Number(body.id));
  }

  @Post('votacoes/voto/insert')
  @HttpCode(200)
  registerVoto(
    @Body() body: { voto: { votacao_id: string | number; opcao_id: string | number } },
    @ReqUser() payload: JwtPayload,
  ) {
    const userId = payload?.user?.id ?? payload?.sub ?? 1;
    return this.service.registerVoto(
      Number(body.voto.votacao_id),
      Number(body.voto.opcao_id),
      Number(userId),
    );
  }

  @Get('votacoes/enquetes/get-all')
  enqueteGetAll(@Query('id_condominio') idCondominio: string) {
    return this.service.enqueteGetAll(Number(idCondominio));
  }

  @Get('votacoes/enquetes/get')
  enqueteGetDetails(@Query('id') id: string, @ReqUser() payload: JwtPayload) {
    const userId = payload?.user?.id ?? payload?.sub ?? 1;
    return this.service.enqueteGetDetails(Number(id), Number(userId));
  }
}
