import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-politica-privacidade',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="min-h-screen bg-slate-950 text-slate-300 py-12 px-4 sm:px-6 lg:px-8 selection:bg-emerald-500 selection:text-slate-950">
      <div class="max-w-4xl mx-auto space-y-8">
        
        <!-- Cabeçalho -->
        <div class="text-center space-y-3 border-b border-white/10 pb-8">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold uppercase tracking-wider">
            Documento Legal Oficial
          </div>
          <h1 class="text-3xl font-extrabold text-white tracking-tight sm:text-4xl">Política de Privacidade</h1>
          <p class="text-sm text-slate-400">Última atualização: 14 de Maio de 2026</p>
        </div>

        <!-- Conteúdo Legal -->
        <div class="space-y-6 text-sm leading-relaxed">
          <section class="space-y-3">
            <h2 class="text-base font-bold text-white uppercase tracking-wide border-l-2 border-emerald-400 pl-3">1. Introdução</h2>
            <p>
              O sistema <strong>Click Condomínios</strong> (operado em parceria com a Prestare Soluções) valoriza a privacidade dos seus usuários, condôminos, síndicos, porteiros e visitantes. Esta Política de Privacidade descreve como coletamos, usamos, armazenamos e protegemos os seus dados pessoais em conformidade com a <strong>Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018)</strong> e os requisitos de transparência das lojas de aplicativos (Google Play Store e Apple App Store).
            </p>
          </section>

          <section class="space-y-3">
            <h2 class="text-base font-bold text-white uppercase tracking-wide border-l-2 border-emerald-400 pl-3">2. Dados Coletados</h2>
            <p>Coletamos apenas as informações estritamente necessárias para a operação, segurança e gestão do ambiente condominial:</p>
            <ul class="list-disc list-inside space-y-1.5 text-slate-400 ml-2">
              <li><strong class="text-slate-300">Dados Cadastrais:</strong> Nome completo, e-mail, telefone, CPF, bloco e apartamento para autenticação e comunicação oficial.</li>
              <li><strong class="text-slate-300">Controle de Acesso:</strong> Registros de entrada e saída de visitantes e prestadores de serviços (incluindo RG e fotografia capturada na portaria) para segurança patrimonial.</li>
              <li><strong class="text-slate-300">Mídia e Documentos:</strong> Comprovantes de pagamento, fotos de ocorrências e arquivos PDF enviados voluntariamente pelos usuários ou administradores.</li>
            </ul>
          </section>

          <section class="space-y-3">
            <h2 class="text-base font-bold text-white uppercase tracking-wide border-l-2 border-emerald-400 pl-3">3. Finalidade do Tratamento</h2>
            <p>Os seus dados são utilizados exclusivamente para:</p>
            <ul class="list-disc list-inside space-y-1.5 text-slate-400 ml-2">
              <li>Permitir a reserva de áreas sociais, registro de encomendas e abertura de chamados/ocorrências.</li>
              <li>Garantir o direito de voto e deliberação segura em assembleias virtuais e enquetes oficiais do condomínio.</li>
              <li>Auditar e conciliar pagamentos de taxas condominiais no módulo financeiro.</li>
              <li>Notificar os moradores sobre comunicados de emergência ou autorizações na portaria.</li>
            </ul>
          </section>

          <section class="space-y-3">
            <h2 class="text-base font-bold text-white uppercase tracking-wide border-l-2 border-emerald-400 pl-3">4. Compartilhamento e Armazenamento</h2>
            <p>
              Os dados são armazenados em servidores de alta segurança e criptografados em repouso e trânsito. <strong>Não vendemos ou alugamos os seus dados pessoais a terceiros.</strong> O compartilhamento ocorre apenas com a administração legítima do seu condomínio (Síndico e Conselho) e provedores de infraestrutura estritamente sob contratos de confidencialidade.
            </p>
          </section>

          <section class="space-y-3">
            <h2 class="text-base font-bold text-white uppercase tracking-wide border-l-2 border-emerald-400 pl-3">5. Direitos do Titular e Exclusão de Dados</h2>
            <p>
              Em conformidade com a LGPD e as diretrizes do Google Play Console, você tem o direito de solicitar a visualização, correção ou <strong>exclusão completa da sua conta e dados pessoais</strong> a qualquer momento.
            </p>
            <div class="p-4 rounded-xl bg-slate-900 border border-white/5 space-y-2 mt-2">
              <p class="font-semibold text-white text-xs">Como solicitar a exclusão de dados:</p>
              <p class="text-xs text-slate-400">
                Você pode solicitar a remoção da sua conta diretamente pelo aplicativo móvel na seção <em>"Configurações da Conta > Excluir Minha Conta"</em> ou enviando um e-mail formal para a administração do seu condomínio ou para a nossa equipe de suporte técnico através do endereço: <code class="text-emerald-400">suporte&#64;prestare.com.br</code>. O prazo de processamento e remoção definitiva é de até 15 dias úteis, ressalvados os prazos de guarda legal obrigatória para fins de auditoria fiscal e segurança pública.
              </p>
            </div>
          </section>

          <section class="space-y-3">
            <h2 class="text-base font-bold text-white uppercase tracking-wide border-l-2 border-emerald-400 pl-3">6. Contato e Encarregado de Dados (DPO)</h2>
            <p>
              Caso tenha dúvidas sobre o tratamento dos seus dados ou sobre esta política, entre em contato com o nosso Encarregado de Proteção de Dados através do e-mail oficial listado acima.
            </p>
          </section>
        </div>

        <!-- Rodapé Legal -->
        <div class="pt-8 border-t border-white/10 text-center text-xs text-slate-500">
          Click Condomínios &copy; 2026. Todos os direitos reservados. Sistema de Gestão Predial Inteligente.
        </div>
      </div>
    </div>
  `,
})
export class PoliticaPrivacidadeComponent {}
