import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  Apartamento, ApartamentosApi, CreateApartamento,
} from './apartamentos.service';

@Component({
  selector: 'app-apartamentos-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './apartamentos-page.component.html',
})
export class ApartamentosPageComponent implements OnInit {
  private api = inject(ApartamentosApi);
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

  ngOnInit() { this.carregar(); }

  carregar() {
    this.loading.set(true);
    this.api.list(this.search() || undefined).subscribe({
      next: (data) => { this.apartamentos.set(data); this.loading.set(false); },
      error: (e) => { this.error.set(e?.message ?? 'Erro'); this.loading.set(false); },
    });
  }
  registrar() {
    if (!this.novo.apto?.trim()) { this.error.set('Apto é obrigatório.'); return; }
    this.api.create(this.novo).subscribe({
      next: () => { this.showForm = false; this.novo = { apto: '', bloco: '', fracao: '' }; this.carregar(); },
      error: (e) => this.error.set(e?.message ?? 'Erro'),
    });
  }
  remover(a: Apartamento) {
    if (!confirm(`Remover apto ${a.apto}?`)) return;
    this.api.remove(a.id).subscribe({ next: () => this.carregar() });
  }
}
