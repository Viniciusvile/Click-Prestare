import 'dart:io';

import 'package:click/pages/singleton.dart';
import 'package:click/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:localstorage/localstorage.dart';

class LocalStorageConfig {
  static final LocalStorageConfig _singleton = LocalStorageConfig._internal();
  LocalStorageConfig._internal();
  static LocalStorageConfig get instance => _singleton;

  final _configStorage = LocalStorage('user_config');

  /// Aguarda ambos os storages estarem prontos antes de usar qualquer dado
  Future<void> initializeLocalStorage() async {
    await Future.wait([
      _configStorage.ready,
      ensureStorageReady(), // aguarda o storage de user_data (local_storage.dart)
    ]);
  }

  savePreferenceLanguage(String language) {
    _configStorage.setItem('languageCode', language);
    Singleton.instance.mainView?.update();
  }

  String getPreferenceLanguage() {
    final code = _configStorage.getItem('languageCode');
    if (code != null && code.toString().isNotEmpty) {
      return code.toString();
    }
    try {
      switch (Platform.localeName) {
        case 'pt_BR': return "pt_BR";
        case 'en_US': return 'en_US';
        case 'pt_PT': return 'pt_PT';
        case 'de':    return 'de';
        default:      return 'pt_BR';
      }
    } catch (e) {
      return 'pt_BR';
    }
  }

  savePreferenceBrightness(String? brightness) {
    _configStorage.setItem('brightness', brightness);
  }

  bool getPreferenceIsLightMode() {
    final saved = _configStorage.getItem('brightness');
    if (saved != null) return saved == "light";
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness != Brightness.dark;
  }

  String? getPreferenceBrightnessToBottomSheet() {
    return _configStorage.getItem('brightness');
  }

  savePreferenceHomeView(String preference) {
    _configStorage.setItem('homeView', preference);
  }

  bool getPreferenceHomeViewIsList() {
    final saved = _configStorage.getItem('homeView');
    return saved == null ? true : saved == "list";
  }
}
