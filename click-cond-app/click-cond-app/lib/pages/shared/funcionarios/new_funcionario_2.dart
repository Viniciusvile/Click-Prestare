import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:click/widgets/cells/cell_permissoes_funcionario.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewFuncionario2 extends StatefulWidget {
  const NewFuncionario2({Key? key}) : super(key: key);

  @override
  _NewFuncionario2PageState createState() => _NewFuncionario2PageState();
}

class _NewFuncionario2PageState extends State<NewFuncionario2> {
  late List<int> list = [1, 2, 3, 4, 1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: getText('libere_funcoes'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        Expanded(
                          child: Text(
                            getText('libere_funcoes'),
                            style: AppTypography.body(context).copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var item in list)
                    GestureDetector(
                      onTap: () {},
                      child: CellPermissoesFuncionario(item: 1, hasArrow: true),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: AppButton(
              label: getText('btn_save'),
              icon: PhosphorIcons.floppyDisk,
              onPressed: () {
                var nav = Navigator.of(context);
                nav.pop();
                nav.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
