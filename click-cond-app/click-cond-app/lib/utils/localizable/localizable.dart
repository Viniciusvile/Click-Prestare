
import 'dart:ui';

import 'package:click/utils/localizable/localizable_al.dart';
import 'package:click/utils/localizable/localizable_en_us.dart';
import 'package:click/utils/localizable/localizable_es.dart';
import 'package:click/utils/localizable/localizable_pt_br.dart';
import 'package:click/utils/localizable/localizable_pt_pt.dart';
import 'package:click/utils/localstorage_config.dart';
import 'package:flutter/material.dart';

String getText(String key) {
  try{
    var file;
    switch (LocalStorageConfig.instance.getPreferenceLanguage()) {
      case 'pt_BR':
        file = Localizable_PtBr();
        break;
      case 'en': 
        file = Localizable_EnUs();
        break;
      case 'es': 
        file = Localizable_Es();
        break;
      case 'pt_PT':
        file = Localizable_PtPt();
        break;
      case 'de':
        file = Localizable_Al();
        break;
      default:
        file = Localizable_PtBr();
        break;
    }

    var item = file.strings.where((element) => element.key == key).first;
    return item.text;
  }catch(e){
    return '';
  }    
}

Locale getCurrentLocale(){
  try{
    switch (LocalStorageConfig.instance.getPreferenceLanguage()) {
      case 'pt_BR':
        return Locale("pt", "BR");
      case 'en': 
        return Locale("en", "US");
      case 'es': 
        return Locale("es", "ES");
      case 'pt_PT':
        return Locale("pt", "PT");
      case 'de':
        return Locale("de", "DE");
      default:
        return Locale("pt", "BR");
    }
  }catch(e){
    return Locale("pt", "BR");
  }   
}

class LocalizableModel{
  String key;
  String text;

  LocalizableModel({
    required this.key,
    required this.text,
  });
}
