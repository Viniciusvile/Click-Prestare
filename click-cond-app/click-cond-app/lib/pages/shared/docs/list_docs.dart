import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/docs/list_atas.dart';
import 'package:click/pages/shared/docs/new_document.dart';
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

class ListDocs extends StatefulWidget {
  const ListDocs({Key? key}) : super(key: key);
  @override
  _ListDocsPageState createState() => _ListDocsPageState();
}

class _ListDocsPageState extends State<ListDocs> {
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
      list = await apiGetAllDocs("documentos", 0);
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> delete(int index) async {
    final choice = await showConfirmDialog(context);
    if (choice != true) return;
    setState(() => _isLoading = true);
    final res = await apiDeleteObject('documentos', index);
    if (mounted) setState(() => _isLoading = false);
    if (res) {
      loadList();
    } else {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSindico = getUserType() == 'sindico';
    return AppScaffold(
      title: getText('docs_nav'),
      floatingActionButton: isSindico
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NewDocument(is_ata: false)))
                  .then((_) => loadList()),
              backgroundColor: AppColors.primary,
              child: const Icon(PhosphorIcons.plus, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, __) => AppSkeleton.listTile(context),
            )
          : RefreshIndicator(
              onRefresh: loadList,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (list.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Column(children: [
                          Icon(PhosphorIcons.folder, size: 56, color: AppColors.textTertiary(context)),
                          const SizedBox(height: AppSpacing.md),
                          Text(getText('alert_list_empty_generic'), style: AppTypography.caption(context)),
                        ]),
                      ),
                    ),
                  for (var item in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _DocCard(
                        item: item,
                        onTap: () => launchInBrowser(item['link_doc'], context),
                        onDelete: isSindico ? () => delete(item['id']) : null,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _DocCard(
                      item: {'nome': 'ATAS'},
                      showArrow: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListAtas())),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showArrow;
  const _DocCard({required this.item, this.onTap, this.onDelete, this.showArrow = false});

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
              child: const Icon(PhosphorIcons.filePdf, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(item['nome'] ?? '', style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (onDelete != null)
              IconButton(
                icon: Icon(PhosphorIcons.trash, size: 18, color: AppColors.error),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            if (showArrow || onDelete == null)
              Icon(PhosphorIcons.caretRight, size: 16, color: AppColors.textTertiary(context)),
          ],
        ),
      ),
    );
  }
}
