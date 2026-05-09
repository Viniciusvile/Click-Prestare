import 'package:click/controllers/controller_condominio.dart';
import 'package:click/controllers/controller_funcionario.dart';
import 'package:click/controllers/controller_moradores.dart';
import 'package:click/pages/shared/funcionarios/edit_funcionario.dart';
import 'package:click/pages/shared/morador/assinatura_morador.dart';
import 'package:click/pages/shared/morador/edit_morador.dart';
import 'package:click/pages/shared/my_condominium.dart';
import 'package:click/pages/sindico/assinatura_sindico.dart';
import 'package:click/pages/sindico/edit_sindico.dart';
import 'package:click/pages/sindico/signup/signup_%20condominium_1.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_spacing.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/widgets/app/app_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListCondomiums extends StatefulWidget {
  const ListCondomiums({Key? key}) : super(key: key);

  @override
  _ListCondomiumsState createState() => _ListCondomiumsState();
}

class _ListCondomiumsState extends State<ListCondomiums> {
  List<dynamic> _list = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    if (!mounted) return;
    final token = getToken();
    if (token.isEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final type = getUserType();
      final locals = type == "sindico"
          ? await getCondominios()
          : type == "morador"
              ? await getCondominiosMorador()
              : await getCondominiosFuncionario();
      if (!mounted) return;
      if (locals is List) {
        setState(() => _list = locals);
      } else {
        setState(() => _errorMessage = getText('alert_generic_error'));
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = getText('alert_generic_error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToNext(dynamic item) {
    Singleton.instance.apartamento = item["apto"] ?? '';
    Singleton.instance.id_apartamento = item["apto_id"] ?? -1;
    Singleton.instance.bloco = item["apto_bloco"] ?? '';
    Singleton.instance.dias_restantes_morador = item["dias_restantes_morador"] ?? 10;
    Singleton.instance.vencimento_morador = item["vencimento_morador"] ?? "";
    Singleton.instance.moeda = item["moeda"] ?? "";

    final dias = item["dias_restantes_condominio"] ?? 0;
    final type = getUserType();
    if (type == "sindico" && dias <= 7) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => AssinaturaSindico(condominio: item),
      )).then((value) {
        if (mounted && (dias > 0 || value == true)) _push(item["id"]);
      });
    } else if (type == "morador" && (item["dias_restantes_morador"] ?? 0) <= 7) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => AssinaturaMorador(condominio: item),
      )).then((value) {
        if (mounted && ((item["dias_restantes_morador"] ?? 0) > 0 || value == true)) _push(item["id"]);
      });
    } else {
      _push(item["id"]);
    }
  }

  void _push(int id) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MyCondominium(id: id),
    )).then((_) { if (mounted) _loadList(); });
  }

  void _editProfile() {
    final type = getUserType();
    Widget page;
    if (type == 'sindico') {
      page = EditSindico();
    } else if (type == 'morador') {
      page = EditMorador();
    } else {
      page = EditFuncionario();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page))
        .then((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadList,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (_errorMessage != null)
                SliverToBoxAdapter(child: _buildError())
              else if (_list.isEmpty)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
                  sliver: SliverList.separated(
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) => _CondominioCard(
                      item: _list[i],
                      onTap: () => _goToNext(_list[i]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: getUserType() == 'sindico'
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SignupCondominuim1(),
                )).then((_) { if (mounted) _loadList(); });
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Icon(PhosphorIcons.plus),
              label: Text(
                'Novo',
                style: AppTypography.button(context).copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: getUserPhoto().isNotEmpty
                    ? NetworkImage(getUserPhoto())
                    : null,
                child: getUserPhoto().isEmpty
                    ? Icon(PhosphorIcons.userFill,
                        color: AppColors.primary, size: 28)
                    : null,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getText('ola'),
                        style: AppTypography.bodySecondary(context)),
                    Text(getUsername(),
                        style: AppTypography.headline(context)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(PhosphorIcons.pencilSimple,
                    color: AppColors.textSecondary(context)),
                onPressed: _editProfile,
                tooltip: getText('editar_infos'),
              ),
              IconButton(
                icon: Icon(PhosphorIcons.signOut,
                    color: AppColors.textSecondary(context)),
                tooltip: getText('lb_logout'),
                onPressed: () {
                  storageLogout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(getText('meus_condominios'),
              style: AppTypography.title(context)),
          AppSpacing.gapXs,
          Text('${_list.length} ${_list.length == 1 ? "condomínio" : "condomínios"}',
              style: AppTypography.bodySecondary(context)),
          AppSpacing.gapXl,
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(PhosphorIcons.warningCircle,
              size: 56, color: AppColors.error),
          AppSpacing.gapLg,
          Text(_errorMessage!,
              style: AppTypography.body(context),
              textAlign: TextAlign.center),
          AppSpacing.gapXl,
          AppButton(
            label: 'Tentar novamente',
            icon: PhosphorIcons.arrowClockwise,
            variant: AppButtonVariant.secondary,
            onPressed: _loadList,
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final isSindico = getUserType() == 'sindico';
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          AppSpacing.gapXxxl,
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.buildings,
                size: 48, color: AppColors.primary),
          ),
          AppSpacing.gapLg,
          Text('Nenhum condomínio',
              style: AppTypography.headline(context)),
          AppSpacing.gapSm,
          Text(
            isSindico
                ? 'Toque em "Novo" para cadastrar seu primeiro condomínio'
                : 'Você ainda não possui condomínios vinculados',
            style: AppTypography.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CondominioCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  const _CondominioCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final saldo = (item['saldo'] ?? '').toString();
    final isNegative = saldo.contains('-');
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: SizedBox(
                  width: 64, height: 64,
                  child: item['photo'] != null && item['photo'].toString().isNotEmpty
                      ? Image.network(
                          item['photo'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              AppSpacing.gapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nome'] ?? '',
                        style: AppTypography.bodyMedium(context),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    AppSpacing.gapXs,
                    Text(saldo.isEmpty ? '—' : saldo,
                        style: AppTypography.caption(context).copyWith(
                          color: isNegative ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
              Icon(PhosphorIcons.caretRight,
                  color: AppColors.textTertiary(context), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primaryLight,
      child: Icon(PhosphorIcons.buildingsFill,
          color: AppColors.primary, size: 32),
    );
  }
}
