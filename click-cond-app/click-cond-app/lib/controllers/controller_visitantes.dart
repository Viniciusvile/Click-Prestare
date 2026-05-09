import 'dart:convert';
import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:http/http.dart' as http;

import 'package:click/utils/api_config.dart';


apiGetAllVisitantes(String search) async {
  var url = ApiConfig.buildUri('/visitantes/get-all',
              {'id_condominio': Singleton.instance.id_condominio.toString(), 
              'offset':'0', 
              'id_apto': Singleton.instance.getIdApartamento(),
              'search': search
              });
  try{
      var response = await http.get(
        url,
        headers: { "Authorization": getToken() }
      );

    if (response.statusCode == 200) {
      var parsed = jsonDecode(response.body);
      return parsed == "" ? [] : parsed;
    } else {
      return [];
    }
  }catch(e){
    return "Houve um erro, tente novamente!";
  }
}
