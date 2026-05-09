import 'package:click/controllers/controller_enquetes.dart';
import 'package:click/controllers/controller_generic.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:click/widgets/cells/cell_votacao.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DetailEnquete extends StatefulWidget {
  const DetailEnquete({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _DetailEnquetePageState createState() => _DetailEnquetePageState();
}

class _DetailEnquetePageState extends State<DetailEnquete> {
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
      obj = await apiGetDetails('assembleias/votacoes/enquetes', widget.id);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> finish() async {
    try {
      var choice = await showConfirmDialog(context, text: getText('votacao_confirm_delete'));
      if (choice != null && choice) {
        setState(() => _isLoading = true);
        await apiFinishEnquete(widget.id.toString());
        load();
      }
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> insertVoto(int opcao_id, int votacao_id) async {
    try {
      setState(() => _isLoading = true);
      var voto = VotoModel(opcao_id: opcao_id, votacao_id: votacao_id);
      var res = await apiSaveObject("assembleias/votacoes/voto", "voto", voto, false);
      if (res.toString().isEmpty) {
        load();
      } else {
        if (mounted) displayMessage(context, getText('alert_error'), res.toString());
      }
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(int status) {
    if (status == 1) return AppColors.primary;
    if (status == 2) return Colors.red;
    return AppColors.textSecondary(context);
  }

  String _statusLabel(int status) {
    if (status == 0) return getText('votacao_agendado');
    if (status == 1) return getText('votacao_andamento');
    if (status == 2) return getText('votacao_finalizado');
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('votacao_enquete'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : obj == null
              ? const SizedBox()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(getText('votacao_infos')),
                      _StatusChip(
                        label: _statusLabel(obj['votacao']['status'] as int),
                        color: _statusColor(obj['votacao']['status'] as int),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(obj['votacao']['titulo'],
                          style: AppTypography.title(context)),
                      const SizedBox(height: AppSpacing.sm),
                      if ((obj['votacao']['descricao'] ?? '').toString().isNotEmpty)
                        Text(obj['votacao']['descricao'],
                            style: AppTypography.body(context).copyWith(color: AppColors.textSecondary(context))),
                      const SizedBox(height: AppSpacing.xl),
                      _section(getText('escolha_opcao_desejada')),
                      CellVotacao(
                        item: obj['votacao'],
                        title: getText('escolha_opcao_desejada'),
                        hasArrow: true,
                        isRegister: false,
                        meusVotos: obj['meuVoto'],
                        onPressedDelete: () {},
                        onPressedChoice: (id) => insertVoto(id, obj['votacao']['id']),
                      ),
                      if (getUserType() == 'sindico' && obj['votacao']['status'] == 1) ...[
                        const SizedBox(height: AppSpacing.xl),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: finish,
                            icon: const Icon(PhosphorIcons.flagCheckered, size: 16),
                            label: Text(getText('votacao_finalizar'),
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ),
                      ],
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

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: AppTypography.caption(context).copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class VotoModel {
  int? votacao_id;
  int? opcao_id;

  VotoModel({this.votacao_id, this.opcao_id});

  Map toJson() => {'votacao_id': votacao_id, 'opcao_id': opcao_id};
}
