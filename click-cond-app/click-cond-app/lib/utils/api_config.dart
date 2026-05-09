/// Configuração centralizada da API.
/// Para trocar de servidor, altere apenas as constantes deste arquivo.
class ApiConfig {
  /// Host (sem protocolo, sem barra final)
  static const String host = "localhost:3003";

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
