import 'package:click/controllers/controller_sindico.dart';
import 'package:click/pages/sindico/forgot_password.dart';
import 'package:click/pages/sindico/list_condominiums.dart';
import 'package:click/utils/local_storage.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/background.dart';
import 'package:click/widgets/textfields/textfield_rounded.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';

import '../../controllers/controller_funcionario.dart';
import '../../controllers/controller_moradores.dart';

class LoginSindico extends StatefulWidget {
  const LoginSindico({Key? key, required this.loginType}) : super(key: key);
  final String loginType;

  @override
  _LoginSindicoPageState createState() => _LoginSindicoPageState();
}

class _LoginSindicoPageState extends State<LoginSindico> {
  final _txtLogin = TextEditingController();
  final _txtSenha = TextEditingController();

  var _isLoading = false;

  @override
  void dispose() {
    // Libera memória dos controllers ao sair da tela
    _txtLogin.dispose();
    _txtSenha.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (_isLoading) return; // evita cliques múltiplos

    final login = _txtLogin.text.trim();
    final senha = _txtSenha.text.trim();
    if (login.isEmpty || senha.isEmpty) {
      displayMessage(context, getText('alert_error'), getText('login_error'));
      return;
    }

    setState(() => _isLoading = true);

    String message;
    try {
      if (widget.loginType == 'sindico') {
        message = await loginSindico(login, senha);
      } else if (widget.loginType == 'morador') {
        message = await loginMorador(login, senha);
      } else {
        message = await loginFuncionario(login, senha);
      }

      if (getUsername().isEmpty) {
        message = getText('login_error');
      }
    } catch (e) {
      message = getText('login_error');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (message == "") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ListCondomiums()),
      );
    } else {
      displayMessage(context, getText('alert_error'), message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 149, 218, 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  decoration: backgroundDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image(
                          height: MediaQuery.of(context).size.width * 0.4,
                          image: const AssetImage('assets/logo.png'),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxMainRounded(),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            getText(widget.loginType).toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFieldRounded(
                            title: getText('email'),
                            isPassword: false,
                            controller: _txtLogin,
                          ),
                          const SizedBox(height: 30),
                          TextFieldRounded(
                            title: getText('senha'),
                            isPassword: true,
                            controller: _txtSenha,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPassword(
                                          loginType: widget.loginType),
                                    ),
                                  );
                                },
                                child: Text(
                                  getText('login_btn_esqueci_senha'),
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          DefaultButton(
                            title: getText('login_btn_entrar'),
                            hasArrow: false,
                            onPressed: _isLoading ? null : _doLogin,
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SizedBox.expand(
              child: Loader(
                loadingTxt: 'Carregando...',
                opacity: 0.7,
                color: Colors.black,
                dismissibles: false,
              ),
            ),
        ],
      ),
    );
  }
}
