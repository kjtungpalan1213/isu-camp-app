import 'package:isu_camp_app/features/auth/domain/auth_repository.dart';
import 'package:isu_camp_app/features/auth/domain/auth_result.dart';
import 'package:isu_camp_app/features/auth/domain/auth_session.dart';

class _Account {
  final String password;
  final String displayName;

  const _Account({required this.password, required this.displayName});
}

class FakeAuthRepository implements AuthRepository {
  final Map<String, _Account> _accounts = {};

  String _emailFor(String username) => '$username@example.com';

  @override
  Future<AuthResult<AuthSession>> register({
    required String username,
    required String password,
  }) async {
    if (_accounts.containsKey(username)) {
      return const AuthResult.failure(AuthFailure.usernameTaken);
    }
    final session = AuthSession(displayName: username);
    _accounts[username] =
        _Account(password: password, displayName: username);
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
    final known = _accounts.values.any(
      (account) => _emailFor(account.displayName) == email,
    );
    if (!known) {
      return const AuthResult.failure(AuthFailure.unknownAccount);
    }
    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<void>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final isSixDigits =
        code.length == 6 && RegExp(r'^[0-9]+$').hasMatch(code);
    if (!isSixDigits) {
      return const AuthResult.failure(AuthFailure.invalidCode);
    }
    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<void>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final username = _accounts.keys.firstWhere(
      (key) => _emailFor(key) == email,
      orElse: () => '',
    );
    final account = _accounts[username];
    if (username.isEmpty || account == null) {
      return const AuthResult.failure(AuthFailure.unknownAccount);
    }
    _accounts[username] =
        _Account(password: newPassword, displayName: account.displayName);
    return const AuthResult.success(null);
  }
}
