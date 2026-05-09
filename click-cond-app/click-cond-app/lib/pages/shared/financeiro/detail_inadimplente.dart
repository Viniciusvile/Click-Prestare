import 'package:click/controllers/controller_financeiro.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DetailInadimplente extends StatefulWidget {
  const DetailInadimplente({Key? key, required this.bloco, required this.apto}) : super(key: key);
  final String bloco;
  final String apto;

  @override
  _DetailInadimplentePageState createState() => _DetailInadimplentePageState();
}

class _DetailInadimplentePageState extends State<DetailInadimplente> {
  List<dynamic> list = [];
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      setState(() => _isLoading = true);
      var locals = await apiGetDetailsInadimplente('financeiro/inadimplente', widget.bloco, widget.apto);
      list = locals;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('financeiro_inadimplente'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '${getText('lb_bloco')} ${widget.bloco} · ${getText('lb_apartamento')} ${widget.apto}',
                      style: AppTypography.title(context).copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('financeiro_meses_aberto')),
                  if (list.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Text(
                          getText('alert_list_empty_generic'),
                          style: AppTypography.body(context).copyWith(color: AppColors.textSecondary(context)),
                        ),
                      ),
                    )
                  else
                    for (var item in list) _MonthCard(item: item),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(title.toUpperCase(),
            style: AppTypography.captionMedium(context).copyWith(color: AppColors.primary, letterSpacing: 0.8)),
      );
}

class _MonthCard extends StatelessWidget {
  final dynamic item;
  const _MonthCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(PhosphorIcons.calendarX, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '${item['mes']}/${item['ano']}',
              style: AppTypography.bodyMedium(context),
            ),
          ),
        ],
      ),
    );
  }
}
