import 'dart:convert';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:http/http.dart' as http;

import 'package:click/utils/api_config.dart';


apiGetAllFinanceiro(String route, String mes, String ano) async {
  var url = ApiConfig.buildUri('/'+route+'/get-all',{'id_condominio': Singleton.instance.id_condominio.toString(), 'mes':mes, 'ano':ano});
  try{
      var response = await http.get(
        url,
        headers: { "Authorization": getToken() }
      );

    if (response.statusCode == 200) {
      var parsed = jsonDecode(response.body);
      return parsed == "" ? {} : parsed;
    } else {
      var parsed = jsonDecode(response.body) as Map<String, dynamic>;
      return [];
    }
  }catch(e){
    print(e);
    return "Houve um erro, tente novamente!";
  }
}

apiGetDetailsInadimplente(String route, String bloco, String apto) async {
  var url = ApiConfig.buildUri('/'+route+'/get',{'id_condominio': Singleton.instance.id_condominio.toString(), 'bloco': bloco, 'apto': apto});
  try{
      var response = await http.get(
        url,
        headers: { "Authorization": getToken() }
      );

    if (response.statusCode == 200) {
      var parsed = jsonDecode(response.body) as List<dynamic>;
      return parsed;
    } else {
      return null;
    }
  }catch(e){
    return null;
  }
}

