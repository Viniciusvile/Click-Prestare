import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:click/controllers/controller_generic.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_input.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewMorador extends StatefulWidget {
  const NewMorador({
    Key? key,
    required this.isEdit,
    this.obj,
    required this.apto,
    required this.bloco,
    required this.tipo,
    required this.id_apto,
  }) : super(key: key);
  final bool isEdit;
  final dynamic obj;
  final String apto, bloco, tipo, id_apto;

  @override
  _NewMoradorPageState createState() => _NewMoradorPageState();
}

class _NewMoradorPageState extends State<NewMorador> {
  var _isLoading = false;
  var _isSaving = false;
  final txtNome = TextEditingController();
  final txtDocumento = TextEditingController();
  final txtDN = TextEditingController();
  final txtEmail = TextEditingController();
  final txtTelefone = TextEditingController();
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  final txtExtra1 = TextEditingController();
  final txtExtra2 = TextEditingController();
  final txtExtra3 = TextEditingController();
  final txtExtra4 = TextEditingController();
  dynamic imageFile;
  var imageChanged = false;
  var myId = -1;

  @override
  void dispose() {
    txtNome.dispose(); txtDocumento.dispose(); txtDN.dispose();
    txtEmail.dispose(); txtTelefone.dispose(); txtBloco.dispose();
    txtApto.dispose(); txtExtra1.dispose(); txtExtra2.dispose();
    txtExtra3.dispose(); txtExtra4.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    txtBloco.text = widget.bloco;
    txtApto.text = widget.apto;
    if (widget.isEdit) load();
  }

  Future<void> load() async {
    try {
      setState(() => _isLoading = true);
      txtNome.text = widget.obj["nome"] ?? '';
      txtDocumento.text = widget.obj["documento"] ?? '';
      txtEmail.text = widget.obj["email"] ?? '';
      txtDN.text = convertDateToString(widget.obj["data_nascimento"]);
      txtTelefone.text = widget.obj["telefone"] ?? '';
      txtExtra1.text = widget.obj["extra1"] ?? '';
      txtExtra2.text = widget.obj["extra2"] ?? '';
      txtExtra3.text = widget.obj["extra3"] ?? '';
      txtExtra4.text = widget.obj["extra4"] ?? '';
      myId = widget.obj["id"];
      imageFile = await fileFromImageUrl(widget.obj['photo'] ?? '');
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
      String? base64;
      if (imageFile != null && imageChanged) {
        List<int> imageBytes = [];
        base64 = "data:image/png;base64," + base64Encode(imageBytes);
      }
      var morador = MoradorModel(
        id: myId, nome: txtNome.text, documento: txtDocumento.text,
        email: txtEmail.text, telefone: txtTelefone.text, tipo: widget.tipo,
        data_nascimento: txtDN.text, id_apto: widget.id_apto,
        extra1: txtExtra1.text, extra2: txtExtra2.text,
        extra3: txtExtra3.text, extra4: txtExtra4.text, photo: base64,
      );
      var res = await apiSaveObject("moradores", "morador", morador, widget.isEdit);
      if (res.toString().isEmpty) {
        if (!widget.isEdit) {
          await displayMessage(context, getText('alert_success'), getText('apto_usuario_criado_msg'));
        }
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
      var res = await apiDeleteObject('moradores', widget.obj['id']);
      if (mounted) setState(() => _isSaving = false);
      if (res) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
      }
    }
  }

  Future<void> _selectPhoto() async {
    var res = await getPhoto(context);
    imageFile = res;
    imageChanged = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.tipo,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _selectPhoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: imageFile == null
                                ? const AssetImage('assets/images/defaultUser.png')
                                : (kIsWeb
                                    ? NetworkImage(imageFile!.path)
                                    : const AssetImage('assets/images/defaultUser.png')) as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.bg(context), width: 2),
                              ),
                              child: const Icon(PhosphorIcons.camera, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('lb_infos_apto')),
                  Row(
                    children: [
                      Expanded(child: AppInput(label: getText('lb_bloco'), controller: txtBloco, readOnly: true, prefixIcon: PhosphorIcons.buildings)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: AppInput(label: getText('lb_apartamento'), controller: txtApto, readOnly: true, prefixIcon: PhosphorIcons.door)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('funcionario_infos_pessoais')),
                  AppInput(label: getText('user_nome_completo'), controller: txtNome, prefixIcon: PhosphorIcons.user, textCapitalization: TextCapitalization.words),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(label: getText('user_documento'), controller: txtDocumento, prefixIcon: PhosphorIcons.identificationCard,
                      formatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))]),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: getText('data_nascimento'),
                    controller: txtDN,
                    prefixIcon: PhosphorIcons.calendarBlank,
                    readOnly: true,
                    onTap: () => showCupertinoModalPopup(
                      context: context,
                      builder: (_) => ModalCupertino(
                        onPressed: (text) => setState(() => txtDN.text = text),
                        initialDate: null,
                        type: 'date',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('signup_infos_contato')),
                  AppInput(label: getText('email'), controller: txtEmail, prefixIcon: PhosphorIcons.envelope, keyboard: TextInputType.emailAddress),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(label: getText('telefone'), controller: txtTelefone, prefixIcon: PhosphorIcons.phone, keyboard: TextInputType.phone),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('funcionario_infos_extra')),
                  AppInput(label: getText('funcionario_infos_extra_1'), controller: txtExtra1, maxLines: 2),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(label: getText('funcionario_infos_extra_2'), controller: txtExtra2, maxLines: 2),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(label: getText('funcionario_infos_extra_3'), controller: txtExtra3, maxLines: 2),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(label: getText('funcionario_infos_extra_4'), controller: txtExtra4, maxLines: 2),
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

class MoradorModel {
  int? id;
  String? nome, documento, data_nascimento, email, telefone, tipo, id_apto;
  String? extra1, extra2, extra3, extra4, photo;

  MoradorModel({this.id, this.nome, this.documento, this.data_nascimento,
      this.email, this.telefone, this.tipo, this.id_apto,
      this.extra1, this.extra2, this.extra3, this.extra4, this.photo});

  Map toJson() => {
        'id': id, 'nome': nome, 'email': email, 'data_nascimento': data_nascimento,
        'documento': documento, 'telefone': telefone, 'tipo': tipo, 'id_apto': id_apto,
        'extra1': extra1, 'extra2': extra2, 'extra3': extra3, 'extra4': extra4, 'photo': photo,
      };
}
