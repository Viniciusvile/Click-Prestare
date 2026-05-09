import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CreatePrestador, Prestador, PrestadoresApi } from './prestadores.service';

@Component({
  selector: 'app-prestadores-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './prestadores-page.component.html',
})
export class PrestadoresPageComponent implements OnInit {
  private api = inject(PrestadoresApi);
  readonly prestadores = signal<Prestador[]>([]);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly search = signal('');
  readonly filtroCategoria = signal<string>('');

  readonly categoriasUnicas = computed(() => {
    const set = new Set<string>();
    for (const p of this.prestadores()) {
      for (const c of (p.categorias ?? '').split(';').map((x) => x.trim()).filter(Boolean)) {
        set.add(c);
      }
    }
    return Array.from(set).sort();
  });

  readonly prestadoresFiltrados = computed(() => {
    const cat = this.filtroCategoria();
    if (!cat) return this.prestadores();
    return this.prestadores().filter((p) =>
      this.categoriasArray(p).some((c) => c.toLowerCase() === cat.toLowerCase()),
    );
  });

  novo: CreatePrestador = { nome: '', telefone: '', categorias: '' };
  showForm = false;

  ngOnInit() { this.carregar(); }

  carregar() {
    this.loading.set(true);
    this.api.list(this.search() || undefined).subscribe({
      next: (data) => { this.prestadores.set(data); this.loading.set(false); },
      error: (e) => { this.error.set(e?.message ?? 'Erro'); this.loading.set(false); },
    });
  }
  registrar() {
    if (!this.novo.nome?.trim()) { this.error.set('Nome é obrigatório.'); return; }
    this.api.create(this.novo).subscribe({
      next: () => { this.showForm = false; this.novo = { nome: '', telefone: '', categorias: '' }; this.carregar(); },
      error: (e) => this.error.set(e?.message ?? 'Erro'),
    });
  }
  remover(p: Prestador) {
    if (!confirm(`Remover ${p.nome}?`)) return;
    this.api.remove(p.id).subscribe({ next: () => this.carregar() });
  }
  categoriasArray(p: Prestador): string[] {
    return (p.categorias ?? '').split(';').map((c) => c.trim()).filter(Boolean);
  }
  iniciais(nome: string): string {
    return nome.trim().split(/\s+/).slice(0, 2).map((s) => s[0]?.toUpperCase() ?? '').join('');
  }
}
