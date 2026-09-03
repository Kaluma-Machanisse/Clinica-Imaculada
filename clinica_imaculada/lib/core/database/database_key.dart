import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gere a chave de cifra da base de dados local (SQLCipher / AES-256).
///
/// A chave é uma sequência aleatória de 32 bytes, gerada uma única vez no
/// primeiro arranque e guardada no cofre seguro do sistema operativo
/// (no Windows, protegida por DPAPI, ligada à conta Windows do utilizador).
///
/// O ficheiro `.db` fica cifrado em disco; sem esta chave é ilegível.
class DatabaseKey {
  DatabaseKey({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _storageKey = 'db_encryption_key_v1';

  /// Opções do cofre seguro. No Windows usa o backend por omissão (DPAPI).
  static const _linuxOptions = LinuxOptions();
  static const _windowsOptions = WindowsOptions();

  /// Devolve a chave existente ou cria uma nova se ainda não existir.
  ///
  /// A chave é devolvida em hexadecimal (64 caracteres), pronta para
  /// `PRAGMA key = "x'<hex>'"`.
  Future<String> getOrCreate() async {
    final existing = await _storage.read(
      key: _storageKey,
      lOptions: _linuxOptions,
      wOptions: _windowsOptions,
    );
    if (existing != null && existing.length == 64) {
      return existing;
    }

    final key = _generateHexKey();
    await _storage.write(
      key: _storageKey,
      value: key,
      lOptions: _linuxOptions,
      wOptions: _windowsOptions,
    );
    return key;
  }

  /// Apenas para testes / reposição: apaga a chave guardada.
  Future<void> delete() => _storage.delete(
        key: _storageKey,
        lOptions: _linuxOptions,
        wOptions: _windowsOptions,
      );

  static String _generateHexKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return _toHex(bytes);
  }

  static String _toHex(List<int> bytes) {
    const digits = '0123456789abcdef';
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(digits[(b >> 4) & 0xf]);
      buffer.write(digits[b & 0xf]);
    }
    return buffer.toString();
  }
}

/// Ajuda a construir o valor do `PRAGMA key` a partir da chave hex.
///
/// O formato `x'<hex>'` diz ao SQLCipher para usar os bytes diretamente como
/// chave em vez de os derivar com KDF a partir de uma frase-passe.
String pragmaKeyLiteral(String hexKey) => "x'$hexKey'";
