import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Comunicado, ComunicadosApi } from './comunicados.service';

@Component({
  selector: 'app-comunicados-page',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="min-h-screen p-6 lg:p-8 space-y-6">

      <!-- Header -->
      <div class="flex items-start gap-4">
        <div class="w-11 h-11 rounded-xl bg-accent/10 border border-accent/20 flex items-center justify-center shrink-0">
          <svg class="w-5 h-5 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
          </svg>
        </div>
        <div>
          <h1 class="text-2xl font-semibold text-white tracking-tight">Comunicados</h1>
          <p class="text-sm text-slate-400 mt-0.5">Avisos do síndico e administração · informações para a portaria</p>
        </div>
      </div>

      <!-- Stats -->
      <div class="grid grid-cols-3 gap-3">
        <div class="px-4 py-3 rounded-xl bg-graphite-200 border border-white/10">
          <p class="text-[11px] text-slate-400 uppercase tracking-wider">Total publicados</p>
          <p class="text-2xl font-bold text-white tabular-nums mt-1 leading-none">{{ comunicados().length }}</p>
        </div>
        <div class="px-4 py-3 rounded-xl bg-graphite-200 border border-white/10">
          <p class="text-[11px] text-slate-400 uppercase tracking-wider">Últimos 7 dias</p>
          <p class="text-2xl font-bold text-accent tabular-nums mt-1 leading-none">{{ recentes() }}</p>
        </div>
        <div class="px-4 py-3 rounded-xl bg-graphite-200 border border-white/10">
          <p class="text-[11px] text-slate-400 uppercase tracking-wider">Mais recente</p>
          <p class="text-sm font-medium text-slate-300 mt-1 leading-none">
            {{ ultimo() ? (ultimo()!.created_at | date:'dd/MM HH:mm') : '—' }}
          </p>
        </div>
      </div>

      <!-- Conteúdo -->
      @if (loading()) {
        <div class="p-12 text-center rounded-2xl bg-graphite-200 border border-white/10">
          <div class="inline-block w-6 h-6 border-2 border-accent/30 border-t-accent rounded-full animate-spin"></div>
        </div>
      } @else if (comunicados().length === 0) {
        <div class="p-12 text-center rounded-2xl bg-graphite-200 border border-white/10">
          <div class="w-12 h-12 rounded-xl bg-white/5 mx-auto flex items-center justify-center mb-3">
            <svg class="w-6 h-6 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5"/>
            </svg>
          </div>
          <p class="text-sm text-slate-300 font-medium">Nenhum comunicado publicado</p>
          <p class="text-xs text-slate-500 mt-1">Avisos da administração aparecerão aqui</p>
        </div>
      } @else {
        <div class="space-y-3">
          @for (c of comunicados(); track c.id; let i = $index) {
            <article class="p-5 rounded-2xl bg-graphite-200 border transition"
                     [class.border-accent/30]="i === 0 && isRecent(c)"
                     [class.border-white/10]="!(i === 0 && isRecent(c))">
              <div class="flex items-start gap-4">
                <div class="w-9 h-9 rounded-xl bg-accent/10 border border-accent/20 flex items-center justify-center shrink-0">
                  <svg class="w-4 h-4 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                      d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"/>
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex items-start justify-between gap-3 mb-2">
                    <div class="flex items-center gap-2 flex-wrap">
                      <h2 class="text-base font-semibold text-white">{{ c.titulo }}</h2>
                      @if (isRecent(c)) {
                        <span class="text-[10px] px-1.5 py-0.5 rounded-md bg-accent/15 border border-accent/25 text-accent uppercase tracking-wider">Novo</span>
                      }
                    </div>
                    <span class="text-xs text-slate-500 shrink-0 font-mono">{{ c.created_at | date: 'dd/MM/yy HH:mm' }}</span>
                  </div>
                  <p class="text-sm text-slate-300 leading-relaxed whitespace-pre-line">{{ c.descricao }}</p>
                </div>
              </div>
            </article>
          }
        </div>
      }
    </div>
  `,
})
export class ComunicadosPageComponent implements OnInit {
  private api = inject(ComunicadosApi);
  readonly comunicados = signal<Comunicado[]>([]);
  readonly loading = signal(true);

  readonly ultimo = computed(() => this.comunicados()[0] ?? null);
  readonly recentes = computed(() => this.comunicados().filter((c) => this.isRecent(c)).length);

  ngOnInit() {
    this.api.list().subscribe({
      next: (data) => { this.comunicados.set(data); this.loading.set(false); },
      error: () => this.loading.set(false),
    });
  }

  isRecent(c: Comunicado): boolean {
    const created = new Date(c.created_at).getTime();
    return Date.now() - created < 7 * 86400000;
  }
}
