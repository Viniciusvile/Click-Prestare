import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface Lancamento {
  id: number;
  nome: string;
  tipo: string; // 'C' ou 'D'
  valor: number;
  valorString: string;
  saldoString: string;
  categoria: string;
  nome_operador?: string;
  pago: number;
  status?: string;
  url_boleto?: string;
  url_comprovante?: string;
}

export interface GraficoCategoria {
  categoria: string;
  saldo: number;
  saldoReal: string;
  tipo: string;
  percentualString: string;
}

@Injectable({ providedIn: 'root' })
export class FinanceiroApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get cid() {
    return this.auth.porteiroInfo()?.id_condominio ?? 1;
  }

  listLancamentos(mes: string, ano: string): Observable<any> {
    const url = `${API_BASE}/financeiro/get-all?id_condominio=${this.cid}&mes=${mes}&ano=${ano}`;
    return this.http.get<any>(url);
  }

  listInadimplentes(): Observable<any> {
    const url = `${API_BASE}/financeiro/inadimplentes/get-all?id_condominio=${this.cid}`;
    return this.http.get<any>(url);
  }

  getGrafico(mes: string, ano: string): Observable<any> {
    const url = `${API_BASE}/financeiro/grafico/get-all?id_condominio=${this.cid}&mes=${mes}&ano=${ano}`;
    return this.http.get<any>(url);
  }

  insertLancamento(payload: any): Observable<any> {
    const url = `${API_BASE}/financeiro/insert`;
    return this.http.post(url, { id_condominio: this.cid, financeiro: payload });
  }

  updateStatus(id: number, status: string | number): Observable<any> {
    const url = `${API_BASE}/financeiro/update-status`;
    return this.http.post(url, { id, status });
  }

  uploadSharedFile(id: number, fileBase64: string, type: string): Observable<any> {
    const url = `${API_BASE}/financeiro/upload-shared-file`;
    return this.http.post(url, { id, file: fileBase64, type });
  }
}
