import 'package:click/pages/sindico/hello.dart';
import 'package:click/pages/sindico/list_condominiums.dart';
import 'package:click/pages/sindico/login.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../utils/local_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _appVersion = "";
  bool _didAutoLogin = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final results = await Future.wait([
      getAppVersion(),
      _requestCameraPermission(),
    ]);
    if (!mounted) return;
    setState(() => _appVersion = results[0] as String);
    _verifyUserLogin();
  }

  Future<void> _requestCameraPermission() async {
    try {
      if (!await Permission.camera.isGranted) {
        await Permission.camera.request();
      }
    } catch (_) {}
  }

  void _verifyUserLogin() {
    if (_didAutoLogin) return;
    final token = getToken();
    if (token.isNotEmpty) {
      _didAutoLogin = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ListCondomiums()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.huge),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 24, offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      PhosphorIcons.buildingsFill,
                      size: 56, color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  'Bem-vindo',
                  style: AppTypography.display(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Gerencie seu condomínio com simplicidade',
                  style: AppTypography.bodySecondary(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.huge),
                AppButton(
                  label: getText("sou_sindico"),
                  variant: AppButtonVariant.primary,
                  trailingIcon: PhosphorIcons.arrowRight,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const Hello()));
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: getText("sou_morador"),
                  variant: AppButtonVariant.secondary,
                  trailingIcon: PhosphorIcons.arrowRight,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginSindico(loginType: 'morador')),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: getText("sou_funcionario"),
                  variant: AppButtonVariant.ghost,
                  trailingIcon: PhosphorIcons.arrowRight,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginSindico(loginType: 'funcionario')),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.huge),
                Text(
                  '${getText("vesaoApp")} $_appVersion',
                  style: AppTypography.tiny(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
