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
    <div class="min-h-screen bg-slate-950 flex relative overflow-hidden font-sans">
      
      <!-- Círculos de Brilho de Fundo (Glow Effects) -->
      <div class="absolute -top-40 -left-40 w-96 h-96 bg-blue-600/10 rounded-full blur-[120px] pointer-events-none"></div>
      <div class="absolute -bottom-40 -right-40 w-96 h-96 bg-accent/15 rounded-full blur-[120px] pointer-events-none"></div>
      
      <!-- Grid Decorativo -->
      <div class="absolute inset-0 bg-[linear-gradient(to_right,#0f172a_1px,transparent_1px),linear-gradient(to_bottom,#0f172a_1px,transparent_1px)] bg-[size:4rem_4rem] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)] opacity-30 pointer-events-none"></div>

      <!-- Container Principal -->
      <div class="w-full flex">
        
        <!-- Painel Esquerdo (Apresentação Corporativa - Visível apenas em telas grandes) -->
        <div class="hidden lg:flex lg:w-[55%] bg-slate-900/40 border-r border-white/5 relative p-16 flex-col justify-between overflow-hidden">
          <!-- Elemento de Grafismo do Prédio/Tecnologia (Prestare Gestão style) -->
          <div class="absolute inset-0 bg-gradient-to-br from-accent/5 via-blue-500/0 to-transparent pointer-events-none"></div>
          
          <!-- Logo Prestare / Click -->
          <div class="relative flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-accent/10 border border-accent/25 flex items-center justify-center shadow-lg shadow-accent/5">
              <svg class="w-5 h-5 text-accent animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
              </svg>
            </div>
            <span class="text-lg font-bold text-white tracking-tight uppercase">Prestare <span class="text-accent font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-accent to-blue-400">Click</span></span>
          </div>

          <!-- Hero Message -->
          <div class="relative space-y-6 max-w-lg my-auto">
            <span class="px-3 py-1 rounded-full bg-accent/10 border border-accent/25 text-[10px] text-accent font-semibold tracking-wider uppercase inline-block">
              Console Portaria Inteligente
            </span>
            <h2 class="text-4xl lg:text-5xl font-extrabold text-white tracking-tight leading-[1.15]">
              A inteligência operacional que <span class="bg-gradient-to-r from-accent to-blue-400 bg-clip-text text-transparent">conecta seu condomínio</span>
            </h2>
            <p class="text-sm text-slate-400 leading-relaxed font-light">
              Acesse a plataforma corporativa oficial da Click Portaria e gerencie fluxos de correspondências, visitantes, prestadores de serviços e ocorrências com rastreabilidade absoluta e conformidade corporativa.
            </p>

            <!-- Bullet points de funcionalidades com design premium -->
            <div class="grid grid-cols-2 gap-4 pt-4">
              <div class="flex items-center gap-2.5">
                <div class="w-5 h-5 rounded-md bg-accent/10 flex items-center justify-center shrink-0">
                  <svg class="w-3.5 h-3.5 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/>
                  </svg>
                </div>
                <span class="text-xs text-slate-300 font-medium">Controle de Acesso</span>
              </div>
              <div class="flex items-center gap-2.5">
                <div class="w-5 h-5 rounded-md bg-accent/10 flex items-center justify-center shrink-0">
                  <svg class="w-3.5 h-3.5 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/>
                  </svg>
                </div>
                <span class="text-xs text-slate-300 font-medium">Gestão de Encomendas</span>
              </div>
              <div class="flex items-center gap-2.5">
                <div class="w-5 h-5 rounded-md bg-accent/10 flex items-center justify-center shrink-0">
                  <svg class="w-3.5 h-3.5 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/>
                  </svg>
                </div>
                <span class="text-xs text-slate-300 font-medium">Ocorrências Ativas</span>
              </div>
              <div class="flex items-center gap-2.5">
                <div class="w-5 h-5 rounded-md bg-accent/10 flex items-center justify-center shrink-0">
                  <svg class="w-3.5 h-3.5 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/>
                  </svg>
                </div>
                <span class="text-xs text-slate-300 font-medium">Relatórios Gerenciais</span>
              </div>
            </div>
          </div>

          <!-- Footer Corporativo -->
          <div class="relative text-xs text-slate-500 flex justify-between items-center">
            <span>© 2026 Prestare Gestão e Tecnologia. Todos os direitos reservados.</span>
            <a href="https://prestaregestao.com.br/novo/" target="_blank" class="hover:text-accent transition font-medium">prestaregestao.com.br</a>
          </div>
        </div>

        <!-- Painel Direito (Formulário de Login) -->
        <div class="w-full lg:w-[45%] flex flex-col justify-center items-center px-6 md:px-16 py-12 bg-slate-950/70 backdrop-blur-md">
          
          <div class="w-full max-w-md space-y-8">
            
            <!-- Header de Mobile (Visível apenas em telas pequenas) -->
            <div class="text-center lg:hidden">
              <div class="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-accent/10 border border-accent/20 mb-3 shadow-lg shadow-accent/5">
                <svg class="w-6 h-6 text-accent animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                </svg>
              </div>
              <h1 class="text-2xl font-bold text-white tracking-tight">Prestare <span class="text-accent">Click</span></h1>
              <p class="text-xs text-slate-400 mt-1">Acesso restrito ao console de portaria</p>
            </div>

            <!-- Header do formulário para telas grandes -->
            <div class="hidden lg:block space-y-2">
              <h2 class="text-3xl font-extrabold text-white tracking-tight">Painel de Acesso</h2>
              <p class="text-sm text-slate-400 font-light">Entre com as suas credenciais para iniciar o turno.</p>
            </div>

            <!-- Formulário -->
            <form (ngSubmit)="onSubmit()" class="space-y-5">
              
              <div class="space-y-2">
                <label class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Identificador / Usuário</label>
                <div class="relative group">
                  <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-500 pointer-events-none group-focus-within:text-accent transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                    </svg>
                  </span>
                  <input
                    type="text"
                    [(ngModel)]="loginValue"
                    name="login"
                    autocomplete="username"
                    class="w-full bg-slate-900/60 border border-white/10 rounded-xl pl-10 pr-4 py-3.5 text-xs text-white
                           placeholder-slate-600 focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent/30 transition shadow-inner"
                    placeholder="Ex: portaria_centro"
                    required
                  />
                </div>
              </div>

              <div class="space-y-2">
                <div class="flex items-center justify-between">
                  <label class="block text-xs font-semibold text-slate-400 uppercase tracking-wider">Senha de Segurança</label>
                </div>
                <div class="relative group">
                  <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-500 pointer-events-none group-focus-within:text-accent transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.8" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                    </svg>
                  </span>
                  <input
                    type="password"
                    [(ngModel)]="senhaValue"
                    name="senha"
                    autocomplete="current-password"
                    class="w-full bg-slate-900/60 border border-white/10 rounded-xl pl-10 pr-4 py-3.5 text-xs text-white
                           placeholder-slate-600 focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent/30 transition shadow-inner"
                    placeholder="••••••••"
                    required
                  />
                </div>
              </div>

              <!-- Erro de Login -->
              @if (erro()) {
                <div class="flex items-center gap-2.5 text-xs text-rose-400 bg-rose-400/10 border border-rose-400/20 rounded-xl px-4 py-3 animate-fadeIn">
                  <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2"
                      d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                  </svg>
                  <span>{{ erro() }}</span>
                </div>
              }

              <!-- Botão Entrar -->
              <button
                type="submit"
                [disabled]="carregando()"
                class="w-full bg-accent hover:bg-accent-600 disabled:opacity-50 disabled:cursor-not-allowed
                       text-white font-semibold text-sm rounded-xl px-4 py-3.5 transition shadow-lg shadow-accent/15
                       active:scale-[0.98]"
              >
                @if (carregando()) {
                  <span class="flex items-center justify-center gap-2">
                    <div class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                    <span>Processando Acesso...</span>
                  </span>
                } @else {
                  <span>Entrar no Sistema</span>
                }
              </button>
            </form>

            <!-- Footer Corporativo para Mobile -->
            <div class="text-center lg:hidden pt-8 border-t border-white/5 space-y-1">
              <p class="text-[10px] text-slate-600">© 2026 Prestare Gestão e Tecnologia</p>
              <a href="https://prestaregestao.com.br/novo/" target="_blank" class="text-[10px] text-slate-500 hover:text-accent transition">prestaregestao.com.br</a>
            </div>

          </div>

        </div>

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