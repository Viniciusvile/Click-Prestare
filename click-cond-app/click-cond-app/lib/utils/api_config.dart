import 'package:flutter/foundation.dart';

/// Configuração centralizada da API.
class ApiConfig {
  /// Host dinâmico: localhost para Web/Desktop, 10.0.2.2 para Emulador Android.
  static String get host {
    if (kIsWeb) return "localhost:3003";
    // Para testar em um aparelho físico, usamos o IP do seu computador na rede
    return "192.168.3.74:3003";
  }

  /// true para HTTPS (produção), false para HTTP (localhost)
  static const bool useHttps = false;

  /// Timeout padrão de requisições HTTP
  static const Duration timeout = Duration(seconds: 30);

  /// Constrói uma Uri completa para o endpoint.
  static Uri buildUri(String path, [Map<String, String>? params]) {
    return useHttps
        ? Uri.https(host, path, params)
        : Uri.http(host, path, params);
  }
}
