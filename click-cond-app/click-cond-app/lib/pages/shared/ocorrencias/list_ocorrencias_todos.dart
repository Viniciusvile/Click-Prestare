import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/ocorrencias/detail_ocorrencia.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListOcorrenciasTodos extends StatefulWidget {
  const ListOcorrenciasTodos({Key? key}) : super(key: key);
  @override
  _ListOcorrenciasTodosPageState createState() => _ListOcorrenciasTodosPageState();
}

class _ListOcorrenciasTodosPageState extends State<ListOcorrenciasTodos> {
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
      list = await apiGetAll("ocorrencias/todos");
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => AppSkeleton.listTile(context),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(PhosphorIcons.warning, size: 48, color: AppColors.textTertiary(context)),
          const SizedBox(height: AppSpacing.md),
          Text(getText('alert_list_empty_generic'), style: AppTypography.caption(context)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: loadList,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _OcorrenciaCard(
          item: list[i],
          onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => DetailOcorrencia(id: list[i]['id'])))
              .then((_) => loadList()),
        ),
      ),
    );
  }
}

class _OcorrenciaCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  const _OcorrenciaCard({required this.item, required this.onTap});

  Color _statusColor(dynamic status) {
    final s = status?.toString() ?? '';
    if (s == '1' || s.toLowerCase() == 'resolvida') return const Color(0xFF22C55E);
    return const Color(0xFFF59E0B);
  }

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
              decoration: BoxDecoration(
                color: _statusColor(item['status']).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(PhosphorIcons.warning, color: _statusColor(item['status']), size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['tipo'] ?? item['descricao'] ?? '', style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (item['descricao'] != null)
                    Text(item['descricao'], style: AppTypography.caption(context), maxLines: 1, overflow: TextOverflow.ellipsis),
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
