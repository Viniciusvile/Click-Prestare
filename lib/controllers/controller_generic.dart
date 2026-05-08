import 'dart:convert';
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

apiSaveObject(String route, String nameObj, dynamic obj, bool isEdit) async {
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
    if (response.statusCode == 200) return "";
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    throw parsed["message"] ?? "Erro desconhecido";
  } catch (e) {
    throw e;
  }
}

apiDeleteObject(String route, int idObj) async {
  final url = _buildUri('/$route/remove');
  final body = json.encode({"id": idObj});
  try {
    final response = await http
        .post(url, headers: _authHeaders(withContentType: true), body: body)
        .timeout(_kTimeout);
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

apiGetAll(String route) async {
  final url = _buildUri('/$route/get-all', {
    'id_condominio': Singleton.instance.id_condominio.toString(),
    'offset': '0',
    'id_apto': Singleton.instance.getIdApartamento(),
  });
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

apiGetDetails(String route, int idItem) async {
  final url = _buildUri('/$route/get', {
    'id_condominio': Singleton.instance.id_condominio.toString(),
    'id': idItem.toString(),
  });
  try {
    final response = await http
        .get(url, headers: _authHeaders())
        .timeout(_kTimeout);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    return null;
  }
}

apiGetAllDocs(String route, int isAta) async {
  final url = _buildUri('/$route/get-all', {
    'id_condominio': Singleton.instance.id_condominio.toString(),
    'is_ata': isAta.toString(),
  });
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

apiUpdateStatus(String route, int idItem, bool status, String motivo) async {
  final url = _buildUri('/$route/update-status');
  final body = json.encode({
    "id": idItem,
    "isAccept": status,
    "motivo_recusa": motivo,
    "id_condominio": Singleton.instance.id_condominio.toString(),
  });
  try {
    final response = await http
        .post(url, headers: _authHeaders(withContentType: true), body: body)
        .timeout(_kTimeout);
    if (response.statusCode == 200) return "";
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    throw parsed["message"] ?? "Erro desconhecido";
  } catch (e) {
    throw e;
  }
}

apiUpdateStatusOcorrManut(String route, int idItem, String status) async {
  final url = _buildUri('/$route/update-status');
  final body = json.encode({
    "id": idItem,
    "status": status,
    "id_condominio": Singleton.instance.id_condominio.toString(),
  });
  try {
    final response = await http
        .post(url, headers: _authHeaders(withContentType: true), body: body)
        .timeout(_kTimeout);
    if (response.statusCode == 200) return "";
    final parsed = jsonDecode(response.body) as Map<String, dynamic>;
    throw parsed["message"] ?? "Erro desconhecido";
  } catch (e) {
    throw e;
  }
}
