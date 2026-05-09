import 'package:click/controllers/controller_moradores.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AssinaturaMorador extends StatefulWidget {
  final dynamic condominio;
  const AssinaturaMorador({Key? key, required this.condominio}) : super(key: key);

  @override
  _AssinaturaMoradorPageState createState() => _AssinaturaMoradorPageState();
}

class _AssinaturaMoradorPageState extends State<AssinaturaMorador> {
  var _isLoading = false;
  List<ProductDetails> products = [];
  ProductDetails? selected;

  @override
  void initState() {
    super.initState();
    monitorSubscriptions();
    loadProducts();
  }

  String getDiasRestantes() {
    if (Singleton.instance.dias_restantes_morador < 0) return '0 dias';
    if (Singleton.instance.dias_restantes_morador == 1) return '1 dia';
    return '${Singleton.instance.dias_restantes_morador} dias';
  }

  Future<void> buy() async {
    if (selected != null) save('codigoApple123', selected!.id);
  }

  void monitorSubscriptions() async {
    await InAppPurchase.instance.isAvailable();
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {}, onError: (error) {});
  }

  Future<void> loadProducts() async {
    products = [
      ProductDetails(id: 'click_mensal_morador', title: 'mensal', description: '', price: 'R\$ 3,50', rawPrice: 3.50, currencyCode: 'BRL'),
      ProductDetails(id: 'click_semestral_morador', title: 'semestral', description: '', price: 'R\$ 19,44', rawPrice: 19.44, currencyCode: 'BRL'),
      ProductDetails(id: 'click_anual_morador', title: 'anual', description: '', price: 'R\$ 38,39', rawPrice: 38.39, currencyCode: 'BRL'),
    ];
    if (mounted) setState(() {});
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.error) {
        displayMessage(context, getText('alert_error'),
            purchaseDetails.error?.details?['NSLocalizedDescription'] ?? getText('assinatura_erro'));
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        save(purchaseDetails.purchaseID ?? '', purchaseDetails.productID);
      }
      if (purchaseDetails.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> save(String purchaseID, String planoId) async {
    try {
      setState(() => _isLoading = true);
      await updateAsinaturaMoradorApi(widget.condominio['id'].toString(), planoId, purchaseID);
      await displayMessage(context, getText('alert_success'), getText('assinatura_renovada'));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) await displayMessage(context, getText('alert_error'), e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String getPrice(String tipo) {
    for (var prod in products) {
      if (prod.title.toLowerCase().contains(tipo)) return prod.price;
    }
    return '';
  }

  void changeSelected(String plano) {
    for (var prod in products) {
      if (prod.title.toLowerCase().contains(plano)) selected = prod;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final venceu = Singleton.instance.dias_restantes_morador <= 0;
    final precisaRenovar = Singleton.instance.dias_restantes_morador <= 7;

    return AppScaffold(
      title: getText('assinatura'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/images/img-assinatura.png', width: 200),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(widget.condominio['photo']),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(widget.condominio['nome'],
                                  style: AppTypography.bodyMedium(context)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _InfoRow(label: getText('nome'), value: getUsername()),
                        _InfoRow(label: getText('assinatura_validade'), value: Singleton.instance.vencimento_morador),
                        _InfoRow(label: getText('assinatura_dias_restantes'), value: getDiasRestantes()),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (precisaRenovar) ...[
                    if (venceu)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(PhosphorIcons.warningCircle, color: Colors.red, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(getText('assinatura_venceu'),
                                  style: AppTypography.body(context).copyWith(color: Colors.red, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Text(getText('assinatura_renove_agora'), style: AppTypography.body(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(getText('assinatura_renove_agora_obs'),
                        style: AppTypography.body(context).copyWith(color: AppColors.textSecondary(context))),
                    const SizedBox(height: AppSpacing.lg),
                    _section(getText('assinatura_morador')),
                    _PlanOption(
                      label: '${getText('assinatura_mensal')}: ${getPrice('mensal')}',
                      selected: selected?.title.toLowerCase().contains('mensal') ?? false,
                      onTap: () => changeSelected('mensal'),
                    ),
                    _PlanOption(
                      label: '${getText('assinatura_semestral')}: ${getPrice('semestral')}',
                      selected: selected?.title.toLowerCase().contains('semestral') ?? false,
                      onTap: () => changeSelected('semestral'),
                    ),
                    _PlanOption(
                      label: '${getText('assinatura_anual')}: ${getPrice('anual')}',
                      selected: selected?.title.toLowerCase().contains('anual') ?? false,
                      onTap: () => changeSelected('anual'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: getText('assinatura_btn_mensal_morador'),
                      onPressed: buy,
                      icon: PhosphorIcons.creditCard,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(getText('assinatura_renovar_depois'),
                            style: AppTypography.body(context).copyWith(color: Colors.red)),
                      ),
                    ),
                  ],
                  if (!precisaRenovar)
                    Text(getText('assinatura_renovar_7_dias'),
                        style: AppTypography.body(context).copyWith(color: AppColors.textSecondary(context))),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text('$label: ', style: AppTypography.body(context).copyWith(
            fontWeight: FontWeight.w500, color: AppColors.textSecondary(context))),
          Text(value, style: AppTypography.body(context)),
        ],
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PlanOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(
              selected ? PhosphorIcons.checkCircle : PhosphorIcons.circle,
              color: selected ? AppColors.primary : AppColors.textSecondary(context),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTypography.body(context).copyWith(
              color: selected ? AppColors.primary : null,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}
