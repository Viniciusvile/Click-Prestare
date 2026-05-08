import 'package:click/controllers/controller_condominio.dart';
import 'package:click/controllers/controller_moradores.dart';
import 'package:click/pages/shared/funcionarios/edit_funcionario.dart';
import 'package:click/pages/shared/morador/assinatura_morador.dart';
import 'package:click/pages/shared/morador/edit_morador.dart';
import 'package:click/pages/shared/my_condominium.dart';
import 'package:click/pages/sindico/assinatura_sindico.dart';
import 'package:click/pages/sindico/edit_sindico.dart';
import 'package:click/pages/sindico/signup/signup_%20condominium_1.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:click/widgets/buttons/float_button.dart';
import 'package:click/widgets/card/card_condominium.dart';
import 'package:click/widgets/containers/box_sindico.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/box_blue_top_rounded.dart';

import '../../controllers/controller_funcionario.dart';
import '../singleton.dart';

class ListCondomiums extends StatefulWidget {
  const ListCondomiums({Key? key}) : super(key: key);

  @override
  _ListCondomiumsState createState() => _ListCondomiumsState();
}

class _ListCondomiumsState extends State<ListCondomiums> {
  List<dynamic> _list = [];
  var _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    if (!mounted) return;

    // Verifica sessão sem pop imediato — mostra erro na própria tela
    final token = getToken();
    if (token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userType = getUserType();
      dynamic locals;
      if (userType == "sindico") {
        locals = await getCondominios();
      } else if (userType == "morador") {
        locals = await getCondominiosMorador();
      } else {
        locals = await getCondominiosFuncionario();
      }

      if (!mounted) return;

      if (locals is List) {
        setState(() => _list = locals);
      } else {
        setState(() => _errorMessage = getText('alert_generic_error'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = getText('alert_generic_error'));
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

    final diasRestantes = item["dias_restantes_condominio"] ?? 0;
    final userType = getUserType();

    if (userType == "sindico") {
      if (diasRestantes <= 7) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AssinaturaSindico(condominio: item)),
        ).then((value) {
          if (!mounted) return;
          if (diasRestantes > 0 || (value != null && value == true)) {
            _pushCondominium(item["id"]);
          }
        });
      } else {
        _pushCondominium(item["id"]);
      }
    } else if (userType == "morador") {
      final diasMorador = item["dias_restantes_morador"] ?? 0;
      if (diasMorador <= 7) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AssinaturaMorador(condominio: item)),
        ).then((value) {
          if (!mounted) return;
          if (diasMorador > 0 || (value != null && value == true)) {
            _pushCondominium(item["id"]);
          }
        });
      } else {
        _pushCondominium(item["id"]);
      }
    } else {
      _pushCondominium(item["id"]);
    }
  }

  void _pushCondominium(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyCondominium(id: id)),
    ).then((_) {
      if (mounted) _loadList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarSize = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 280,
                      padding: EdgeInsets.fromLTRB(15, statusBarSize + 10, 15, 0),
                      decoration: backgroundDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  storageLogout();
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil('/', (_) => false);
                                },
                                child: Text(
                                  getText('lb_logout'),
                                  textScaleFactor: 1.0,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getText('meus_condominios'),
                                textScaleFactor: 1.0,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 280,
                      padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_errorMessage != null && !_isLoading)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    LabelDefault(
                                      title: _errorMessage!,
                                      maxLines: 10,
                                      size: 16,
                                      align: TextAlign.center,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _loadList,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Tentar novamente'),
                                    ),
                                  ],
                                ),
                              ),
                            if (_list.isEmpty && !_isLoading && _errorMessage == null)
                              LabelDefault(
                                title: "\n\nVocê ainda não possui condomínios!",
                                maxLines: 10,
                                size: 18,
                                align: TextAlign.center,
                                color: Theme.of(context).primaryColor,
                                weight: FontWeight.w500,
                              ),
                            if (_list.isEmpty && !_isLoading && _errorMessage == null && getUserType() == "sindico")
                              LabelDefault(
                                title: "\n\nClick no botão abaixo e cadastre o seu primeiro.",
                                maxLines: 10,
                                size: 18,
                                align: TextAlign.center,
                                color: Theme.of(context).primaryColor,
                                weight: FontWeight.w500,
                              ),
                            for (var item in _list)
                              GestureDetector(
                                onTap: () => _goToNext(item),
                                child: CardCondominium(item: item),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 165, right: 30, left: 30),
                  child: Container(
                    height: 150.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxSindico(),
                    padding: const EdgeInsets.fromLTRB(40, 50, 40, 10),
                    child: Column(
                      children: [
                        Text(
                          "${getText('ola')}, ${getUsername()}",
                          textScaleFactor: 1.0,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 29,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        DefaultButton(
                          title: getText('editar_infos'),
                          hasArrow: false,
                          isRounded: true,
                          size: 40,
                          onPressed: () {
                            final type = getUserType();
                            Widget page;
                            if (type == 'sindico') {
                              page = EditSindico();
                            } else if (type == 'morador') {
                              page = EditMorador();
                            } else {
                              page = EditFuncionario();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => page),
                            ).then((_) {
                              if (mounted) setState(() {});
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 125, right: 30, left: 30),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: (getUserPhoto().isNotEmpty)
                        ? NetworkImage(getUserPhoto()) as ImageProvider
                        : const AssetImage('assets/images/defaultUser.png'),
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
        ],
      ),
      floatingActionButton: getUserType() == 'sindico'
          ? FloatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupCondominuim1()),
                ).then((_) {
                  if (mounted) _loadList();
                });
              },
            )
          : null,
    );
  }
}
