import 'dart:convert';
import 'dart:io';

import 'package:click/pages/sindico/signup/signup_%20condominium_2.dart';
import 'package:click/utils/localizable/localizable.dart';
import 'package:click/utils/utils.dart';
import 'package:click/widgets/buttons/default_button_normal.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:click/widgets/textfields/textfield_default.dart';
import 'package:click/widgets/navigation/navigation.dart';
import 'package:click/widgets/containers/box_main_rounded.dart';
import 'package:click/widgets/label/label_title.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignupCondominuim1 extends StatefulWidget {
  const SignupCondominuim1({Key? key}) : super(key: key);

  @override
  _SignupCondominuim1PageState createState() => _SignupCondominuim1PageState();
}

class _SignupCondominuim1PageState extends State<SignupCondominuim1> {
  dynamic _imageFile;
  final _txtNome = TextEditingController();
  final _txtDocumento = TextEditingController();
  final _txtSubsindico = TextEditingController();
  final _txtInicioMandato = TextEditingController();
  final _txtTerminoMandato = TextEditingController();

  @override
  void dispose() {
    _txtNome.dispose();
    _txtDocumento.dispose();
    _txtSubsindico.dispose();
    _txtInicioMandato.dispose();
    _txtTerminoMandato.dispose();
    super.dispose();
  }

  Future<void> _selectPhoto() async {
    final res = await getPhoto(context);
    if (res == null) return;
    setState(() => _imageFile = res);
  }

  ImageProvider _getAvatarImage() {
    if (_imageFile == null) return const AssetImage('assets/images/business_default.png');
    if (kIsWeb) return NetworkImage(_imageFile.path);
    return FileImage(File(_imageFile.path));
  }

  Future<void> _nextPage() async {
    var err = "";
    err += validateFieldIsEmpty(_txtNome.text, getText('signup_cond_error_nome'));
    err += validateFieldIsEmpty(_txtDocumento.text, getText('signup_cond_error_doc'));
    err += validateFieldIsEmpty(_txtSubsindico.text, getText('signup_cond_error_subsindico'));
    if (!validateGenericDate(_txtInicioMandato.text)) err += "${getText('signup_cond_error_dt_inicio_mandato')}\n";
    if (!validateGenericDate(_txtTerminoMandato.text)) err += "${getText('signup_cond_error_dt_fim_mandato')}\n";
    if (!dateIsAfter(_txtInicioMandato.text, _txtTerminoMandato.text)) err += "${getText('signup_cond_error_dt_anterior')}\n";

    if (err.isNotEmpty) {
      displayMessage(context, getText('alert_error'), err);
      return;
    }

    final condominio = CondominioRegister(
      nome: _txtNome.text.trim(),
      documento: _txtDocumento.text.trim(),
      subsindico: _txtSubsindico.text.trim(),
      inicioMandato: _txtInicioMandato.text.trim(),
      terminoMandato: _txtTerminoMandato.text.trim(),
      photo: _imageFile?.path,
    );

    if (_imageFile != null) {
      final bytes = await _imageFile.readAsBytes();
      condominio.photoBase64 = "data:image/png;base64," + base64Encode(bytes);
    }

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => SignupCondominuim2(condominio: condominio)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: const Color.fromRGBO(0, 149, 218, 1),
        child: Column(
          children: [
            NavigationDefault(title: getText('signup_cond_nav')),
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                  decoration: BoxMainRounded(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: InkWell(
                          onTap: _selectPhoto,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
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
                      ),
                      const SizedBox(height: 10),
                      TextFieldDefault(title: getText('signup_cond_nome'), controller: _txtNome),
                      const SizedBox(height: 10),
                      TextFieldDefault(title: getText('user_documento'), controller: _txtDocumento),
                      const SizedBox(height: 10),
                      TextFieldDefault(title: getText('signup_cond_subsindico_nome'), controller: _txtSubsindico),
                      const SizedBox(height: 10),
                      TextFieldDefault(title: getText('signup_cond_ini_mandato'), keyboard: TextInputType.number, controller: _txtInicioMandato, mask: TextInputMask(mask: ['99/99/9999'], reverse: false)),
                      const SizedBox(height: 10),
                      TextFieldDefault(title: getText('signup_cond_fim_mandato'), keyboard: TextInputType.number, controller: _txtTerminoMandato, mask: TextInputMask(mask: ['99/99/9999'], reverse: false)),
                      const SizedBox(height: 20),
                      LabelTitle(title: "1 ${getText('label_of')} 3", size: 19),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                          minHeight: 10,
                          value: 0.33,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DefaultButtonNormal(
                        title: getText('btn_proximo'),
                        hasArrow: false,
                        onPressed: _nextPage,
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
    );
  }
}

class CondominioRegister {
  String? nome;
  String? documento;
  String? subsindico;
  String? inicioMandato;
  String? terminoMandato;
  String? photo;
  String? photoBase64;

  String? cep;
  String? pais;
  String? uf;
  String? bairro;
  String? cidade;
  String? rua;
  String? numero;
  String? complemento;

  int? blocos;
  int? aptos;

  CondominioRegister({
    this.nome,
    this.documento,
    this.subsindico,
    this.inicioMandato,
    this.terminoMandato,
    this.photo,
    this.photoBase64,
  });
}
