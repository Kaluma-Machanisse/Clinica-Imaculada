import 'package:logging/logging.dart';

import '../database/app_database.dart';
import '../database/daos/audit_dao.dart';
import '../database/daos/users_dao.dart';
import 'password_hasher.dart';
import 'session.dart';
import 'user_role.dart';

/// Resultado de uma tentativa de início de sessão.
sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  const LoginSuccess(this.session);
  final AppSession session;
}

class LoginFailure extends LoginResult {
  const LoginFailure(this.message);
  final String message;
}

class LoginLocked extends LoginResult {
  const LoginLocked(this.until);
  final DateTime until;
}

/// Autenticação local (offline). Sem serviços externos.
class AuthService {
  AuthService({
    required UsersDao usersDao,
    required AuditDao auditDao,
    this._hasher = const PasswordHasher(),
  })  : _users = usersDao,
        _audit = auditDao;

  final UsersDao _users;
  final AuditDao _audit;
  final PasswordHasher _hasher;
  final _log = Logger('AuthService');

  /// Nº de tentativas falhadas antes de bloquear temporariamente.
  static const int lockThreshold = 5;

  /// Duração do bloqueio após atingir o limite.
  static const Duration lockDuration = Duration(minutes: 5);

  /// Se ainda não existe nenhum utilizador (primeiro arranque).
  Future<bool> hasAnyUser() async => (await _users.countAll()) > 0;

  Future<LoginResult> login(String username, String password) async {
    final user = await _users.findByUsername(username);

    if (user == null || !user.isActive || user.isDeleted) {
      await _audit.record(
        username: username.trim(),
        action: 'login_failed',
        details: 'utilizador inexistente ou inativo',
      );
      // Mensagem genérica: não revela se o utilizador existe.
      return const LoginFailure('Utilizador ou senha inválidos.');
    }

    final now = DateTime.now();
    if (user.lockedUntil != null && user.lockedUntil!.isAfter(now)) {
      return LoginLocked(user.lockedUntil!);
    }

    final ok = await _hasher.verify(password, user.passwordHash);
    if (!ok) {
      final attempts = user.failedAttempts + 1;
      final shouldLock = attempts >= lockThreshold;
      await _users.markLoginFailure(
        user.id,
        newFailedCount: shouldLock ? 0 : attempts,
        lockedUntil: shouldLock ? now.add(lockDuration) : null,
      );
      await _audit.record(
        userId: user.id,
        username: user.username,
        action: 'login_failed',
        details: 'senha incorreta (tentativa $attempts)',
      );
      if (shouldLock) {
        return LoginLocked(now.add(lockDuration));
      }
      return const LoginFailure('Utilizador ou senha inválidos.');
    }

    await _users.markLoginSuccess(user.id);
    await _audit.record(
      userId: user.id,
      username: user.username,
      action: 'login',
    );

    final session = AppSession(
      userId: user.id,
      username: user.username,
      fullName: user.fullName,
      role: UserRole.fromName(user.role),
      loginAt: now,
    );
    _log.info('Sessão iniciada: ${user.username} (${user.role})');
    return LoginSuccess(session);
  }

  Future<void> logout(AppSession session) async {
    await _audit.record(
      userId: session.userId,
      username: session.username,
      action: 'logout',
    );
    _log.info('Sessão terminada: ${session.username}');
  }

  /// Cria um novo utilizador. Usado no arranque inicial (criar admin) e,
  /// mais tarde, no módulo de administração.
  ///
  /// Lança [ArgumentError] se a senha não cumprir a política ou se o nome de
  /// utilizador já existir.
  Future<void> createUser({
    required String fullName,
    required String username,
    required String password,
    required UserRole role,
    AppSession? actor,
  }) async {
    final policyError = PasswordPolicy.validate(password);
    if (policyError != null) {
      throw ArgumentError(policyError);
    }
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.length < 3) {
      throw ArgumentError('O nome de utilizador deve ter pelo menos 3 caracteres.');
    }
    final existing = await _users.findByUsername(normalizedUsername);
    if (existing != null) {
      throw ArgumentError('Já existe um utilizador com esse nome.');
    }

    final hash = await _hasher.hash(password);
    final entry = UsersCompanion.insert(
      fullName: fullName.trim(),
      username: normalizedUsername,
      passwordHash: hash,
      role: role.name,
    );
    await _users.insertUser(entry);

    await _audit.record(
      userId: actor?.userId,
      username: actor?.username,
      action: 'create',
      entity: 'user',
      details: 'novo utilizador "$normalizedUsername" (${role.name})',
    );
  }
}
