import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/financeiro/detail_inadimplente.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListInadimplestes extends StatefulWidget {
  const ListInadimplestes({Key? key}) : super(key: key);
  @override
  _ListInadimplestesPageState createState() => _ListInadimplestesPageState();
}

class _ListInadimplestesPageState extends State<ListInadimplestes> {
  List<dynamic> blocos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadList();
  }

  Future<void> loadList() async {
    try {
      setState(() => _isLoading = true);
      final list = await apiGetAll("financeiro/inadimplentes");
      blocos = list['blocos'];
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('financeiro_inadimplentes'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : blocos.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(PhosphorIcons.checkCircle, size: 56, color: const Color(0xFF22C55E)),
                    const SizedBox(height: AppSpacing.md),
                    Text(getText('financeiro_nenhum_inadimplente'), style: AppTypography.caption(context), textAlign: TextAlign.center),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: loadList,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      for (final bloco in blocos)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.error.withOpacity(0.2)),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                title: Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Icon(PhosphorIcons.buildings, color: AppColors.error, size: 18),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text('${getText('lb_bloco')} ${bloco['bloco']}', style: AppTypography.bodyMedium(context)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                                      child: Text('${bloco['aptos'].length}', style: AppTypography.tiny(context).copyWith(color: Colors.white)),
                                    ),
                                  ],
                                ),
                                children: [
                                  for (final apto in bloco['aptos'])
                                    InkWell(
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(builder: (_) => DetailInadimplente(apto: apto['apto'], bloco: apto['bloco']))),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                                        child: Row(
                                          children: [
                                            Icon(PhosphorIcons.door, size: 16, color: AppColors.textSecondary(context)),
                                            const SizedBox(width: 8),
                                            Text('Apto ${apto['apto']}', style: AppTypography.body(context)),
                                            const Spacer(),
                                            Text(apto['total']?.toString() ?? '', style: AppTypography.captionMedium(context).copyWith(color: AppColors.error)),
                                            const SizedBox(width: 8),
                                            Icon(PhosphorIcons.caretRight, size: 14, color: AppColors.textTertiary(context)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
