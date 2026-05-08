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
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/bottom_sheet_edit_condominio.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/card/card_menu.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/box_blue_top_rounded.dart';

import '../singleton.dart';

class MyCondominium extends StatefulWidget {
  const MyCondominium({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _MyCondominiumState createState() => _MyCondominiumState();
}

class _MyCondominiumState extends State<MyCondominium> {
  var _isLoading = false;
  Map<String, dynamic>? _cond;
  late List<HomeMenuModel> _menuList;
  var _saldo = '';

  @override
  void initState() {
    super.initState();
    Singleton.instance.id_condominio = widget.id;
    _menuList = _buildMenuList();
    _loadCond();
  }

  List<HomeMenuModel> _buildMenuList() {
    final all = [
      HomeMenuModel(nome: getText('lb_areas_sociais'), image: const AssetImage('assets/icon/ic_area_social.png'), navigator: ListAreasSociais()),
      HomeMenuModel(nome: getText('lb_financeiro'), image: const AssetImage('assets/icon/ic_financeiro.png'), navigator: ListFinanceiro()),
      HomeMenuModel(nome: getText('lb_assembleia_votacoes'), image: const AssetImage('assets/icon/ic_assembleias.png'), navigator: ListAssembleias()),
      HomeMenuModel(nome: getText('lb_enquetes'), image: const AssetImage('assets/icon/ic_enquete.png'), navigator: ListEnquetes()),
      HomeMenuModel(nome: getText('lb_comunicados'), image: const AssetImage('assets/icon/ic_comunicados.png'), navigator: ListComunicados()),
      HomeMenuModel(nome: getText('lb_ocorrencias'), image: const AssetImage('assets/icon/ic_ocorrencias.png'), navigator: ListOcorrencias()),
      HomeMenuModel(nome: getText('lb_funcionarios_condominio'), image: const AssetImage('assets/icon/ic_funcionarios.png'), navigator: ListFuncionarios()),
      HomeMenuModel(nome: getText('lb_manut_programadas'), image: const AssetImage('assets/icon/ic_agenda2.png'), navigator: ListAgenda()),
      HomeMenuModel(nome: getText('lb_prestadores_servico'), image: const AssetImage('assets/icon/ic_prestador.png'), navigator: ListPrestadores()),
      HomeMenuModel(nome: getText('lb_agendar_mudanca'), image: const AssetImage('assets/icon/ic_mudanca.png'), navigator: ListMudancas()),
      HomeMenuModel(nome: getText('lb_cadastrar_visitante'), image: const AssetImage('assets/icon/ic_visitante.png'), navigator: ListVisitantes()),
      HomeMenuModel(nome: getText('lb_apartamentos'), image: const AssetImage('assets/icon/ic_morador.png'), navigator: ListMoradores()),
    ];

    if (getUserType() == 'funcionario') {
      // Remove por nome para não depender de índices fixos (bug original)
      return all.where((item) =>
        item.nome != getText('lb_financeiro') &&
        item.nome != getText('lb_assembleia_votacoes') &&
        item.nome != getText('lb_enquetes') &&
        item.nome != getText('lb_funcionarios_condominio')
      ).toList();
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
        final rawSaldo = (result['saldo'] ?? '').toString();
        setState(() {
          _cond = result;
          _saldo = rawSaldo.replaceAll("R\$", Singleton.instance.getCurrentMoeda());
        });
      } else {
        _showErrorAndPop();
      }
    } catch (e) {
      if (mounted) _showErrorAndPop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorAndPop() {
    displayMessage(context, getText('alert_error'), getText('alert_generic_error'))
        .then((_) { if (mounted) Navigator.pop(context); });
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page))
        .then((_) => _loadCond());
  }

  @override
  Widget build(BuildContext context) {
    final statusBarSize = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 330,
                    padding: EdgeInsets.fromLTRB(20, statusBarSize + 10, 20, 0),
                    decoration: backgroundDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.only(bottom: 8),
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(true),
                              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
                            ),
                            LabelTitle(
                              title: "${getText('ola')} ${getUsername().split(" ")[0]}",
                              size: 30,
                              color: Colors.white,
                            ),
                            IconButton(
                              padding: const EdgeInsets.only(bottom: 8),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConfiguracoesView(condominio: _cond),
                                  ),
                                ).then((_) => _loadCond());
                              },
                              icon: const Icon(Icons.settings_outlined, size: 30, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (_cond != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  _cond!["photo"] ?? '',
                                  width: MediaQuery.of(context).size.width * 0.22,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: MediaQuery.of(context).size.width * 0.22,
                                    height: 100,
                                    color: Colors.white24,
                                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_cond != null)
                                    LabelDefault(
                                      title: _cond!["nome"] ?? '',
                                      size: 20,
                                      color: Colors.white,
                                      maxLines: 2,
                                    ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (getUserType() == 'sindico')
                                        ElevatedButton(
                                          onPressed: () {
                                            bottomSheetEditCondominio(context, (callback) {
                                              Navigator.pop(context);
                                              _loadCond();
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                            ),
                                          ),
                                          child: Text(
                                            getText('editar_infos'),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      if (getUserType() != 'funcionario')
                                        ElevatedButton(
                                          onPressed: () {
                                            _navigate(ListDocs());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                            ),
                                          ),
                                          child: Text(
                                            getText('lb_docs'),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () => _navigate(ListMoradores()),
                              child: getUserType() != "morador"
                                  ? Column(
                                      children: [
                                        if (_cond != null)
                                          LabelDefault(
                                            title: (_cond!["num_aptos"] ?? '').toString(),
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        LabelDefault(title: getText('lb_apartamentos'), size: 20, color: Colors.white),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        const Icon(Icons.home_outlined, color: Colors.white, size: 30),
                                        const SizedBox(width: 5),
                                        LabelDefault(
                                          title: "${getText('lb_apto')} ${Singleton.instance.apartamento}",
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                            if (getUserType() != 'funcionario') ...[
                              const SizedBox(width: 40),
                              InkWell(
                                onTap: () => _navigate(ListFinanceiro()),
                                child: Column(
                                  children: [
                                    LabelDefault(
                                      title: _saldo.isEmpty ? '${Singleton.instance.getCurrentMoeda()} 0,00' : _saldo,
                                      size: 30,
                                      color: _saldo.contains('-') ? Colors.red[500] : Colors.white,
                                    ),
                                    LabelDefault(title: getText('lb_saldo'), size: 20, color: Colors.white),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 260, right: 15, left: 15, bottom: 30),
                child: GridView.count(
                  primary: false,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: _menuList
                      .map((item) => GestureDetector(
                            onTap: () => _navigate(item.navigator),
                            child: CardMenu(item: item),
                          ))
                      .toList(),
                ),
              ),
              if (_isLoading)
                const Loader(
                  loadingTxt: '',
                  opacity: 0.7,
                  color: Colors.black,
                  dismissibles: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeMenuModel {
  final String nome;
  final AssetImage image;
  final dynamic navigator;

  const HomeMenuModel({
    required this.nome,
    required this.image,
    required this.navigator,
  });
}
