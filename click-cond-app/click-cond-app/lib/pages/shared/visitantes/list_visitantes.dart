import 'dart:async';
import 'package:click/controllers/controller_visitantes.dart';
import 'package:click/pages/shared/visitantes/new_visitante.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListVisitantes extends StatefulWidget {
  const ListVisitantes({Key? key}) : super(key: key);
  @override
  _ListVisitantesPageState createState() => _ListVisitantesPageState();
}

class _ListVisitantesPageState extends State<ListVisitantes> {
  final txtSearch = TextEditingController();
  Timer? _timerSearch;
  List<dynamic> list = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadList();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    _timerSearch?.cancel();
    super.dispose();
  }

  Future<void> loadList() async {
    try {
      setState(() => _isLoading = true);
      list = await apiGetAllVisitantes(txtSearch.text);
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = (getUserType() != 'funcionario') || getUserPermission('cadastrar_visitante') == 1;
    return AppScaffold(
      title: getText('visitantes_list'),
      floatingActionButton: canAdd
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NewVisitante(isEdit: false)))
                  .then((_) => loadList()),
              backgroundColor: AppColors.primary,
              child: const Icon(PhosphorIcons.plus, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: TextField(
              controller: txtSearch,
              onChanged: (v) {
                _timerSearch?.cancel();
                _timerSearch = Timer(const Duration(milliseconds: 600), loadList);
              },
              style: AppTypography.body(context),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: getText('lb_buscar'),
                hintStyle: AppTypography.body(context).copyWith(color: AppColors.textTertiary(context)),
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass, size: 20, color: AppColors.textSecondary(context)),
                filled: true,
                fillColor: AppColors.surface(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? _EmptyState(getText('alert_list_empty_generic'), PhosphorIcons.identificationCard)
                    : RefreshIndicator(
                        onRefresh: loadList,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (_, i) => _VisitanteCard(
                            item: list[i],
                            onTap: canAdd
                                ? () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => NewVisitante(isEdit: true, myId: list[i]['id'])))
                                    .then((_) => loadList())
                                : null,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _VisitanteCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  const _VisitanteCard({required this.item, this.onTap});

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
              child: Text(
                (item['nome'] ?? 'V').substring(0, 1).toUpperCase(),
                style: AppTypography.bodyMedium(context).copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['nome'] ?? '', style: AppTypography.bodyMedium(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (item['documento'] != null)
                    Text(item['documento'], style: AppTypography.caption(context)),
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

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState(this.message, this.icon);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textTertiary(context)),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTypography.caption(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
