import 'package:click/controllers/controller_generic.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/bottom_sheet_conta.dart';
import 'package:click/widgets/alerts/modal_cupertino.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_input.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewFinanceiroMorador extends StatefulWidget {
  const NewFinanceiroMorador({Key? key, required this.apto, this.id}) : super(key: key);
  final dynamic apto;
  final int? id;

  @override
  _NewFinanceiroMoradorPageState createState() => _NewFinanceiroMoradorPageState();
}

class _NewFinanceiroMoradorPageState extends State<NewFinanceiroMorador> {
  var id = -1;
  var _isLoading = false;
  var _isSaving = false;
  final txtBloco = TextEditingController();
  final txtApto = TextEditingController();
  final txtReferencia = TextEditingController();
  final txtVencimento = TextEditingController();
  final txtPagamento = TextEditingController();
  final txtValor = TextEditingController();
  final txtConta = TextEditingController();
  final txtDescricao = TextEditingController();

  @override
  void dispose() {
    txtBloco.dispose(); txtApto.dispose(); txtReferencia.dispose();
    txtVencimento.dispose(); txtPagamento.dispose();
    txtValor.dispose(); txtConta.dispose(); txtDescricao.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.apto != null) {
      var pago = widget.apto["pago"] ?? 1;
      id = widget.apto["financeiro_id"] ?? -1;
      txtBloco.text = widget.apto['bloco'] ?? '';
      txtApto.text = widget.apto['apto'] ?? '';
      txtReferencia.text = "${widget.apto['mes']}/${widget.apto['ano']}";
      txtVencimento.text = widget.apto['data_vencimento'] ?? '';
      txtPagamento.text = pago == 1 ? widget.apto['data'] ?? '' : '';
      txtValor.text = widget.apto['valor'].toString();
      txtDescricao.text = widget.apto['descricao'] ?? '';
      txtConta.text = widget.apto['conta'] ?? '';
    } else if (widget.id != null) {
      load();
    }
  }

  Future<void> load() async {
    try {
      setState(() => _isLoading = true);
      var obj = await apiGetDetails('financeiro', widget.id!);
      var nome = obj['nome'].toString().split("-")[0];
      var apto = nome.split(getText('lb_bloco'))[0].split('Apto')[1].trim();
      var pago = obj["pago"] ?? 1;
      txtBloco.text = nome.toString().split('Bloco')[1].trim();
      txtApto.text = apto;
      txtReferencia.text = obj['nome'].toString().split("Ref.")[1].trim();
      txtVencimento.text = obj['data_vencimento'] ?? '';
      txtPagamento.text = pago == 1 ? obj['data'] ?? '' : '';
      txtValor.text = obj['valor'].toString();
      txtDescricao.text = obj['descricao']?.toString() ?? '';
      txtConta.text = obj['conta']?.toString() ?? '';
      id = obj['id'];
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
      var dtPag = txtPagamento.text.isNotEmpty ? convertStringToDate(txtPagamento.text) : null;
      var obj = FinanceiroModel(
        id: id,
        nome: "Apto ${txtApto.text} Bloco ${txtBloco.text} - Ref. ${txtReferencia.text}",
        tipo: 'C', categoria: 'Arrecadação',
        data: dtPag,
        data_vencimento: convertStringToDate(txtVencimento.text),
        conta: txtConta.text, descricao: txtDescricao.text,
        valor: double.parse(txtValor.text.replaceAll(',', '.')),
      );
      var res = await apiSaveObject("financeiro", "financeiro", obj, id != -1);
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
      var res = await apiDeleteObject('financeiro', id);
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
      title: getText('financeiro_lancamento'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(getText('lb_infos_apto')),
                  Row(
                    children: [
                      Expanded(child: AppInput(label: getText('lb_bloco'), controller: txtBloco, readOnly: true, prefixIcon: PhosphorIcons.buildings)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: AppInput(label: getText('lb_apartamento'), controller: txtApto, readOnly: true, prefixIcon: PhosphorIcons.door)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('datas')),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          label: getText('financeiro_mes_referencia'),
                          controller: txtReferencia,
                          prefixIcon: PhosphorIcons.calendarBlank,
                          keyboard: TextInputType.number,
                          formatters: [TextInputMask(mask: ['99/9999'], reverse: false)],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppInput(
                          label: getText('financeiro_data_vencimento'),
                          controller: txtVencimento,
                          prefixIcon: PhosphorIcons.calendarX,
                          readOnly: true,
                          onTap: () => showCupertinoModalPopup(
                            context: context,
                            builder: (_) => ModalCupertino(
                              onPressed: (text) => setState(() => txtVencimento.text = text),
                              initialDate: DateTime.now(),
                              minimumDate: DateTime.now().add(const Duration(days: -700)),
                              type: 'date',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: getText('financeiro_dt_pag'),
                    controller: txtPagamento,
                    prefixIcon: PhosphorIcons.calendarCheck,
                    readOnly: true,
                    onTap: () => showCupertinoModalPopup(
                      context: context,
                      builder: (_) => ModalCupertino(
                        onPressed: (text) => setState(() => txtPagamento.text = text),
                        initialDate: DateTime.now(),
                        minimumDate: DateTime.now().add(const Duration(days: -700)),
                        type: 'date',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('financeiro_valores')),
                  AppInput(
                    label: getText('financeiro_valor'),
                    controller: txtValor,
                    prefixIcon: PhosphorIcons.currencyDollar,
                    keyboard: TextInputType.number,
                    formatters: [CurrencyTextInputFormatter.currency(decimalDigits: 2, symbol: '', locale: 'pt_BR')],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: getText('financeiro_conta_bancaria'),
                    controller: txtConta,
                    prefixIcon: PhosphorIcons.bank,
                    readOnly: true,
                    onTap: () => bottomSheetConta(context, (s) {
                      txtConta.text = s;
                      Navigator.of(context).pop();
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {});
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _section(getText('lb_descricao_opcional')),
                  AppInput(label: getText('lb_descricao'), controller: txtDescricao, prefixIcon: PhosphorIcons.notepad, maxLines: 3),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: getText('btn_save'),
                    onPressed: _isSaving ? null : save,
                    loading: _isSaving,
                    icon: PhosphorIcons.floppyDisk,
                  ),
                  if (id != -1) ...[
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

class FinanceiroModel {
  int? id;
  String? nome, tipo, data, data_vencimento, categoria, conta, descricao, cliente, forma_pagamento, photo;
  double? valor;
  int? parcelas;

  FinanceiroModel({this.id, this.nome, this.tipo, this.data, this.data_vencimento,
      this.valor, this.categoria, this.conta, this.descricao, this.cliente,
      this.forma_pagamento, this.parcelas, this.photo});

  Map toJson() => {
        'id': id, 'nome': nome, 'tipo': tipo, 'data': data,
        'data_vencimento': data_vencimento, 'valor': valor, 'categoria': categoria,
        'conta': conta, 'descricao': descricao, 'cliente': cliente,
        'forma_pagamento': forma_pagamento, 'parcelas': parcelas, 'photo': photo,
      };
}
