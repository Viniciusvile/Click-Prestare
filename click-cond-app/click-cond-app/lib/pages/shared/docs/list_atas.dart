import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/docs/new_document.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListAtas extends StatefulWidget {
  const ListAtas({Key? key}) : super(key: key);
  @override
  _ListAtasPageState createState() => _ListAtasPageState();
}

class _ListAtasPageState extends State<ListAtas> {
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
      list = await apiGetAllDocs("documentos", 1);
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
    if (res) { loadList(); } else {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSindico = getUserType() == 'sindico';
    return AppScaffold(
      title: getText('docs_nav_atas'),
      floatingActionButton: isSindico
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NewDocument(is_ata: true)))
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
                    Icon(PhosphorIcons.fileText, size: 56, color: AppColors.textTertiary(context)),
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
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => launchInBrowser(list[i]['link_doc'], context),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: AppColors.surface(context), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(PhosphorIcons.fileText, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: Text(list[i]['nome'] ?? '', style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            if (isSindico)
                              IconButton(
                                icon: Icon(PhosphorIcons.trash, size: 18, color: AppColors.error),
                                onPressed: () => delete(list[i]['id']),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
