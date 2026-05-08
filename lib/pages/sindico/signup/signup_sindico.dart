import 'dart:convert';
import 'dart:io';

import 'package:click/controllers/controller_sindico.dart';
import 'package:click/pages/sindico/list_condominiums.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/alerts/loader.dart';
import 'package:click/widgets/buttons/default_button.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignupSindico extends StatefulWidget {
  const SignupSindico({Key? key}) : super(key: key);

  @override
  _SignupSindicoPageState createState() => _SignupSindicoPageState();
}

class _SignupSindicoPageState extends State<SignupSindico> {
  dynamic _imageFile; // XFile no web, File no mobile
  var _isLoading = false;

  final _txtNome = TextEditingController();
  final _txtDocumento = TextEditingController();
  final _txtDN = TextEditingController();
  final _txtEmail = TextEditingController();
  final _txtTelefone = TextEditingController();
  final _txtPassword = TextEditingController();

  @override
  void dispose() {
    _txtNome.dispose();
    _txtDocumento.dispose();
    _txtDN.dispose();
    _txtEmail.dispose();
    _txtTelefone.dispose();
    _txtPassword.dispose();
    super.dispose();
  }

  Future<void> _selectPhoto() async {
    final res = await getPhoto(context);
    if (res == null) return;
    setState(() => _imageFile = res);
  }

  ImageProvider _getAvatarImage() {
    if (_imageFile == null) return const AssetImage('assets/images/defaultUser.png');
    if (kIsWeb) return NetworkImage(_imageFile.path);
    return FileImage(File(_imageFile.path));
  }

  Future<void> _signup() async {
    if (_isLoading) return;
    if (!validateDate(_txtDN.text)) {
      displayMessage(context, getText('alert_error'), getText('signup_erro_dt_nascimento'));
      return;
    }

    setState(() => _isLoading = true);

    String? base64;
    if (_imageFile != null) {
      final bytes = await _imageFile.readAsBytes();
      base64 = "data:image/png;base64," + base64Encode(bytes);
    }

    final message = await signupSindico(
      _txtNome.text, _txtDocumento.text, _txtDN.text,
      _txtEmail.text.trim(), _txtTelefone.text, _txtPassword.text, base64,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (message == "") {
      await displayMessage(context, getText('alert_success'), getText('signup_success'));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ListCondomiums()));
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
            color: const Color.fromRGBO(0, 149, 218, 1),
            child: Column(
              children: [
                NavigationDefault(title: getText('signup_nav_sindico')),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                      decoration: BoxMainRounded(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: _selectPhoto,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 55,
                                  backgroundImage: _getAvatarImage(),
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Icon(MdiIcons.camera, color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFieldDefault(title: getText('user_nome_completo'), controller: _txtNome, textCapitalization: TextCapitalization.words),
                          const SizedBox(height: 10),
                          TextFieldDefault(title: getText('user_documento'), controller: _txtDocumento),
                          const SizedBox(height: 10),
                          TextFieldDefault(title: getText("data_nascimento"), keyboard: TextInputType.number, controller: _txtDN, mask: TextInputMask(mask: ['99/99/9999'], reverse: false)),
                          const SizedBox(height: 10),
                          TextFieldDefault(title: getText("email"), controller: _txtEmail, keyboard: TextInputType.emailAddress),
                          const SizedBox(height: 10),
                          TextFieldDefault(title: getText("telefone"), keyboard: TextInputType.number, controller: _txtTelefone),
                          const SizedBox(height: 10),
                          TextFieldDefault(title: getText("senha"), isPassword: true, controller: _txtPassword),
                          const SizedBox(height: 20),
                          DefaultButton(
                            title: getText('btn_enviar'),
                            hasArrow: false,
                            onPressed: _isLoading ? null : _signup,
                          ),
                          const SizedBox(height: 20),
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
              child: Loader(loadingTxt: '', opacity: 0.7, color: Colors.black, dismissibles: false),
            ),
        ],
      ),
    );
  }
}
