import 'package:click/pages/sindico/hello.dart';
import 'package:click/pages/sindico/list_condominiums.dart';
import 'package:click/pages/sindico/login.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/theme/theme_controller.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
        body: Stack(
          children: [
            // Background Gradient & Grid Pattern matching the premium Web look
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [const Color(0xFF0A1628), const Color(0xFF131D2E)]
                        : [const Color(0xFFEBF3FC), const Color(0xFFFFFFFF)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(context),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Corporate Branding row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            PhosphorIcons.buildings,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'PRESTARE ',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.textPrimary(context),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'CLICK',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
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
            // Floating Light/Dark Mode Theme Toggle Button (placed at the end of Stack so it stays on top of everything for hit-testing)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              right: AppSpacing.lg,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Material(
                  color: AppColors.surfaceElevated(context),
                  child: InkWell(
                    onTap: () {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      ThemeController.instance.setMode(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border(context),
                          width: 1.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? PhosphorIcons.sun
                            : PhosphorIcons.moon,
                        color: AppColors.textPrimary(context),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final BuildContext context;
  GridPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.02 : 0.025)
      ..strokeWidth = 0.8;

    const double step = 38.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
