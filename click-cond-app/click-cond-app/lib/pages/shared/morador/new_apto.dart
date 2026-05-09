import 'package:click/controllers/controller_generic.dart';
import 'package:click/controllers/controller_moradores.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_input.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:click/widgets/cells/cell_morador_apto.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'new_morador.dart';

class NewApto extends StatefulWidget {
  const NewApto({Key? key, required this.isEdit, this.obj}) : super(key: key);
  final bool isEdit;
  final dynamic obj;

  @override
  _NewAptoPageState createState() => _NewAptoPageState();
}

class _NewAptoPageState extends State<NewApto> {
  var isEdit = false;
  var _isLoading = false;
  var _isSaving = false;
  var idObj = -1;
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  final txtFracao = TextEditingController();
  List<dynamic> listProprietarios = [];
  List<dynamic> listInquilinos = [];

  @override
  void dispose() {
    txtBloco.dispose(); txtApto.dispose(); txtFracao.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      isEdit = widget.isEdit;
      idObj = widget.obj['id'];
      load();
    }
  }

  Future<void> load() async {
    txtApto.text = widget.obj['apto'];
    txtBloco.text = widget.obj['bloco'];
    txtFracao.text = widget.obj['fracao'] ?? '';
    await loadMoradores();
  }

  Future<void> loadMoradores() async {
    try {
      setState(() => _isLoading = true);
      var resProps = await apiGetAllMoradores('Proprietário', idObj.toString());
      var resInqui = await apiGetAllMoradores('Inquilino', idObj.toString());
      listProprietarios = resProps;
      listInquilinos = resInqui;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> save() async {
    try {
      setState(() => _isSaving = true);
      var obj = AptoModel(id: idObj, bloco: txtBloco.text, apto: txtApto.text, fracao: txtFracao.text);
      var res = await apiSaveApto('apartamentos', getText('lb_apartamento'), obj, isEdit);
      await displayMessage(context, getText('alert_success'), 'Apartamento salvo com sucesso!');
      idObj = res['id'];
      isEdit = true;
      await loadMoradores();
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> delete() async {
    var choice = await showConfirmDialog(context);
    if (choice != null && choice) {
      setState(() => _isSaving = true);
      var res = await apiDeleteObject('apartamentos', idObj);
      if (mounted) setState(() => _isSaving = false);
      if (res) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  bool get canEdit => getUserType() == 'sindico' || getUserPermission('apartamentos') == 1;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('lb_apartamento'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isEdit) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.info, color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(getText('apto_desc'), style: AppTypography.body(context).copyWith(color: AppColors.primary))),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  _section(getText('lb_infos_apto')),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          label: getText('lb_bloco'),
                          controller: txtBloco,
                          prefixIcon: PhosphorIcons.buildings,
                          readOnly: !canEdit,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppInput(
                          label: getText('lb_apartamento'),
                          controller: txtApto,
                          prefixIcon: PhosphorIcons.door,
                          readOnly: !canEdit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: getText('apto_fracao'),
                    controller: txtFracao,
                    prefixIcon: PhosphorIcons.percent,
                    readOnly: !canEdit,
                    keyboard: TextInputType.number,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _MoradorSection(
                      title: '${getText('apto_proprietarios')} (${listProprietarios.length})',
                      canEdit: canEdit,
                      list: listProprietarios,
                      onAdd: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewMorador(
                          isEdit: false, apto: txtApto.text, bloco: txtBloco.text,
                          tipo: 'Proprietário', id_apto: idObj.toString(),
                        )),
                      ).then((_) => loadMoradores()),
                      onTap: (item) {
                        if (canEdit) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NewMorador(
                              obj: item, isEdit: true, apto: txtApto.text, bloco: txtBloco.text,
                              tipo: 'Proprietário', id_apto: idObj.toString(),
                            )),
                          ).then((_) => loadMoradores());
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _MoradorSection(
                      title: '${getText('apto_inquilinos')} (${listInquilinos.length})',
                      canEdit: canEdit,
                      list: listInquilinos,
                      onAdd: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewMorador(
                          isEdit: false, apto: txtApto.text, bloco: txtBloco.text,
                          tipo: 'Inquilino', id_apto: idObj.toString(),
                        )),
                      ).then((_) => loadMoradores()),
                      onTap: (item) {
                        if (canEdit) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NewMorador(
                              obj: item, isEdit: true, apto: txtApto.text, bloco: txtBloco.text,
                              tipo: 'Inquilino', id_apto: idObj.toString(),
                            )),
                          ).then((_) => loadMoradores());
                        }
                      },
                    ),
                  ],
                  if (canEdit) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: getText('btn_save'),
                      onPressed: _isSaving ? null : save,
                      loading: _isSaving,
                      icon: PhosphorIcons.floppyDisk,
                    ),
                    if (widget.isEdit) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: getText('btn_delete'),
                        onPressed: _isSaving ? null : delete,
                        variant: AppButtonVariant.danger,
                        icon: PhosphorIcons.trash,
                      ),
                    ],
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

class _MoradorSection extends StatelessWidget {
  final String title;
  final bool canEdit;
  final List<dynamic> list;
  final VoidCallback onAdd;
  final void Function(dynamic item) onTap;

  const _MoradorSection({required this.title, required this.canEdit, required this.list, required this.onAdd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.toUpperCase(),
                style: AppTypography.captionMedium(context).copyWith(color: AppColors.primary, letterSpacing: 0.8)),
            if (canEdit)
              IconButton(
                onPressed: onAdd,
                icon: Icon(PhosphorIcons.plusCircle, color: AppColors.primary, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var item in list)
          GestureDetector(
            onTap: () => onTap(item),
            child: CellMoradorApto(item: item),
          ),
      ],
    );
  }
}

class AptoModel {
  int? id;
  String? bloco;
  String? apto;
  String? fracao;

  AptoModel({this.id, this.bloco, this.apto, this.fracao});

  Map toJson() => {'id': id, 'bloco': bloco, 'apto': apto, 'fracao': fracao};
}
