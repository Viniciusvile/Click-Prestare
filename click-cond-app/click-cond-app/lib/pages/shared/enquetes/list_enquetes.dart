import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/assembleias/new_votacao.dart';
import 'package:click/pages/shared/enquetes/detail_enquete.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListEnquetes extends StatefulWidget {
  const ListEnquetes({Key? key}) : super(key: key);
  @override
  _ListEnquetesPageState createState() => _ListEnquetesPageState();
}

class _ListEnquetesPageState extends State<ListEnquetes> {
  List<dynamic> list = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadList();
  }

  Future<void> loadList() async {
    try {
      setState(() => _isLoading = true);
      list = await apiGetAll("assembleias/votacoes/enquetes");
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSindico = getUserType() == 'sindico';
    return AppScaffold(
      title: getText('lb_votacoes'),
      floatingActionButton: isSindico
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NewVotacao(isEnquete: true)))
                  .then((_) => loadList()),
              backgroundColor: AppColors.primary,
              child: const Icon(PhosphorIcons.plus, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(PhosphorIcons.chartBar, size: 56, color: AppColors.textTertiary(context)),
                    const SizedBox(height: AppSpacing.md),
                    Text(getText('alert_list_empty_generic'), style: AppTypography.caption(context)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: loadList,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _EnqueteCard(
                      item: list[i],
                      onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => DetailEnquete(id: list[i]['id'])))
                          .then((_) => loadList()),
                    ),
                  ),
                ),
    );
  }
}

class _EnqueteCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  const _EnqueteCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface(context), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(PhosphorIcons.chartBar, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['titulo'] ?? item['pergunta'] ?? '', style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (item['status'] != null)
                    _StatusBadge(item['status']),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight, size: 16, color: AppColors.textTertiary(context)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final dynamic status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final isOpen = status?.toString().toLowerCase() == 'aberta' || status?.toString() == '1';
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF22C55E).withOpacity(0.1) : AppColors.textTertiary(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'Aberta' : 'Encerrada',
        style: AppTypography.tiny(context).copyWith(color: isOpen ? const Color(0xFF22C55E) : AppColors.textTertiary(context)),
      ),
    );
  }
}
