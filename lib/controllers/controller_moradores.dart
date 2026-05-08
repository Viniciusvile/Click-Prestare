import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:http/http.dart' as http;

const _kBaseUrl = "localhost:3003";
const _kTimeout = Duration(seconds: 15);

Uri _buildUri(String path, [Map<String, String>? params]) =>
    Uri.http(_kBaseUrl, path, params);

Map<String, String> _authHeaders({bool withContentType = false}) {
  final headers = <String, String>{"Authorization": getToken()};
  if (withContentType) headers["Content-Type"] = "application/json";
  return headers;
}

apiSaveApto(String route, String nameObj, dynamic obj, bool isEdit) async {
  final endUri = isEdit ? 'update' : 'insert';
  final url = _buildUri('/$route/$endUri');
  final body = json.encode({
    "id_condominio": Singleton.instance.id_condominio.toString(),
    nameObj: obj,
  });
  try {
    final response = await http
        .post(url, headers: _authHeaders(withContentType: true), body: body)
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    throw parsed["message"] ?? "Houve um erro, tente novamente!";
  } catch (e) {
    throw e;
  }
}

apiGetAllMoradores(String tipo, String id_apto) async {
  final url = _buildUri('/apartamentos/get-moradores', {'id_apto': id_apto, 'tipo': tipo});
  try {
    final response = await http
        .get(url, headers: _authHeaders())
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      return (parsed == null || parsed == "") ? [] : parsed;
    }
    return [];
  } catch (e) {
    return "Houve um erro, tente novamente!";
  }
}

loginMorador(String login, String password) async {
  try {
    final url = _buildUri('/moradores/login');
    final body = json.encode({'login': login, 'password': password});
    final response = await http
        .post(url,
            headers: {"Content-Type": "application/json"}, body: body)
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      storageMorador(parsed);
      return "";
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    return parsed["message"] ?? "Houve um erro, tente novamente!";
  } catch (e) {
    return "Houve um erro, tente novamente!";
  }
}

getCondominiosMorador() async {
  final url = _buildUri('/moradores/list-condominios');
  try {
    final response = await http
        .get(url, headers: _authHeaders())
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  } catch (e) {
    return "Houve um erro, tente novamente!";
  }
}

updateMoradorApi(dynamic morador) async {
  final url = _buildUri('/moradores/update');
  final body = json.encode({
    "id_condominio": Singleton.instance.id_condominio.toString(),
    "morador": morador,
  });
  try {
    final response = await http
        .post(url, headers: _authHeaders(withContentType: true), body: body)
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      storageMorador(parsed);
      return "";
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    throw parsed["message"] ?? "Houve um erro, tente novamente!";
  } catch (e) {
    throw "Houve um erro, tente novamente!";
  }
}

updatePasswordMoradorApi(String senha) async {
  final url = _buildUri('/moradores/new-password');
  final body = json.encode({"senha": senha});
  try {
    final response = await http
        .post(url, headers: _authHeaders(withContentType: true), body: body)
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      storageMorador(parsed);
      return "";
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    throw parsed["message"] ?? "Houve um erro, tente novamente!";
  } catch (e) {
    throw "Houve um erro, tente novamente!";
  }
}

updateAsinaturaMoradorApi(
    String idCondominio, String plano, String codigo) async {
  final url = _buildUri('/moradores/update-assinatura');
  final body = json.encode({
    "assinatura": {
      "id_plano": plano,
      "codigo": codigo,
      "plataforma": kIsWeb ? "Web" : Platform.isAndroid ? "Android" : "iOS",
    }
  });
  try {
    final response = await http
        .post(url, headers: _authHeaders(withContentType: true), body: body)
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      Singleton.instance.dias_restantes_morador = parsed["dias_restantes"] ?? 10;
      Singleton.instance.vencimento_morador = parsed["vencimento_formatado"] ?? "";
      return;
    }
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    throw parsed["message"] ?? "Houve um erro, tente novamente!";
  } catch (e) {
    throw "Houve um erro, tente novamente!";
  }
}
