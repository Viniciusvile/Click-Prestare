import 'package:click/controllers/controller_financeiro.dart';
import 'package:click/pages/shared/financeiro/new_financeiro_morador.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListFinanceiroMoradores extends StatefulWidget {
  const ListFinanceiroMoradores({Key? key}) : super(key: key);

  @override
  _ListFinanceiroMoradoresPageState createState() => _ListFinanceiroMoradoresPageState();
}

class _ListFinanceiroMoradoresPageState extends State<ListFinanceiroMoradores> {
  List<dynamic> blocos = [];
  List<dynamic> titlesTabs = [];
  final ScrollController _tabScroll = ScrollController();

  var _isLoading = false;
  var tabSelected = '';
  var mes = '';
  var ano = '';

  @override
  void initState() {
    super.initState();
    loadList();
  }

  @override
  void dispose() {
    _tabScroll.dispose();
    super.dispose();
  }

  Future<void> loadList() async {
    try {
      setState(() => _isLoading = true);
      var locals = await apiGetAllFinanceiro("financeiro/moradores", mes, "20$ano");
      blocos = locals['blocos'];
      titlesTabs = locals['meses'];
      if (tabSelected == '' && titlesTabs.isNotEmpty) {
        var last = titlesTabs[titlesTabs.length - 1];
        tabSelected = last['periodo'];
        _changeMonth(last['periodo'], last['mes'], last['ano']);
        return;
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeMonth(String month, String newMes, String newAno) {
    tabSelected = month;
    mes = newMes;
    ano = newAno.substring(newAno.length - 2);
    loadList();
  }

  int _getCountStatus(dynamic bloco, int pago) {
    var count = 0;
    for (var apto in bloco['aptos']) {
      count += apto['pago'] == pago ? 1 : 0;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('financeiro_nav_arrecadacoes'),
      body: Column(
        children: [
          if (titlesTabs.isNotEmpty) _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : blocos.isEmpty
                    ? Center(
                        child: Text(
                          getText('alert_nenhum_apto'),
                          style: AppTypography.body(context).copyWith(color: AppColors.textSecondary(context)),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: blocos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) => _BlocoTile(
                          bloco: blocos[i],
                          paid: _getCountStatus(blocos[i], 1),
                          pending: _getCountStatus(blocos[i], 0),
                          onApto: (apto) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NewFinanceiroMorador(apto: apto)),
                            ).then((_) => loadList());
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      color: AppColors.surface(context),
      child: ListView.separated(
        controller: _tabScroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: titlesTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final tab = titlesTabs[i];
          final isSelected = tabSelected == tab['periodo'];
          return GestureDetector(
            onTap: isSelected ? null : () => _changeMonth(tab['periodo'], tab['mes'], tab['ano']),
            child: Center(
              child: Text(
                tab['periodo'],
                style: AppTypography.bodyMedium(context).copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary(context),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  decoration: isSelected ? TextDecoration.underline : null,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlocoTile extends StatelessWidget {
  final dynamic bloco;
  final int paid;
  final int pending;
  final void Function(dynamic apto) onApto;

  const _BlocoTile({required this.bloco, required this.paid, required this.pending, required this.onApto});

  @override
  Widget build(BuildContext context) {
    final aptos = bloco['aptos'] as List<dynamic>;
    final total = bloco['total'].toString().replaceAll('R\$', Singleton.instance.getCurrentMoeda());

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          childrenPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${getText('lb_bloco')} ${bloco['bloco']}',
                  style: AppTypography.bodyMedium(context),
                ),
              ),
              _StatusBadge(icon: PhosphorIcons.checkCircle, color: Colors.green, count: paid),
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(icon: PhosphorIcons.warningCircle, color: Colors.orange, count: pending),
              const SizedBox(width: AppSpacing.md),
              Text(total, style: AppTypography.caption(context).copyWith(color: AppColors.textSecondary(context))),
            ],
          ),
          children: [
            const Divider(height: 1),
            for (var apto in aptos)
              _AptoRow(apto: apto, onTap: () => onApto(apto)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  const _StatusBadge({required this.icon, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 2),
        Text(count.toString(), style: AppTypography.caption(context)),
      ],
    );
  }
}

class _AptoRow extends StatelessWidget {
  final dynamic apto;
  final VoidCallback onTap;
  const _AptoRow({required this.apto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPaid = apto['pago'] == 1;
    final valor = apto['valorReal'].toString().replaceAll('R\$', Singleton.instance.getCurrentMoeda());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 4, height: 36,
              decoration: BoxDecoration(
                color: isPaid ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isPaid ? PhosphorIcons.checkCircle : PhosphorIcons.warningCircle,
              color: isPaid ? Colors.green : Colors.orange,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${getText('lb_apartamento')} ${apto['apto']}',
                style: AppTypography.bodyMedium(context),
              ),
            ),
            Text(valor, style: AppTypography.caption(context).copyWith(color: AppColors.textSecondary(context))),
            const SizedBox(width: AppSpacing.sm),
            Icon(PhosphorIcons.caretRight, size: 16, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }
}
