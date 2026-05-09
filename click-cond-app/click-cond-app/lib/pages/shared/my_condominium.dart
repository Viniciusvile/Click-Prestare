import 'package:click/controllers/controller_condominio.dart';
import 'package:click/pages/shared/agenda/list_agenda.dart';
import 'package:click/pages/shared/areas%20sociais/list_areas_sociais.dart';
import 'package:click/pages/shared/assembleias/list_assembleias.dart';
import 'package:click/pages/shared/comunicados/list_comunicados.dart';
import 'package:click/pages/shared/configuracoes/configuracoes_view.dart';
import 'package:click/pages/shared/docs/list_docs.dart';
import 'package:click/pages/shared/financeiro/list_financeiro.dart';
import 'package:click/pages/shared/funcionarios/list_funcionarios.dart';
import 'package:click/pages/shared/morador/list_moradores.dart';
import 'package:click/pages/shared/mudancas/list_mudancas.dart';
import 'package:click/pages/shared/ocorrencias/list_ocorrencias.dart';
import 'package:click/pages/shared/prestador%20de%20servico/list_prestadores.dart';
import 'package:click/pages/shared/visitantes/list_visitantes.dart';
import 'package:click/pages/shared/enquetes/list_enquetes.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MyCondominium extends StatefulWidget {
  const MyCondominium({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _MyCondominiumState createState() => _MyCondominiumState();
}

class _MyCondominiumState extends State<MyCondominium> {
  bool _isLoading = false;
  Map<String, dynamic>? _cond;
  late List<_MenuItem> _menu;
  String _saldo = '';

  @override
  void initState() {
    super.initState();
    Singleton.instance.id_condominio = widget.id;
    _menu = _buildMenu();
    _loadCond();
  }

  List<_MenuItem> _buildMenu() {
    final all = <_MenuItem>[
      _MenuItem(getText('lb_areas_sociais'), PhosphorIcons.usersFour, ListAreasSociais()),
      _MenuItem(getText('lb_financeiro'), PhosphorIcons.wallet, ListFinanceiro()),
      _MenuItem(getText('lb_assembleia_votacoes'), PhosphorIcons.usersThree, ListAssembleias()),
      _MenuItem(getText('lb_enquetes'), PhosphorIcons.chartBar, ListEnquetes()),
      _MenuItem(getText('lb_comunicados'), PhosphorIcons.megaphone, ListComunicados()),
      _MenuItem(getText('lb_ocorrencias'), PhosphorIcons.warningCircle, ListOcorrencias()),
      _MenuItem(getText('lb_funcionarios_condominio'), PhosphorIcons.users, ListFuncionarios()),
      _MenuItem(getText('lb_manut_programadas'), PhosphorIcons.wrench, ListAgenda()),
      _MenuItem(getText('lb_prestadores_servico'), PhosphorIcons.handshake, ListPrestadores()),
      _MenuItem(getText('lb_agendar_mudanca'), PhosphorIcons.truck, ListMudancas()),
      _MenuItem(getText('lb_cadastrar_visitante'), PhosphorIcons.userPlus, ListVisitantes()),
      _MenuItem(getText('lb_apartamentos'), PhosphorIcons.house, ListMoradores()),
    ];
    if (getUserType() == 'funcionario') {
      return all.where((i) =>
          i.label != getText('lb_financeiro') &&
          i.label != getText('lb_assembleia_votacoes') &&
          i.label != getText('lb_enquetes') &&
          i.label != getText('lb_funcionarios_condominio')).toList();
    }
    return all;
  }

  Future<void> _loadCond() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await getCondominio(widget.id);
      if (!mounted) return;
      if (result is Map<String, dynamic>) {
        final raw = (result['saldo'] ?? '').toString();
        setState(() {
          _cond = result;
          _saldo = raw.replaceAll("R\$", Singleton.instance.getCurrentMoeda());
        });
      } else {
        _err();
      }
    } catch (_) {
      if (mounted) _err();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _err() {
    displayMessage(context, getText('alert_error'), getText('alert_generic_error'))
        .then((_) { if (mounted) Navigator.pop(context); });
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page))
        .then((_) => _loadCond());
  }

  @override
  Widget build(BuildContext context) {
    final saldoNeg = _saldo.contains('-');
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadCond,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildStats(context, saldoNeg)),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: Text('Gerenciar', style: AppTypography.title(context))),
                      Text('${_menu.length} módulos',
                          style: AppTypography.tiny(context)),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i.isOdd) return const SizedBox(height: AppSpacing.sm);
                      final idx = i ~/ 2;
                      return _MenuRow(
                        item: _menu[idx],
                        onTap: () => _navigate(_menu[idx].page),
                      );
                    },
                    childCount: _menu.length * 2 - 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: [
          Material(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(PhosphorIcons.caretLeft,
                    color: AppColors.textPrimary(context)),
              ),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${getText('ola')} ${getUsername()}',
                    style: AppTypography.bodySecondary(context)),
                if (_cond != null)
                  Text(_cond!['nome'] ?? '',
                      style: AppTypography.headline(context),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            )
          else
            Material(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ConfiguracoesView(condominio: _cond),
                  )).then((_) => _loadCond());
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(PhosphorIcons.gearSix,
                      color: AppColors.textPrimary(context)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, bool saldoNeg) {
    final type = getUserType();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
              blurRadius: 20, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: SizedBox(
                    width: 56, height: 56,
                    child: _cond != null && (_cond!['photo'] ?? '').toString().isNotEmpty
                        ? Image.network(
                            _cond!['photo'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _condFallback(),
                          )
                        : _condFallback(),
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_cond != null)
                        Text(_cond!['nome'] ?? '',
                            style: AppTypography.headline(context).copyWith(color: Colors.white),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      AppSpacing.gapXs,
                      Text(type == 'morador'
                              ? '${getText('lb_apto')} ${Singleton.instance.apartamento}'
                              : '${(_cond?['num_aptos'] ?? 0)} ${getText('lb_apartamentos')}',
                          style: AppTypography.caption(context).copyWith(
                              color: Colors.white.withOpacity(0.85))),
                    ],
                  ),
                ),
              ],
            ),
            if (type != 'funcionario') ...[
              AppSpacing.gapXl,
              Container(height: 1, color: Colors.white.withOpacity(0.2)),
              AppSpacing.gapLg,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getText('lb_saldo'),
                            style: AppTypography.tiny(context).copyWith(
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 1)),
                        AppSpacing.gapXs,
                        Text(_saldo.isEmpty ? '${Singleton.instance.getCurrentMoeda()} 0,00' : _saldo,
                            style: AppTypography.title(context).copyWith(
                                color: saldoNeg ? const Color(0xFFFFB4BC) : Colors.white)),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => _navigate(ListDocs()),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Icon(PhosphorIcons.fileText,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _condFallback() => Container(
        color: Colors.white.withOpacity(0.2),
        child: Icon(PhosphorIcons.buildingsFill,
            color: Colors.white, size: 28),
      );
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Widget page;
  _MenuItem(this.label, this.icon, this.page);
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;
  const _MenuRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.bodyMedium(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(PhosphorIcons.caretRight, size: 16, color: AppColors.textTertiary(context)),
            ],
          ),
        ),
      ),
    );
  }
}
