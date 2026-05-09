import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/prestador%20de%20servico/new_prestador.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListPrestadores extends StatefulWidget {
  const ListPrestadores({Key? key}) : super(key: key);
  @override
  _ListPrestadoresPageState createState() => _ListPrestadoresPageState();
}

class _ListPrestadoresPageState extends State<ListPrestadores> {
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
      list = await apiGetAll("prestadores");
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = getUserType() == 'sindico' || getUserPermission('prestadores_servico') == 1;
    return AppScaffold(
      title: getText('lb_prestadores_servico'),
      floatingActionButton: canAdd
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NewPrestador(isEdit: false)))
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
                    Icon(PhosphorIcons.briefcase, size: 56, color: AppColors.textTertiary(context)),
                    const SizedBox(height: AppSpacing.md),
                    Text(getText('alert_list_empty_generic'), style: AppTypography.caption(context), textAlign: TextAlign.center, maxLines: 2),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: loadList,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _PrestadorCard(
                      item: list[i],
                      onTap: canAdd
                          ? () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => NewPrestador(isEdit: true, myId: list[i]['id'])))
                              .then((_) => loadList())
                          : null,
                    ),
                  ),
                ),
    );
  }
}

class _PrestadorCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  const _PrestadorCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface(context), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: (item['photo'] != null && item['photo'].toString().isNotEmpty)
                  ? NetworkImage(item['photo']) as ImageProvider
                  : null,
              child: (item['photo'] == null || item['photo'].toString().isEmpty)
                  ? Text(
                      (item['nome'] ?? 'P').substring(0, 1).toUpperCase(),
                      style: AppTypography.bodyMedium(context).copyWith(color: AppColors.primary),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['nome'] ?? '', style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (item['servico'] != null)
                    Text(item['servico'], style: AppTypography.caption(context)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(PhosphorIcons.caretRight, size: 16, color: AppColors.textTertiary(context)),
          ],
        ),
      ),
    );
  }
}
