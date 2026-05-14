import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AgendamentoArea, AreaSocial, AreasSociaisApi } from './areas-sociais.service';

@Component({
  selector: 'app-areas-sociais-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './areas-sociais-page.component.html',
})
export class AreasSociaisPageComponent implements OnInit {
  private api = inject(AreasSociaisApi);

  readonly areas = signal<AreaSocial[]>([]);
  readonly agendamentos = signal<AgendamentoArea[]>([]);
  readonly loading = signal(true);
  readonly tab = signal<'areas' | 'reservas'>('areas');

  // Controle do Modal
  readonly modalAberto = signal(false);
  novaArea: any = { nome: '', capacidade: null, imagem: '', agendar: true, autorizacao: true };

  readonly pendentesCount = computed(() =>
    this.agendamentos().filter(a => a.status === 'pendente').length
  );

  readonly aprovadasCount = computed(() =>
    this.agendamentos().filter(a => a.status === 'aprovado').length
  );

  ngOnInit() {
    this.carregarDados();
  }

  carregarDados() {
    this.loading.set(true);
    this.api.listAreas().subscribe(areas => {
      this.areas.set(areas);
      this.api.listAgendamentos().subscribe(ag => {
        this.agendamentos.set(ag);
        this.loading.set(false);
      });
    });
  }

  alterarStatus(id: number, isAccept: boolean) {
    this.api.updateStatus(id, isAccept).subscribe(() => {
      // Atualizar lista local na hora
      this.agendamentos.update(list =>
        list.map(item => item.id === id ? { ...item, status: isAccept ? 'aprovado' : 'recusado' } : item)
      );
    });
  }

  excluirArea(id: number) {
    if (confirm('Tem certeza que deseja excluir este espaço?')) {
      this.api.removeArea(id).subscribe(() => {
        this.areas.update(list => list.filter(a => a.id !== id));
      });
    }
  }

  abrirModalArea() {
    this.novaArea = { nome: '', capacidade: null, imagem: '', agendar: true, autorizacao: true };
    this.modalAberto.set(true);
  }

  fecharModal() {
    this.modalAberto.set(false);
  }

  salvarArea() {
    const payload = {
      nome: this.novaArea.nome,
      capacidade: this.novaArea.capacidade,
      imagem: this.novaArea.imagem || 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600',
      agendar: this.novaArea.agendar ? 1 : 0,
      autorizacao: this.novaArea.autorizacao ? 1 : 0,
      horarios: Array.from({ length: 7 }).map(() => ({
        horarios: [{ horarioDe: '08:00', horarioAte: '22:00' }]
      }))
    };

    this.api.insertArea(payload).subscribe(() => {
      this.fecharModal();
      this.carregarDados();
    });
  }
}
