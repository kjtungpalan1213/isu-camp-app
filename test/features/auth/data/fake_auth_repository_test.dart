import 'package:flutter_test/flutter_test.dart';
import 'package:isu_camp_app/features/auth/data/fake_auth_repository.dart';
import 'package:isu_camp_app/features/auth/domain/auth_repository.dart';
import 'package:isu_camp_app/features/auth/domain/auth_result.dart';

void main() {
  late AuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
  });

  test('register then login round-trip succeeds', () async {
    final registration = await repository.register(
      username: 'justine',
      password: 'campus123',
      email: 'justine@example.com',
    );
    expect(registration.isSuccess, isTrue);
    expect(registration.value?.displayName, isNotEmpty);

    final session =
        await repository.login(username: 'justine', password: 'campus123');
    expect(session.isSuccess, isTrue);
    expect(session.value?.displayName, registration.value?.displayName);
  });

  test('duplicate registration is rejected', () async {
    await repository.register(
      username: 'justine',
      password: 'campus123',
      email: 'justine@example.com',
    );
    final second = await repository.register(
      username: 'justine',
      password: 'other123',
      email: 'justine@example.com',
    );
    expect(second.isSuccess, isFalse);
    expect(second.failure, AuthFailure.usernameTaken);
  });

  test('login with unknown username is rejected', () async {
    final session =
        await repository.login(username: 'stranger', password: 'campus123');
    expect(session.isSuccess, isFalse);
    expect(session.failure, AuthFailure.invalidCredentials);
    expect(session.value, isNull);
  });

  test('login with wrong password is rejected', () async {
    await repository.register(
      username: 'justine',
      password: 'campus123',
      email: 'justine@example.com',
    );
    final wrong =
        await repository.login(username: 'justine', password: 'nope');
    expect(wrong.isSuccess, isFalse);
    expect(wrong.failure, AuthFailure.invalidCredentials);

    final right =
        await repository.login(username: 'justine', password: 'campus123');
    expect(right.isSuccess, isTrue);
  });

  test('password reset end-to-end updates stored password', () async {
    await repository.register(
      username: 'justine',
      password: 'campus123',
      email: 'justine@example.com',
    );

    final request = await repository.requestPasswordReset(
        email: 'justine@example.com');
    expect(request.isSuccess, isTrue);

    final verify = await repository.verifyResetCode(
        email: 'justine@example.com', code: '123456');
    expect(verify.isSuccess, isTrue);

    final reset = await repository.resetPassword(
        email: 'justine@example.com', newPassword: 'freshPass1');
    expect(reset.isSuccess, isTrue);

    final oldLogin =
        await repository.login(username: 'justine', password: 'campus123');
    expect(oldLogin.isSuccess, isFalse);

    final newLogin =
        await repository.login(username: 'justine', password: 'freshPass1');
    expect(newLogin.isSuccess, isTrue);
  });

  test('verification code of wrong length is rejected', () async {
    await repository.register(
      username: 'justine',
      password: 'campus123',
      email: 'justine@example.com',
    );
    await repository.requestPasswordReset(email: 'justine@example.com');

    for (final badCode in ['12345', '1234567', '12a456']) {
      final verify = await repository.verifyResetCode(
          email: 'justine@example.com', code: badCode);
      expect(verify.failure, AuthFailure.invalidCode);
    }

    final stillWorks = await repository.verifyResetCode(
        email: 'justine@example.com', code: '654321');
    expect(stillWorks.isSuccess, isTrue);
  });

  test('verification code without a prior request is rejected', () async {
    await repository.register(
      username: 'justine',
      password: 'campus123',
      email: 'justine@example.com',
    );

    final verify = await repository.verifyResetCode(
        email: 'justine@example.com', code: '123456');
    expect(verify.isSuccess, isFalse);

    final reset = await repository.resetPassword(
        email: 'justine@example.com', newPassword: 'freshPass1');
    expect(reset.isSuccess, isFalse);
  });

  test('verification code for unknown account is rejected', () async {
    await repository.register(
      username: 'justine',
      password: 'campus123',
      email: 'justine@example.com',
    );
    await repository.requestPasswordReset(email: 'justine@example.com');

    final verify = await repository.verifyResetCode(
        email: 'ghost@example.com', code: '123456');
    expect(verify.failure, AuthFailure.unknownAccount);
  });

  test('reset against unknown account is rejected', () async {
    final request =
        await repository.requestPasswordReset(email: 'ghost@example.com');
    expect(request.isSuccess, isFalse);
    expect(request.failure, AuthFailure.unknownAccount);

    final reset = await repository.resetPassword(
        email: 'ghost@example.com', newPassword: 'whatever1');
    expect(reset.isSuccess, isFalse);
    expect(reset.failure, AuthFailure.unknownAccount);
  });

  test('operations complete asynchronously and are awaitable', () async {
    final pending = repository.register(
      username: 'async',
      password: 'pass123',
      email: 'async@example.com',
    );
    expect(pending, isA<Future>());
    final result = await pending;
    expect(result.isSuccess, isTrue);
  });
}
