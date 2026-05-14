import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FinanceiroApi, Lancamento } from './financeiro.service';

@Component({
  selector: 'app-financeiro-page',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './financeiro-page.component.html',
})
export class FinanceiroPageComponent implements OnInit {
  private api = inject(FinanceiroApi);

  readonly loading = signal(true);
  readonly tab = signal<'lancamentos' | 'graficos' | 'inadimplencia'>('lancamentos');

  // Dados
  readonly sumario = signal<{ totalReceita: string; totalDespesa: string; saldo: string }>({ totalReceita: 'R$ 0,00', totalDespesa: 'R$ 0,00', saldo: 'R$ 0,00' });
  readonly lancamentosMap = signal<Record<string, Lancamento[]>>({});
  readonly mesesDisponiveis = signal<any[]>([]);
  readonly inadimplentesBlocos = signal<any[]>([]);
  readonly dadosGrafico = signal<any>(null);

  // Período de Consumo
  selectedMesAno: string = '05|2026';

  // Modais
  readonly modalLancamento = signal(false);
  novoLancamento: any = { nome: '', tipo: 'C', valor: null, data: '', data_vencimento: '', categoria: 'Receitas' };

  ngOnInit() {
    // Configura o mês atual inicialmente
    const hoje = new Date();
    const mStr = hoje.getMonth() + 1 < 10 ? '0' + (hoje.getMonth() + 1) : String(hoje.getMonth() + 1);
    this.selectedMesAno = `${mStr}|${hoje.getFullYear()}`;

    this.carregarDados();
    this.carregarInadimplencia();
  }

  carregarDados() {
    this.loading.set(true);
    const [m, a] = this.selectedMesAno.split('|');

    this.api.listLancamentos(m, a).subscribe(res => {
      this.lancamentosMap.set(res?.lancamentos || {});
      this.sumario.set({
        totalReceita: res?.totalReceita || 'R$ 0,00',
        totalDespesa: res?.totalDespesa || 'R$ 0,00',
        saldo: res?.saldo || 'R$ 0,00',
      });

      if (res?.meses && Array.isArray(res.meses)) {
        this.mesesDisponiveis.set(res.meses);
      }

      // Aproveita e carrega o gráfico associado a este mês
      this.api.getGrafico(m, a).subscribe(graf => {
        this.dadosGrafico.set(graf);
        this.loading.set(false);
      });
    });
  }

  carregarInadimplencia() {
    this.api.listInadimplentes().subscribe(res => {
      this.inadimplentesBlocos.set(res?.blocos || []);
    });
  }

  onPeriodoChange() {
    this.carregarDados();
  }

  getDiasChaves(): string[] {
    return Object.keys(this.lancamentosMap());
  }

  // Ações Operacionais
  alternarPago(item: Lancamento) {
    const novoStatus = item.pago === 1 ? 0 : 1;
    this.api.updateStatus(item.id, novoStatus).subscribe(() => {
      this.carregarDados();
    });
  }

  aprovarPagamento(id: number) {
    // Status 1 = Aprovado/Pago
    this.api.updateStatus(id, 1).subscribe(() => {
      this.carregarDados();
    });
  }

  abrirModalLancamento() {
    const hoje = new Date();
    const dFmt = hoje.toLocaleDateString('pt-BR');
    this.novoLancamento = { nome: '', tipo: 'C', valor: null, data: dFmt, data_vencimento: dFmt, categoria: 'Receitas' };
    this.modalLancamento.set(true);
  }

  salvarLancamento() {
    this.api.insertLancamento(this.novoLancamento).subscribe(() => {
      this.modalLancamento.set(false);
      this.carregarDados();
    });
  }
}
