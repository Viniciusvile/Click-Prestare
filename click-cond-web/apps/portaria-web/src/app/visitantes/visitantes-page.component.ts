import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { VisitantesService } from './visitantes.service';
import { ApartamentosApi, Apartamento } from '../apartamentos/apartamentos.service';
import { CreateVisitante, Visitante } from './visitante.model';

@Component({
  selector: 'app-visitantes-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './visitantes-page.component.html',
  styleUrl: './visitantes-page.component.css',
})
export class VisitantesPageComponent implements OnInit {
  private service = inject(VisitantesService);
  private aptApi = inject(ApartamentosApi);

  readonly visitantes = signal<Visitante[]>([]);
  readonly apartamentos = signal<Apartamento[]>([]);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly search = signal('');
  readonly viewFilter = signal<'todos' | 'ativos' | 'historico'>('todos');

  readonly visitantesAtivos = computed(() =>
    this.visitantes().filter((v) => !v.data_hora_termino),
  );
  readonly visitantesHistorico = computed(() =>
    this.visitantes().filter((v) => !!v.data_hora_termino),
  );
  readonly visitantesFiltrados = computed(() => {
    const f = this.viewFilter();
    if (f === 'ativos') return this.visitantesAtivos();
    if (f === 'historico') return this.visitantesHistorico();
    return this.visitantes();
  });

  novo: CreateVisitante = this.estadoInicial();
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
    this.service.list(this.search() || undefined).subscribe({
      next: (data) => {
        this.visitantes.set(data);
        this.loading.set(false);
      },
      error: (e) => {
        this.error.set(`Falha ao carregar: ${e?.message ?? e}`);
        this.loading.set(false);
      },
    });
  }

  registrar() {
    if (!this.novo.nome?.trim() || !this.novo.id_apartamento) {
      this.error.set('Informe nome e selecione o apartamento.');
      return;
    }
    this.service.create(this.novo).subscribe({
      next: () => {
        this.showForm = false;
        this.novo = this.estadoInicial();
        this.carregar();
      },
      error: (e) => this.error.set(`Falha ao registrar: ${e?.message ?? e}`),
    });
  }

  remover(v: Visitante) {
    if (!confirm(`Remover registro de ${v.nome}?`)) return;
    this.service.remove(v.id).subscribe({
      next: () => this.carregar(),
      error: (e) => this.error.set(`Falha ao remover: ${e?.message ?? e}`),
    });
  }

  iniciais(nome: string): string {
    return nome.trim().split(/\s+/).slice(0, 2).map((s) => s[0]?.toUpperCase() ?? '').join('');
  }

  duracao(v: Visitante): string {
    if (!v.data_hora_inicio) return '—';
    const inicio = new Date(v.data_hora_inicio).getTime();
    const fim = v.data_hora_termino ? new Date(v.data_hora_termino).getTime() : Date.now();
    const min = Math.floor((fim - inicio) / 60000);
    if (min < 1) return 'agora';
    if (min < 60) return `${min} min`;
    const h = Math.floor(min / 60);
    const m = min % 60;
    return m > 0 ? `${h}h ${m}min` : `${h}h`;
  }

  private estadoInicial(): CreateVisitante {
    return {
      nome: '',
      doc_identificacao: '',
      id_apartamento: 0,
      is_visitante: 1,
      is_prestador: 0,
    };
  }
}
