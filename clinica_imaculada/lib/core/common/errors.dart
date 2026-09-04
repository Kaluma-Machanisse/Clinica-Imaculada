/// Erro lançado quando o perfil com sessão iniciada não tem acesso a uma
/// operação. Apanhado na interface para mostrar uma mensagem clara.
class AccessDeniedException implements Exception {
  const AccessDeniedException([this.message = 'Sem permissão para esta ação.']);
  final String message;

  @override
  String toString() => 'AccessDeniedException: $message';
}

/// Erro de validação de dados de negócio (ex.: campo obrigatório em falta).
class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
