import 'package:isu_camp_app/features/auth/domain/auth_result.dart';
import 'package:isu_camp_app/features/auth/domain/auth_session.dart';

abstract class AuthRepository {
  Future<AuthResult<AuthSession>> register({
    required String username,
    required String password,
  });

  Future<AuthResult<AuthSession>> login({
    required String username,
    required String password,
  });

  Future<AuthResult<void>> requestPasswordReset({required String email});

  Future<AuthResult<void>> verifyResetCode({
    required String email,
    required String code,
  });

  Future<AuthResult<void>> resetPassword({
    required String email,
    required String newPassword,
  });
}
