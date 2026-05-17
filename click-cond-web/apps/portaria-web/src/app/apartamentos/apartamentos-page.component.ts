import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  Apartamento, ApartamentosApi, CreateApartamento,
} from './apartamentos.service';
import { ConfirmService } from '../shared/confirm.service';

@Component({
  selector: 'app-apartamentos-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './apartamentos-page.component.html',
})
export class ApartamentosPageComponent implements OnInit {
  private api = inject(ApartamentosApi);
  private confirm = inject(ConfirmService);
  readonly apartamentos = signal<Apartamento[]>([]);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly search = signal('');
  readonly viewMode = signal<'grid' | 'tabela'>('grid');

  readonly blocos = computed(() => {
    const map = new Map<string, Apartamento[]>();
    for (const a of this.apartamentos()) {
      const k = a.bloco || 'Sem bloco';
      if (!map.has(k)) map.set(k, []);
      map.get(k)!.push(a);
    }
    return Array.from(map.entries())
      .map(([nome, aptos]) => ({ nome, aptos: aptos.sort((x,y) => x.apto.localeCompare(y.apto, 'pt', { numeric: true })) }))
      .sort((a, b) => a.nome.localeCompare(b.nome));
  });

  readonly totalMoradores = computed(() =>
    this.apartamentos().reduce((sum, a) => sum + (a.qtdMoradores ?? 0), 0),
  );
  readonly aptosOcupados = computed(() =>
    this.apartamentos().filter((a) => (a.qtdMoradores ?? 0) > 0).length,
  );
  readonly aptosVazios = computed(() => this.apartamentos().length - this.aptosOcupados());

  novo: CreateApartamento = { apto: '', bloco: '', fracao: '' };
  showForm = false;
  editingId: number | null = null;
  readonly saving = signal(false);

  ngOnInit() { this.carregar(); }

  carregar() {
    this.loading.set(true);
    this.api.list(this.search() || undefined).subscribe({
      next: (data) => { this.apartamentos.set(data); this.loading.set(false); },
      error: (e) => { this.error.set(e?.message ?? 'Erro'); this.loading.set(false); },
    });
  }
  abrirNovo() {
    this.editingId = null;
    this.novo = { apto: '', bloco: '', fracao: '' };
    this.error.set(null);
    this.showForm = true;
  }
  abrirEditar(a: Apartamento) {
    this.editingId = a.id;
    this.novo = { apto: a.apto, bloco: a.bloco ?? '', fracao: a.fracao ?? '' };
    this.error.set(null);
    this.showForm = true;
  }
  cancelarForm() {
    this.showForm = false;
    this.editingId = null;
    this.error.set(null);
  }
  salvar() {
    if (!this.novo.apto?.trim()) { this.error.set('Apto é obrigatório.'); return; }
    this.saving.set(true);
    const obs = this.editingId
      ? this.api.update(this.editingId, this.novo)
      : this.api.create(this.novo);
    obs.subscribe({
      next: () => {
        this.saving.set(false);
        this.cancelarForm();
        this.novo = { apto: '', bloco: '', fracao: '' };
        this.carregar();
      },
      error: (e) => {
        this.saving.set(false);
        this.error.set(e?.error?.message ?? e?.message ?? 'Erro');
      },
    });
  }
  async remover(a: Apartamento) {
    const ok = await this.confirm.ask({
      title: 'Remover apartamento',
      message: `O apto ${a.bloco ? a.bloco + ' / ' : ''}${a.apto} será removido. Moradores vinculados serão desvinculados.`,
      confirmLabel: 'Remover',
      variant: 'danger',
    });
    if (!ok) return;
    this.api.remove(a.id).subscribe({ next: () => this.carregar() });
  }
}
