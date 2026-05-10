import 'package:click/controllers/controller_generic.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:click/widgets/app/app_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'new_apto.dart';

class ListMoradores extends StatefulWidget {
  const ListMoradores({Key? key}) : super(key: key);
  @override
  _ListMoradoresPageState createState() => _ListMoradoresPageState();
}

class _ListMoradoresPageState extends State<ListMoradores> {
  List<dynamic> list = [];
  bool _isLoading = false;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    loadList();
  }

  Future<void> loadList() async {
    try {
      setState(() => _isLoading = true);
      list = await apiGetAll("apartamentos");
      loaded = true;
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = (getUserType() == 'sindico') || getUserPermission('apartamentos') == 1;
    return AppScaffold(
      title: getText('lb_apartamentos'),
      floatingActionButton: canAdd
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NewApto(isEdit: false)))
                  .then((_) => loadList()),
              backgroundColor: AppColors.primary,
              child: const Icon(PhosphorIcons.plus, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, __) => AppSkeleton.listTile(context),
            )
          : loaded && list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.buildings, size: 56, color: AppColors.textTertiary(context)),
                      const SizedBox(height: AppSpacing.md),
                      Text(getText('moradores_empty'), style: AppTypography.caption(context), textAlign: TextAlign.center, maxLines: 3),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadList,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _AptoCard(
                      item: list[i],
                      onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => NewApto(isEdit: true, obj: list[i])))
                          .then((_) => loadList()),
                    ),
                  ),
                ),
    );
  }
}

class _AptoCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  const _AptoCard({required this.item, required this.onTap});

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
              child: const Icon(PhosphorIcons.door, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apto ${item['numero'] ?? ''} - Bloco ${item['bloco'] ?? ''}',
                      style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (item['tipo'] != null)
                    Text(item['tipo'], style: AppTypography.caption(context)),
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
