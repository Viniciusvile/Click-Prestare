import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { ComunicadosService } from './comunicados.service';

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
}
