import {
  Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put,
} from '@nestjs/common';
import { ComunicadosService, CreateComunicadoDto } from './comunicados.service';

@Controller('condominios/:idCondominio/comunicados')
export class ComunicadosController {
  constructor(private readonly service: ComunicadosService) {}

  @Get()
  list(@Param('idCondominio', ParseIntPipe) idCondominio: number) {
    return this.service.findAll(idCondominio);
  }

  @Get(':id')
  get(@Param('id', ParseIntPipe) id: number) {
    return this.service.findOne(id);
  }

  @Post()
  create(
    @Param('idCondominio', ParseIntPipe) idCondominio: number,
    @Body() body: Omit<CreateComunicadoDto, 'id_condominio'>,
  ) {
    return this.service.create({ ...body, id_condominio: idCondominio });
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: Partial<CreateComunicadoDto>,
  ) {
    return this.service.update(id, body);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.service.remove(id);
    return { ok: true };
  }
}
