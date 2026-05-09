import 'package:click/controllers/controller_generic.dart';
import 'package:click/pages/shared/areas%20sociais/agendamentos_cells.dart';
import 'package:click/pages/shared/areas%20sociais/areas_sociais_cells.dart';
import 'package:click/pages/shared/areas%20sociais/meus_agendamentos_cells.dart';
import 'package:click/pages/shared/areas%20sociais/new_area_social.dart';
import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_typography.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/app/app_scaffold.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListAreasSociais extends StatefulWidget {
  const ListAreasSociais({Key? key}) : super(key: key);
  @override
  _ListAreasSociaisPageState createState() => _ListAreasSociaisPageState();
}

class _ListAreasSociaisPageState extends State<ListAreasSociais> {
  List<dynamic> list = [];
  List<dynamic> listAgendamentos = [];
  List<dynamic> listMeusAgendamentos = [];
  int _currentTab = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    setState(() => _isLoading = true);
    try {
      list = await apiGetAll("areas-sociais");
      listMeusAgendamentos = await apiGetAll("areas-sociais/meus-agendamentos");
      if (getUserType() == 'sindico') {
        listAgendamentos = await apiGetAll("areas-sociais/agendamentos");
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  bool get _isSindico => getUserType() == 'sindico';
  bool get _isMorador => getUserType() == 'morador';

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      Tab(text: getText('lb_areas_sociais')),
      if (_isSindico) Tab(text: getText('area_social_agendamentos')),
      if (_isMorador) Tab(text: getText('area_social_meus_agendamentos')),
    ];

    final views = <Widget>[
      AreasSociaisCells(list: list, reload: loadAll),
      if (_isSindico) AgendamentosCells(list: listAgendamentos, reload: loadAll),
      if (_isMorador) MeusAgendamentosCells(list: listMeusAgendamentos, reload: loadAll),
    ];

    final canAddArea = _currentTab == 0 && (_isSindico || getUserPermission("areas_sociais") == 1);

    return DefaultTabController(
      length: tabs.length,
      child: AppScaffold(
        title: getText('lb_areas_sociais'),
        floatingActionButton: canAddArea
            ? FloatingActionButton(
                onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => NewAreaSocial(isEdit: false)))
                    .then((_) => loadAll()),
                backgroundColor: AppColors.primary,
                child: const Icon(PhosphorIcons.plus, color: Colors.white),
              )
            : null,
        body: Column(
          children: [
            Container(
              color: AppColors.surface(context),
              child: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary(context),
                labelStyle: AppTypography.captionMedium(context),
                onTap: (i) => setState(() => _currentTab = i),
                tabs: tabs,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(children: views),
            ),
          ],
        ),
      ),
    );
  }
}
