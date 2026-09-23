import 'package:flutter_test/flutter_test.dart';
import 'package:isu_camp_app/features/auth/services/verification_security_controller.dart';

void main() {
  testWidgets('OTP challenge expires using an absolute deadline',
      (tester) async {
    var now = DateTime(2026);
    VerificationTimeoutReason? timeoutReason;
    final controller = VerificationSecurityController(
      now: () => now,
      codeLifetime: const Duration(seconds: 2),
      inactivityDuration: const Duration(seconds: 20),
      onTimeout: (reason) => timeoutReason = reason,
    );

    controller.startOtpChallenge();
    now = now.add(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));

    expect(timeoutReason, VerificationTimeoutReason.codeExpired);
    expect(controller.stage, VerificationStage.expired);
    controller.dispose();
  });

  testWidgets('user activity resets only the inactivity deadline',
      (tester) async {
    var now = DateTime(2026);
    VerificationTimeoutReason? timeoutReason;
    final controller = VerificationSecurityController(
      now: () => now,
      codeLifetime: const Duration(seconds: 20),
      inactivityDuration: const Duration(seconds: 2),
      inactivityWarning: const Duration(seconds: 1),
      onTimeout: (reason) => timeoutReason = reason,
    );

    controller.startOtpChallenge();
    final originalCodeExpiry = controller.codeExpiresAt;
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    controller.recordActivity();
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(timeoutReason, isNull);
    expect(controller.codeExpiresAt, originalCodeExpiry);

    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(timeoutReason, VerificationTimeoutReason.inactivity);
    controller.dispose();
  });

  testWidgets('attempt and resend limits enter their lockout states',
      (tester) async {
    final now = DateTime(2026);
    final controller = VerificationSecurityController(
      now: () => now,
      maximumAttempts: 2,
      maximumResends: 2,
      resendCooldown: Duration.zero,
      onTimeout: (_) {},
    );

    controller.startOtpChallenge();
    controller.recordIncorrectAttempt();
    expect(controller.attemptsRemaining, 1);
    controller.recordIncorrectAttempt();
    expect(controller.attemptsRemaining, 0);
    expect(controller.isVerificationLocked, isTrue);

    controller.recordResend();
    controller.recordResend();
    expect(controller.isResendLocked, isTrue);
    controller.dispose();
  });
}
