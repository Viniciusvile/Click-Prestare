import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  CreateEncomenda, Encomenda, EncomendasApi,
} from './encomendas.service';

@Component({
  selector: 'app-encomendas-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './encomendas-page.component.html',
})
export class EncomendasPageComponent implements OnInit {
  private api = inject(EncomendasApi);

  readonly encomendas = signal<Encomenda[]>([]);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly filtro = signal<string>('');

  readonly aguardando = computed(() => this.encomendas().filter((e) => e.status === 'Aguardando').length);
  readonly retiradas = computed(() => this.encomendas().filter((e) => e.status === 'Retirada').length);

  novo: CreateEncomenda = this.estadoInicial();
  showForm = false;

  ngOnInit() { this.carregar(); }

  carregar() {
    this.loading.set(true);
    this.api.list(this.filtro() || undefined).subscribe({
      next: (data) => { this.encomendas.set(data); this.loading.set(false); },
      error: (e) => { this.error.set(e?.message ?? 'Erro'); this.loading.set(false); },
    });
  }

  registrar() {
    if (!this.novo.descricao?.trim() || !this.novo.destinatario_apto?.trim()) {
      this.error.set('Descrição e apto destinatário são obrigatórios.');
      return;
    }
    this.api.create(this.novo).subscribe({
      next: () => { this.showForm = false; this.novo = this.estadoInicial(); this.carregar(); },
      error: (e) => this.error.set(e?.message ?? 'Erro'),
    });
  }

  retirar(e: Encomenda) {
    const por = prompt(`Quem está retirando "${e.descricao}"?\nNome do morador:`);
    if (!por) return;
    this.api.retirar(e.id, por).subscribe({ next: () => this.carregar() });
  }

  imprimir(e: Encomenda) {
    const w = window.open('', '_blank', 'width=400,height=300');
    if (!w) return;
    w.document.write(`
      <html><head><title>Etiqueta #${e.id}</title>
      <style>
        body{font-family:Arial,sans-serif;padding:20px;margin:0}
        .label{border:2px solid #000;padding:16px;border-radius:8px}
        .id{font-size:11px;color:#666;letter-spacing:2px;text-transform:uppercase}
        .apto{font-size:48px;font-weight:bold;margin:8px 0;letter-spacing:-1px}
        .desc{font-size:14px;margin:8px 0;border-top:1px dashed #999;padding-top:8px}
        .meta{font-size:11px;color:#666;margin-top:12px}
      </style></head><body>
      <div class="label">
        <div class="id">Encomenda #${e.id}</div>
        <div class="apto">${e.destinatario_bloco ? e.destinatario_bloco + ' / ' : ''}${e.destinatario_apto}</div>
        <div class="desc">${e.descricao}</div>
        <div class="meta">Recebido de: ${e.recebido_de ?? '—'}<br>Em: ${new Date(e.recebido_em).toLocaleString('pt-BR')}</div>
      </div>
      <script>window.onload=()=>window.print()</script>
      </body></html>
    `);
    w.document.close();
  }

  remover(e: Encomenda) {
    if (!confirm('Remover encomenda?')) return;
    this.api.remove(e.id).subscribe({ next: () => this.carregar() });
  }

  diasArmazenada(e: Encomenda): number {
    const recebido = new Date(e.recebido_em).getTime();
    const ref = e.retirado_em ? new Date(e.retirado_em).getTime() : Date.now();
    return Math.floor((ref - recebido) / 86400000);
  }

  private estadoInicial(): CreateEncomenda {
    return { descricao: '', destinatario_apto: '', destinatario_bloco: '', recebido_de: '' };
  }
}
