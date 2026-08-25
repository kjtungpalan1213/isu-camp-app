import 'package:isu_camp_app/features/auth/domain/auth_repository.dart';
import 'package:isu_camp_app/features/auth/domain/auth_result.dart';
import 'package:isu_camp_app/features/auth/domain/auth_session.dart';

class _Account {
  final String password;
  final String displayName;
  final String email;

  const _Account({
    required this.password,
    required this.displayName,
    required this.email,
  });
}

class FakeAuthRepository implements AuthRepository {
  final Map<String, _Account> _accounts = {};
  final Set<String> _pendingResets = {};

  @override
  Future<AuthResult<AuthSession>> register({
    required String username,
    required String password,
    required String email,
  }) async {
    if (_accounts.containsKey(username)) {
      return const AuthResult.failure(AuthFailure.usernameTaken);
    }
    final emailRegistered =
        _accounts.values.any((account) => account.email == email);
    if (emailRegistered) {
      return const AuthResult.failure(AuthFailure.emailTaken);
    }
    final session = AuthSession(displayName: username);
    _accounts[username] = _Account(
      password: password,
      displayName: username,
      email: email,
    );
    return AuthResult.success(session);
  }

  @override
  Future<AuthResult<AuthSession>> login({
    required String username,
    required String password,
  }) async {
    final account = _accounts[username];
    if (account == null || account.password != password) {
      return const AuthResult.failure(AuthFailure.invalidCredentials);
    }
    return AuthResult.success(AuthSession(displayName: account.displayName));
  }

  @override
  Future<AuthResult<void>> requestPasswordReset({required String email}) async {
    final known = _accounts.values.any((account) => account.email == email);
    if (!known) {
      return const AuthResult.failure(AuthFailure.unknownAccount);
    }
    _pendingResets.add(email);
    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<void>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final isSixDigits = code.length == 6 && RegExp(r'^[0-9]+$').hasMatch(code);
    if (!isSixDigits) {
      return const AuthResult.failure(AuthFailure.invalidCode);
    }
    if (!_pendingResets.contains(email)) {
      return const AuthResult.failure(AuthFailure.unknownAccount);
    }
    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<void>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    if (!_pendingResets.contains(email)) {
      return const AuthResult.failure(AuthFailure.unknownAccount);
    }
    final username = _accounts.keys.firstWhere(
      (key) => _accounts[key]!.email == email,
      orElse: () => '',
    );
    final account = _accounts[username];
    if (username.isEmpty || account == null) {
      return const AuthResult.failure(AuthFailure.unknownAccount);
    }
    _pendingResets.remove(email);
    _accounts[username] = _Account(
      password: newPassword,
      displayName: account.displayName,
      email: account.email,
    );
    return const AuthResult.success(null);
  }
}
