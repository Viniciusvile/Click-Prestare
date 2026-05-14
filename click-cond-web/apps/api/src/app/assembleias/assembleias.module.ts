import { Module } from '@nestjs/common';
import { AssembleiasController } from './assembleias.controller';
import { AssembleiasService } from './assembleias.service';

@Module({
  controllers: [AssembleiasController],
  providers: [AssembleiasService],
})
export class AssembleiasModule {}
