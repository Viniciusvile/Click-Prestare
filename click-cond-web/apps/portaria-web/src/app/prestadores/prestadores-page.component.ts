import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CreatePrestador, Prestador, PrestadoresApi } from './prestadores.service';
import { ConfirmService } from '../shared/confirm.service';

@Component({
  selector: 'app-prestadores-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './prestadores-page.component.html',
})
export class PrestadoresPageComponent implements OnInit {
  private api = inject(PrestadoresApi);
  private confirm = inject(ConfirmService);
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
  editingId: number | null = null;
  readonly saving = signal(false);

  ngOnInit() { this.carregar(); }

  carregar() {
    this.loading.set(true);
    this.api.list(this.search() || undefined).subscribe({
      next: (data) => { this.prestadores.set(data); this.loading.set(false); },
      error: (e) => { this.error.set(e?.message ?? 'Erro'); this.loading.set(false); },
    });
  }
  abrirNovo() {
    this.editingId = null;
    this.novo = { nome: '', telefone: '', categorias: '' };
    this.error.set(null);
    this.showForm = true;
  }
  abrirEditar(p: Prestador) {
    this.editingId = p.id;
    this.novo = {
      nome: p.nome,
      telefone: p.telefone ?? '',
      categorias: p.categorias ?? '',
    };
    this.error.set(null);
    this.showForm = true;
  }
  cancelarForm() {
    this.showForm = false;
    this.editingId = null;
    this.error.set(null);
  }
  salvar() {
    if (!this.novo.nome?.trim()) { this.error.set('Nome é obrigatório.'); return; }
    this.saving.set(true);
    const obs = this.editingId
      ? this.api.update(this.editingId, this.novo)
      : this.api.create(this.novo);
    obs.subscribe({
      next: () => {
        this.saving.set(false);
        this.cancelarForm();
        this.novo = { nome: '', telefone: '', categorias: '' };
        this.carregar();
      },
      error: (e) => {
        this.saving.set(false);
        this.error.set(e?.error?.message ?? e?.message ?? 'Erro');
      },
    });
  }
  async remover(p: Prestador) {
    const ok = await this.confirm.ask({
      title: 'Remover prestador',
      message: `${p.nome} será removido da lista de autorizados.`,
      confirmLabel: 'Remover',
      variant: 'danger',
    });
    if (!ok) return;
    this.api.remove(p.id).subscribe({ next: () => this.carregar() });
  }
  categoriasArray(p: Prestador): string[] {
    return (p.categorias ?? '').split(';').map((c) => c.trim()).filter(Boolean);
  }
  iniciais(nome: string): string {
    return nome.trim().split(/\s+/).slice(0, 2).map((s) => s[0]?.toUpperCase() ?? '').join('');
  }
}
