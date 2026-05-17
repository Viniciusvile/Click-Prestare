import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/areas%20sociais/new_reserva.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:click/widgets/cells/cell_morador_agendamento.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'new_area_social.dart';

class AreaSocialDetail extends StatefulWidget {
  const AreaSocialDetail({Key? key, this.myId}) : super(key: key);
  final int? myId;

  @override
  _AreaSocialDetailPageState createState() => _AreaSocialDetailPageState();
}

class _AreaSocialDetailPageState extends State<AreaSocialDetail> {
  var _isLoading = false;
  dynamic obj;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      setState(() => _isLoading = true);
      obj = await apiGetDetails('areas-sociais', widget.myId!);
      if (obj == null && mounted) {
        displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _canEditAgendamento(dynamic item) {
    return getUserType() == 'sindico' ||
        getUserPermission('areas_sociais') == 1 ||
        (getUserType() == 'morador' &&
            Singleton.instance.bloco.toString() == item['bloco'] &&
            Singleton.instance.apartamento.toString() == item['apto']);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('lb_area_social'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : obj == null
              ? const SizedBox()
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((obj['imagem'] ?? '').toString().isNotEmpty)
                            Image.network(
                              obj['imagem'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(obj['nome'],
                                    style: AppTypography.title(context)),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Icon(PhosphorIcons.usersThree, size: 16, color: AppColors.textSecondary(context)),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      obj['capacidade'].toString() != '-1'
                                          ? '${obj['capacidade']} ${getText('pessoas')}'
                                          : getText('capacidade_indeterminada'),
                                      style: AppTypography.body(context).copyWith(color: AppColors.textSecondary(context)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  children: [
                                    if (obj['precisa_agendar'] == 1) _Tag(label: getText('area_social_precisa_agendamento')),
                                    if (obj['precisa_autorizacao'] == 1) _Tag(label: getText('area_social_precisa_autorizacao')),
                                    if (obj['precisa_pagamento'] == 1) _Tag(label: getText('area_social_precisa_pagamento')),
                                  ],
                                ),
                                if (obj['precisa_agendar'] == 1) ...[
                                  const SizedBox(height: AppSpacing.xl),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(getText('area_social_agendamentos').toUpperCase(),
                                          style: AppTypography.captionMedium(context).copyWith(color: AppColors.primary, letterSpacing: 0.8)),
                                      if (getUserType() != 'funcionario')
                                        TextButton.icon(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => NewReserva(obj: obj)),
                                          ).then((_) => load()),
                                          icon: const Icon(PhosphorIcons.plus, size: 16),
                                          label: Text(getText('nova_reserva')),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  if (obj['agendamentos'].isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                      child: Center(
                                        child: Text(
                                          getText('alert_list_empty_generic'),
                                          style: AppTypography.bodySecondary(context),
                                        ),
                                      ),
                                    ),
                                  for (var item in obj['agendamentos'])
                                    GestureDetector(
                                      onTap: () {
                                        if (_canEditAgendamento(item)) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => NewReserva(obj: obj, objEditReserva: item)),
                                          ).then((_) => load());
                                        }
                                      },
                                      child: CellMoradorAgendamento(item: item, canEdit: _canEditAgendamento(item)),
                                    ),
                                ],
                                const SizedBox(height: AppSpacing.xxxl),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: (getUserType() == 'sindico' || getUserPermission('areas_sociais') == 1)
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NewAreaSocial(isEdit: true, obj: obj, myId: obj['id'])),
              ).then((_) => load()),
              backgroundColor: AppColors.primary,
              child: const Icon(PhosphorIcons.pencil, color: Colors.white),
            )
          : null,
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTypography.caption(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
    );
  }
}
