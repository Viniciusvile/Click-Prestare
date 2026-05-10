import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:click/controllers/controller_condominio.dart';
import 'package:click/pages/sindico/signup/signup_%20condominium_1.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/modal_signup_success.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SignupCondominuim3 extends StatefulWidget {
  const SignupCondominuim3({Key? key, required this.condominio}) : super(key: key);
  final CondominioRegister condominio;

  @override
  _SignupCondominuim3PageState createState() => _SignupCondominuim3PageState();
}

class _SignupCondominuim3PageState extends State<SignupCondominuim3> {
  var _isLoading = false;

  Future<void> _register() async {
    widget.condominio.blocos = 0;
    widget.condominio.aptos = 0;

    setState(() => _isLoading = true);
    try {
      final message = await registerCondominio(widget.condominio);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (message == "") {
        showDialog(
          context: context,
          builder: (_) => CustomDialogBox(),
        );
      } else {
        displayMessage(context, getText('alert_error'), message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      displayMessage(context, getText('alert_error'), getText('alert_invalid_value'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('signup_cond_nav'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  backgroundImage: widget.condominio.photo != null
                      ? (kIsWeb
                          ? NetworkImage(widget.condominio.photo!)
                          : NetworkImage(widget.condominio.photo!)) as ImageProvider
                      : const AssetImage('assets/images/business_default.png'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.condominio.nome ?? '',
                    style: AppTypography.headline(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _PlanCard(context),
            const SizedBox(height: AppSpacing.xl),
            _StepIndicator(step: 3, total: 3),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: getText('btn_save'),
              onPressed: _isLoading ? null : _register,
              loading: _isLoading,
              size: AppButtonSize.lg,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _PlanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(PhosphorIcons.star, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(getText('signup_cond_valor_total'), style: AppTypography.headline(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            getText('signup_cond_valor_mensal'),
            style: AppTypography.body(context).copyWith(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(PhosphorIcons.gift, getText('signup_cond_dias_gratuitos'), context),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(PhosphorIcons.xCircle, getText('signup_cond_cancele_label'), context),
        ],
      ),
    );
  }

  Widget _InfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption(context).copyWith(color: AppColors.textSecondary(context)),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final int total;
  const _StepIndicator({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$step de $total',
          style: AppTypography.captionMedium(context).copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: step / total,
            minHeight: 6,
            backgroundColor: AppColors.border(context),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
