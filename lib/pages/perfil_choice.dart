import 'package:click/pages/sindico/hello.dart';
import 'package:click/pages/sindico/list_condominiums.dart';
import 'package:click/pages/sindico/login.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/label/label_default.dart';
import 'package:flutter/material.dart';
import 'package:click/widgets/containers/background.dart';
import 'package:click/widgets/buttons/alternative_button.dart';
import 'package:permission_handler/permission_handler.dart';

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
    // Carrega versão e pede permissão em paralelo
    final results = await Future.wait([
      getAppVersion(),
      _requestCameraPermission(),
    ]);

    if (!mounted) return;
    setState(() => _appVersion = results[0] as String);

    // Verifica login após garantir que storage está pronto
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
      // pushReplacement evita acumular HomePage na stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ListCondomiums()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.fromLTRB(40, 120, 40, 0),
          width: MediaQuery.of(context).size.width,
          decoration: backgroundDecoration(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      height: MediaQuery.of(context).size.width * 0.35,
                      image: const AssetImage('assets/logo.png'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LabelDefault(
                  title: "${getText("vesaoApp")} $_appVersion",
                  color: Colors.white70,
                  size: 11,
                ),
                const SizedBox(height: 25),
                AlternativeButton(
                  title: getText("sou_sindico"),
                  backgroundColor: Colors.white,
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Hello()),
                    );
                  },
                ),
                const SizedBox(height: 30),
                AlternativeButton(
                  title: getText("sou_morador"),
                  backgroundColor: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginSindico(loginType: 'morador'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                AlternativeButton(
                  title: getText("sou_funcionario"),
                  backgroundColor: const Color.fromRGBO(1, 149, 218, 1),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginSindico(loginType: 'funcionario'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
