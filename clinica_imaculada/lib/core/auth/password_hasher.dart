import 'dart:isolate';

import 'package:bcrypt/bcrypt.dart';

/// Hashing de senhas com bcrypt.
///
/// bcrypt é propositadamente lento (resistente a força bruta). Por isso, as
/// operações correm num isolate à parte para não bloquear a interface.
class PasswordHasher {
  const PasswordHasher({this.logRounds = 12});

  /// Fator de custo (2^logRounds iterações). 12 é um bom equilíbrio em 2025.
  final int logRounds;

  Future<String> hash(String plain) {
    final rounds = logRounds;
    return Isolate.run(() => BCrypt.hashpw(plain, BCrypt.gensalt(logRounds: rounds)));
  }

  Future<bool> verify(String plain, String hash) {
    return Isolate.run(() => BCrypt.checkpw(plain, hash));
  }
}

/// Regras mínimas de força da senha.
class PasswordPolicy {
  const PasswordPolicy._();

  static const int minLength = 8;

  /// Devolve `null` se a senha for aceitável, ou a razão da recusa.
  static String? validate(String password) {
    if (password.length < minLength) {
      return 'A senha deve ter pelo menos $minLength caracteres.';
    }
    final hasLetter = password.contains(RegExp(r'[A-Za-zÀ-ÿ]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    if (!hasLetter || !hasDigit) {
      return 'A senha deve conter letras e números.';
    }
    return null;
  }
}
