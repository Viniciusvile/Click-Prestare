import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CreateMorador, Morador, MoradoresApi } from './moradores.service';
import { ApartamentosApi, Apartamento } from '../apartamentos/apartamentos.service';

@Component({
  selector: 'app-moradores-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './moradores-page.component.html',
})
export class MoradoresPageComponent implements OnInit {
  private api = inject(MoradoresApi);
  private aptApi = inject(ApartamentosApi);

  readonly moradores = signal<Morador[]>([]);
  readonly apartamentos = signal<Apartamento[]>([]);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly search = signal('');
  readonly filtroTipo = signal<string>('');

  readonly moradoresFiltrados = computed(() => {
    const t = this.filtroTipo();
    if (!t) return this.moradores();
    return this.moradores().filter((m) => (m.tipo ?? '').toLowerCase() === t);
  });
  readonly stats = computed(() => {
    const list = this.moradores();
    return {
      total: list.length,
      proprietarios: list.filter((m) => m.tipo?.toLowerCase() === 'proprietario').length,
      inquilinos: list.filter((m) => m.tipo?.toLowerCase() === 'inquilino').length,
      dependentes: list.filter((m) => m.tipo?.toLowerCase() === 'dependente').length,
    };
  });

  novo: CreateMorador = this.estadoInicial();
  showForm = false;

  ngOnInit() {
    this.carregar();
    this.aptApi.list().subscribe({
      next: (data) => this.apartamentos.set(data),
    });
  }

  carregar() {
    this.loading.set(true);
    this.error.set(null);
    this.api.list(this.search() || undefined).subscribe({
      next: (data) => { this.moradores.set(data); this.loading.set(false); },
      error: (e) => { this.error.set(e?.message ?? 'Erro'); this.loading.set(false); },
    });
  }
  registrar() {
    if (!this.novo.nome?.trim() || !this.novo.id_apartamento) {
      this.error.set('Nome e apartamento são obrigatórios.');
      return;
    }
    this.api.create(this.novo).subscribe({
      next: () => { this.showForm = false; this.novo = this.estadoInicial(); this.carregar(); },
      error: (e) => this.error.set(e?.message ?? 'Erro'),
    });
  }
  remover(m: Morador) {
    if (!confirm(`Remover ${m.nome}?`)) return;
    this.api.remove(m.id).subscribe({ next: () => this.carregar() });
  }

  iniciais(nome: string): string {
    return nome.trim().split(/\s+/).slice(0, 2).map((s) => s[0]?.toUpperCase() ?? '').join('');
  }

  tipoColor(tipo: string | null): string {
    const t = (tipo ?? '').toLowerCase();
    if (t === 'proprietario') return 'bg-accent/10 border-accent/20 text-accent';
    if (t === 'inquilino') return 'bg-amber-400/10 border-amber-400/20 text-amber-400';
    if (t === 'dependente') return 'bg-slate-400/10 border-slate-400/20 text-slate-300';
    return 'bg-white/5 border-white/10 text-slate-400';
  }

  private estadoInicial(): CreateMorador {
    return { nome: '', documento: '', email: '', telefone: '', tipo: 'proprietario', id_apartamento: 0 };
  }
}
