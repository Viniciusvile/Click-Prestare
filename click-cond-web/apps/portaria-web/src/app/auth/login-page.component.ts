import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from './auth.service';

@Component({
  selector: 'app-login-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="min-h-screen bg-graphite flex items-center justify-center px-4">
      <div class="w-full max-w-sm">

        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-14 h-14 rounded-xl bg-accent/10 border border-accent/20 mb-4">
            <svg class="w-7 h-7 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
            </svg>
          </div>
          <h1 class="text-xl font-semibold text-white">Click Portaria</h1>
          <p class="text-sm text-slate-400 mt-1">Acesso restrito ao pessoal da portaria</p>
        </div>

        <form (ngSubmit)="onSubmit()" class="space-y-4">
          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1.5">Login</label>
            <input
              type="text"
              [(ngModel)]="loginValue"
              name="login"
              autocomplete="username"
              class="w-full bg-graphite-200 border border-white/10 rounded-lg px-3 py-2.5 text-sm text-white
                     placeholder-slate-500 focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent/30"
              placeholder="usuário"
              required
            />
          </div>

          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1.5">Senha</label>
            <input
              type="password"
              [(ngModel)]="senhaValue"
              name="senha"
              autocomplete="current-password"
              class="w-full bg-graphite-200 border border-white/10 rounded-lg px-3 py-2.5 text-sm text-white
                     placeholder-slate-500 focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent/30"
              placeholder="••••••••"
              required
            />
          </div>

          @if (erro()) {
            <div class="flex items-center gap-2 text-xs text-red-400 bg-red-400/10 border border-red-400/20 rounded-lg px-3 py-2.5">
              <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
              </svg>
              {{ erro() }}
            </div>
          }

          <button
            type="submit"
            [disabled]="carregando()"
            class="w-full bg-accent hover:bg-accent-600 disabled:opacity-50 disabled:cursor-not-allowed
                   text-white font-medium text-sm rounded-lg px-4 py-2.5 transition-colors"
          >
            @if (carregando()) {
              <span class="flex items-center justify-center gap-2">
                <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                </svg>
                Entrando...
              </span>
            } @else {
              Entrar
            }
          </button>
        </form>

      </div>
    </div>
  `,
})
export class LoginPageComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  loginValue = '';
  senhaValue = '';
  carregando = signal(false);
  erro = signal('');

  onSubmit() {
    if (!this.loginValue || !this.senhaValue) return;
    this.carregando.set(true);
    this.erro.set('');

    this.auth.login(this.loginValue, this.senhaValue).subscribe({
      next: () => this.router.navigate(['/']),
      error: (err) => {
        this.carregando.set(false);
        this.erro.set(
          err.status === 401
            ? 'Login ou senha incorretos'
            : 'Falha na conexão com o servidor',
        );
      },
    });
  }
}