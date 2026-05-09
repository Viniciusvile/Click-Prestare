import 'dart:async';

import 'package:click/controllers/controller_financeiro.dart';
import 'package:click/pages/shared/financeiro/finan_relatorio.dart';
import 'package:click/pages/shared/financeiro/list_inadimplentes.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_despesa.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_morador.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_receita.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListFinanceiro extends StatefulWidget {
  const ListFinanceiro({Key? key}) : super(key: key);
  @override
  _ListFinanceiroPageState createState() => _ListFinanceiroPageState();
}

class _ListFinanceiroPageState extends State<ListFinanceiro> {
  bool _isLoading = false;
  List<dynamic> titlesTabs = [];
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> lancamentos = {};
  String tabSelected = "";
  String saldoAtual = '';
  String dia = '--/--/----';
  String mes = '';
  String ano = '';

  @override
  void initState() {
    super.initState();
    saldoAtual = '${Singleton.instance.getCurrentMoeda()} 0,00';
    loadList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadList() async {
    try {
      setState(() => _isLoading = true);
      final locals = await apiGetAllFinanceiro("financeiro", mes, ano);
      lancamentos = locals['lancamentos'];
      saldoAtual = (locals['saldo'] as String).replaceAll("R\$", Singleton.instance.getCurrentMoeda());
      dia = locals['dia'];
      titlesTabs = locals['meses'];
      if (tabSelected.isEmpty && titlesTabs.isNotEmpty) {
        tabSelected = titlesTabs.last['periodo'];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void changeMonth(String month, String newMes, String newAno) {
    setState(() { tabSelected = month; mes = newMes; ano = newAno; });
    loadList();
  }

  int getCountStatus(int pago) {
    var count = 0;
    for (var data in lancamentos.values) {
      for (var l in data) { if (l["pago"] == pago) count++; }
    }
    return count;
  }

  void _openLancamento(dynamic item) {
    if (getUserType() != 'sindico') return;
    Widget page;
    if (item['tipo'] == 'C') {
      page = item['categoria'] == 'Arrecadação'
          ? NewFinanceiroMorador(id: item['id'], apto: null)
          : NewFinanceiroReceita(id: item['id']);
    } else {
      page = NewFinanceiroDespesa(id: item['id']);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => loadList());
  }

  @override
  Widget build(BuildContext context) {
    final isSindico = getUserType() == 'sindico';
    return AppScaffold(
      title: getText('lb_financeiro'),
      actions: isSindico
          ? [
              PopupMenuButton<String>(
                icon: Icon(PhosphorIcons.dotsThreeVertical, color: AppColors.textPrimary(context)),
                onSelected: (v) {
                  if (v == 'inadimplentes') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ListInadimplestes()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FinanceiroRelatorio()));
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'inadimplentes', child: Text(getText('financeiro_inadimplentes'))),
                  PopupMenuItem(value: 'relatorio', child: Text(getText('financeiro_nav_relatorio'))),
                ],
              )
            ]
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadList,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 28,
                            child: ListView.separated(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: titlesTabs.length,
                              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                              itemBuilder: (_, i) {
                                final t = titlesTabs[i];
                                final selected = tabSelected == t['periodo'];
                                return GestureDetector(
                                  onTap: selected ? null : () => changeMonth(t['periodo'], t['mes'], t['ano']),
                                  child: Text(
                                    t['periodo'],
                                    style: AppTypography.captionMedium(context).copyWith(
                                      color: selected ? AppColors.primary : AppColors.textSecondary(context),
                                      decoration: selected ? TextDecoration.underline : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SaldoCard(saldoAtual: saldoAtual, dia: dia, mes: tabSelected),
                          const SizedBox(height: AppSpacing.md),
                          if (isSindico)
                            Row(
                              children: [
                                _CountChip(
                                  icon: PhosphorIcons.checkCircle,
                                  color: const Color(0xFF22C55E),
                                  label: '${getCountStatus(1)} ${getText('pagos')}',
                                  context: context,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                _CountChip(
                                  icon: PhosphorIcons.clock,
                                  color: const Color(0xFFF59E0B),
                                  label: '${getCountStatus(0)} ${getText('lb_pendentes')}',
                                  context: context,
                                ),
                              ],
                            ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                  if (lancamentos.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: AppColors.surface(context), borderRadius: BorderRadius.circular(12)),
                        child: Text(getText('financeiro_sem_lancamentos'), style: AppTypography.caption(context)),
                      ),
                    ),
                  for (final data in lancamentos.keys)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data, style: AppTypography.captionMedium(context).copyWith(color: AppColors.textSecondary(context))),
                            const SizedBox(height: AppSpacing.sm),
                            for (var item in lancamentos[data])
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _LancamentoCard(item: item, onTap: () => _openLancamento(item)),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: isSindico
          ? FloatingActionButton(
              onPressed: loadList,
              backgroundColor: AppColors.primary,
              child: const Icon(PhosphorIcons.arrowsClockwise, color: Colors.white),
            )
          : null,
    );
  }
}

class _SaldoCard extends StatelessWidget {
  final String saldoAtual;
  final String dia;
  final String mes;
  const _SaldoCard({required this.saldoAtual, required this.dia, required this.mes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF0077C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo em $mes', style: AppTypography.caption(context).copyWith(color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 4),
          Text(saldoAtual, style: AppTypography.title(context).copyWith(color: Colors.white, fontSize: 28)),
          const SizedBox(height: 8),
          Text('Atualizado: $dia', style: AppTypography.tiny(context).copyWith(color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final BuildContext context;
  const _CountChip({required this.icon, required this.color, required this.label, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.tiny(context).copyWith(color: color)),
        ],
      ),
    );
  }
}

class _LancamentoCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  const _LancamentoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCredito = item['tipo'] == 'C';
    final isPago = item['pago'] == 1;
    final color = isCredito ? const Color(0xFF22C55E) : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface(context), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(isCredito ? PhosphorIcons.arrowDown : PhosphorIcons.arrowUp, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['descricao'] ?? item['categoria'] ?? '', style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(item['categoria'] ?? '', style: AppTypography.caption(context)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item['valor']?.toString() ?? '', style: AppTypography.captionMedium(context).copyWith(color: color)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPago ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isPago ? getText('pagos') : getText('lb_pendentes'),
                    style: AppTypography.tiny(context).copyWith(color: isPago ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
