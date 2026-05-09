import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

/// Controlador de tema do app.
///
/// Modos disponíveis:
/// - `system` — segue o tema do dispositivo
/// - `light`  — sempre claro
/// - `dark`   — sempre escuro
///
/// O modo é persistido em LocalStorage.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _key = 'theme_mode';
  final _storage = LocalStorage('user_config');

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> init() async {
    await _storage.ready;
    final saved = _storage.getItem(_key) as String?;
    if (saved == 'light') {
      _mode = ThemeMode.light;
    } else if (saved == 'dark') {
      _mode = ThemeMode.dark;
    } else {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final str = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    _storage.setItem(_key, str);
    notifyListeners();
  }

  String get label {
    switch (_mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}
