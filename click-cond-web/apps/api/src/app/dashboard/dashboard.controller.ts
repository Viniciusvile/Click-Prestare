import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { DashboardService } from './dashboard.service';

@Controller('condominios/:idCondominio/dashboard')
export class DashboardController {
  constructor(private readonly service: DashboardService) {}

  @Get()
  get(@Param('idCondominio', ParseIntPipe) idCondominio: number) {
    return this.service.summary(idCondominio);
  }
}
