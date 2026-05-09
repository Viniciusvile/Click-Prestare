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
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewFinanceiro extends StatefulWidget {
  const NewFinanceiro({Key? key, required this.isEdit, this.myId, this.obj}) : super(key: key);
  final bool isEdit;
  final int? myId;
  final dynamic obj;

  @override
  _NewFinanceiroPageState createState() => _NewFinanceiroPageState();
}

class _NewFinanceiroPageState extends State<NewFinanceiro> {
  var _isSaving = false;
  var tipo = 'D';
  final txtNome = TextEditingController();
  final txtData = TextEditingController();
  final txtValor = TextEditingController();
  final txtCategoria = TextEditingController();

  @override
  void dispose() {
    txtNome.dispose(); txtData.dispose();
    txtValor.dispose(); txtCategoria.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) load();
  }

  Future<void> load() async {
    tipo = widget.obj['tipo'];
    txtNome.text = widget.obj['nome'];
    txtData.text = '${widget.obj['dia']}/${widget.obj['mes']}/${widget.obj['ano']}';
    txtValor.text = widget.obj['valor'].toString().replaceAll('-', '');
    txtCategoria.text = widget.obj['categoria'];
    if (mounted) setState(() {});
  }

  Future<void> save() async {
    try {
      setState(() => _isSaving = true);
      var obj = FinanceiroModel(
        id: widget.myId ?? -1,
        nome: txtNome.text,
        tipo: tipo,
        categoria: txtCategoria.text,
        data: convertStringToDate(txtData.text),
        valor: double.parse(txtValor.text.replaceAll('.', '').replaceAll(',', '.')),
      );
      var res = await apiSaveObject("financeiro", "financeiro", obj, widget.isEdit);
      if (res.toString().isEmpty) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        if (mounted) displayMessage(context, getText('alert_error'), res.toString());
      }
    } catch (e) {
      if (mounted) displayMessage(context, getText('alert_error'), getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> delete() async {
    var choice = await showConfirmDialog(context);
    if (choice != null && choice) {
      setState(() => _isSaving = true);
      var res = await apiDeleteObject('financeiro', widget.myId!);
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
      title: widget.isEdit ? getText('financeiro_nav_edit') : getText('financeiro_nav_new'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(getText('financeiro_tipo')),
            Row(
              children: [
                Expanded(child: _TipoChip(label: getText('financeiro_receita'), value: 'C', selected: tipo, onTap: () => setState(() => tipo = 'C'))),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _TipoChip(label: getText('financeiro_despesa'), value: 'D', selected: tipo, onTap: () => setState(() => tipo = 'D'))),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _section(getText('financeiro_dados')),
            AppInput(label: getText('nome'), controller: txtNome, prefixIcon: PhosphorIcons.tag, textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: AppSpacing.md),
            AppInput(label: getText('lb_categoria'), controller: txtCategoria, prefixIcon: PhosphorIcons.folderOpen, textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: AppSpacing.xl),
            _section(getText('data')),
            AppInput(
              label: getText('data'),
              controller: txtData,
              prefixIcon: PhosphorIcons.calendarBlank,
              readOnly: true,
              onTap: () => showCupertinoModalPopup(
                context: context,
                builder: (_) => ModalCupertino(
                  onPressed: (text) => setState(() => txtData.text = text),
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

class _TipoChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;
  const _TipoChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border(context)),
        ),
        child: Center(
          child: Text(label,
              style: AppTypography.bodyMedium(context).copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary(context),
              )),
        ),
      ),
    );
  }
}

class FinanceiroModel {
  int? id;
  String? nome;
  String? tipo;
  String? data;
  double? valor;
  String? categoria;

  FinanceiroModel({this.id, this.nome, this.tipo, this.data, this.valor, this.categoria});

  Map toJson() => {
        'id': id, 'nome': nome, 'tipo': tipo,
        'data': data, 'valor': valor, 'categoria': categoria,
      };
}
