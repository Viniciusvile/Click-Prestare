import 'package:click/controllers/controller_generic.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_input.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewPrestador extends StatefulWidget {
  const NewPrestador({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewPrestadorPageState createState() => _NewPrestadorPageState();
}

class _NewPrestadorPageState extends State<NewPrestador> {
  var _isLoading = false;
  var _isSaving = false;
  final txtNome = TextEditingController();
  final txtTelefone = TextEditingController();
  final txtOutrasCategorias = TextEditingController();
  var categorias = [];
  late final List<Map<String, String>> opcoesCategorias = [
    {"display": getText('prestador_eletricista'), "value": "Eletricista"},
    {"display": getText('prestador_hidraulica'), "value": "Hidraulica"},
    {"display": getText('prestador_pintor'), "value": "Pintor"},
    {"display": getText('prestador_pedreiro'), "value": "Pedreiro"},
    {"display": getText('prestador_limpeza'), "value": "Limpeza"},
    {"display": getText('prestador_dedetizacao'), "value": "Dedetizacao"},
  ];

  @override
  void dispose() {
    txtNome.dispose(); txtTelefone.dispose(); txtOutrasCategorias.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      load();
    } else {
      categorias = [];
    }
  }

  Future<void> load() async {
    try {
      setState(() => _isLoading = true);
      var obj = await apiGetDetails("prestadores", widget.myId!);
      txtNome.text = obj["nome"] ?? '';
      txtTelefone.text = obj["telefone"] ?? '';
      categorias = obj["categorias"].split(",");
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
      if (txtOutrasCategorias.text.isNotEmpty) categorias.add(txtOutrasCategorias.text);
      List<String> categsToAdd = List<String>.from(categorias)..remove('');
      var obj = PrestadorModel(id: widget.myId ?? -1, nome: txtNome.text, telefone: txtTelefone.text, categorias: categsToAdd);
      var res = await apiSaveObject("prestadores", "prestador", obj, widget.isEdit);
      if (res.toString().isEmpty) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        if (mounted) displayMessage(context, getText('alert_error'), res.toString());
      }
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
      var res = await apiDeleteObject('prestadores', widget.myId!);
      if (mounted) setState(() => _isSaving = false);
      if (res) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEdit ? getText('prestador_nav_edit') : getText('prestador_nav_new'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(getText('prestador_infos')),
                  AppInput(label: getText('user_nome_completo'), controller: txtNome, prefixIcon: PhosphorIcons.user, textCapitalization: TextCapitalization.words),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(label: getText('telefone'), controller: txtTelefone, prefixIcon: PhosphorIcons.phone, keyboard: TextInputType.phone),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('prestador_funcoes')),
                  Text(getText('prestador_selecione_categoria'),
                      style: AppTypography.caption(context).copyWith(color: AppColors.textSecondary(context))),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var cat in opcoesCategorias)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (categorias.contains(cat["display"])) {
                                categorias.remove(cat["display"]);
                              } else {
                                categorias.add(cat["display"]);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: categorias.contains(cat["display"]) ? AppColors.primary : AppColors.surface(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: categorias.contains(cat["display"]) ? AppColors.primary : AppColors.border(context),
                              ),
                            ),
                            child: Text(cat["display"]!,
                                style: AppTypography.captionMedium(context).copyWith(
                                    color: categorias.contains(cat["display"]) ? Colors.white : AppColors.textSecondary(context))),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(label: getText('prestador_categoria_desc'), controller: txtOutrasCategorias, prefixIcon: PhosphorIcons.plusCircle),
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

class PrestadorModel {
  int? id;
  String? nome, telefone;
  List<String>? categorias;

  PrestadorModel({this.id, this.nome, this.telefone, this.categorias});

  Map toJson() => {'id': id, 'nome': nome, 'telefone': telefone, 'categorias': categorias};
}
