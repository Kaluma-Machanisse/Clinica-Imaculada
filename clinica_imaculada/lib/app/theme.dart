import 'package:flutter/material.dart';

/// Tema da aplicação. Cor base provisória (verde clínico); pode ser ajustada
/// quando existir identidade visual da clínica.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF00695C);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.comfortable,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
