import 'package:click/pages/perfil_choice.dart';
import 'package:flutter/material.dart';

class RouterGenerator {
  static Route<dynamic> generateRouter(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: RouteSettings(name: "/"),
          builder: (_) => HomePage(),
        );
      default:
        return MaterialPageRoute(
          settings: RouteSettings(name: "/"),
          builder: (_) => HomePage(),
        );
    }
  }
}
