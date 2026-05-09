import { Body, Controller, HttpCode, Post } from '@nestjs/common';
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
}