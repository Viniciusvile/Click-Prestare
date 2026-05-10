import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:click/controllers/controller_generic.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/buttons/upload_button.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_input.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewManutencao extends StatefulWidget {
  const NewManutencao({Key? key, required this.isEdit, this.myId}) : super(key: key);
  final bool isEdit;
  final int? myId;

  @override
  _NewManutencaoPageState createState() => _NewManutencaoPageState();
}

class _NewManutencaoPageState extends State<NewManutencao> {
  List<dynamic> list = [];
  var _isLoading = false;
  var _isSaving = false;
  final txtDescricao = TextEditingController();

  @override
  void dispose() {
    txtDescricao.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) load();
  }

  Future<void> load() async {
    try {
      setState(() => _isLoading = true);
      var obj = await apiGetDetails("manutencoes", widget.myId!);
      txtDescricao.text = obj["descricao"] ?? '';
      for (var item in obj['anexos'].split(';')) {
        if (item.isNotEmpty) list.add(await fileFromImageUrl(item));
      }
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
      List<String> base64 = [];
      for (var item in list) {
        base64.add(convertToBase64(item, 'image/png'));
      }
      var doc = ManutencaoModel(id: widget.myId ?? -1, descricao: txtDescricao.text, docs: base64);
      var message = await apiSaveObject('manutencoes', 'manutencao', doc, widget.isEdit);
      if (message == '') {
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) displayMessage(context, getText('alert_error'), message);
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
      var res = await apiDeleteObject('manutencoes', widget.myId!);
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
      title: widget.isEdit ? getText('manut_edit') : getText('manut_new'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(getText('lb_anexos')),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: uploadFile(
                      title: getText('lb_insira_fotos'),
                      types: ['jpg', 'png'],
                      maxDocs: 3,
                      defaults: list,
                      onPressed: (listFiles) {
                        list = listFiles;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('lb_descricao')),
                  AppInput(label: getText('lb_descricao'), controller: txtDescricao, prefixIcon: PhosphorIcons.notepad, maxLines: 4),
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

class ManutencaoModel {
  int? id;
  String? descricao;
  List<String>? docs;

  ManutencaoModel({this.id, this.descricao, this.docs});

  Map toJson() => {'id': id, 'descricao': descricao, 'docs': docs};
}
