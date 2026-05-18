import { Body, Controller, HttpCode, Post, Get, Param, ParseIntPipe } from '@nestjs/common';
import { AuthService } from './auth.service';
import { Public } from './public.decorator';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('login-portaria')
  @HttpCode(200)
  login(@Body() body: { login: string; senha: string }) {
    return this.authService.loginPortaria(body.login, body.senha);
  }

  @Public()
  @Get('condominio/:id')
  async getCondominio(@Param('id', ParseIntPipe) id: number) {
    return this.authService.getCondominioNome(id);
  }

  @Post('change-password')
  @HttpCode(200)
  changePassword(@Body() body: { id: number; senhaAtual: string; novaSenha: string }) {
    return this.authService.changePassword(body.id, body.senhaAtual, body.novaSenha);
  }
}