import 'dart:async';

import 'package:flutter/widgets.dart';

enum VerificationStage { idle, otp, passwordSetup, expired }

enum VerificationTimeoutReason { inactivity, codeExpired, setupExpired }

class VerificationSecurityController extends ChangeNotifier
    with WidgetsBindingObserver {
  VerificationSecurityController({
    required this.onTimeout,
    DateTime Function()? now,
    this.codeLifetime = const Duration(minutes: 5),
    this.resendCooldown = const Duration(minutes: 1),
    this.lockoutDuration = const Duration(minutes: 5),
    this.setupLifetime = const Duration(minutes: 10),
    this.inactivityDuration = const Duration(minutes: 3),
    this.inactivityWarning = const Duration(seconds: 30),
    this.maximumAttempts = 5,
    this.maximumResends = 5,
  }) : _now = now ?? DateTime.now;

  final ValueChanged<VerificationTimeoutReason> onTimeout;
  final Duration codeLifetime;
  final Duration resendCooldown;
  final Duration lockoutDuration;
  final Duration setupLifetime;
  final Duration inactivityDuration;
  final Duration inactivityWarning;
  final int maximumAttempts;
  final int maximumResends;
  final DateTime Function() _now;

  VerificationStage stage = VerificationStage.idle;
  int attemptsRemaining = 5;
  int resendCount = 0;
  DateTime? codeExpiresAt;
  DateTime? resendAvailableAt;
  DateTime? verificationLockedUntil;
  DateTime? resendLockedUntil;
  DateTime? setupExpiresAt;
  DateTime? lastActivityAt;

  Timer? _ticker;
  bool _timeoutDelivered = false;
  bool _isObservingLifecycle = false;

  bool get isOtpStage => stage == VerificationStage.otp;
  bool get isSetupStage => stage == VerificationStage.passwordSetup;
  bool get isVerificationLocked =>
      verificationLockedUntil != null &&
      _now().isBefore(verificationLockedUntil!);
  bool get isResendLocked =>
      resendLockedUntil != null && _now().isBefore(resendLockedUntil!);
  bool get canResend =>
      isOtpStage &&
      !isVerificationLocked &&
      !isResendLocked &&
      remaining(resendAvailableAt) == Duration.zero;
  bool get canVerify =>
      isOtpStage && !isVerificationLocked && codeRemaining > Duration.zero;

  Duration get codeRemaining => remaining(codeExpiresAt);
  Duration get resendRemaining => isResendLocked
      ? remaining(resendLockedUntil)
      : remaining(resendAvailableAt);
  Duration get verificationLockRemaining => remaining(verificationLockedUntil);
  Duration get setupRemaining => remaining(setupExpiresAt);
  Duration get inactivityRemaining {
    final lastActivity = lastActivityAt;
    if (lastActivity == null || stage == VerificationStage.idle) {
      return Duration.zero;
    }
    return remaining(lastActivity.add(inactivityDuration));
  }

  bool get showInactivityWarning =>
      stage != VerificationStage.idle &&
      stage != VerificationStage.expired &&
      inactivityRemaining > Duration.zero &&
      inactivityRemaining <= inactivityWarning;

  void startOtpChallenge() {
    final now = _now();
    stage = VerificationStage.otp;
    attemptsRemaining = maximumAttempts;
    resendCount = 0;
    codeExpiresAt = now.add(codeLifetime);
    resendAvailableAt = now.add(resendCooldown);
    verificationLockedUntil = null;
    resendLockedUntil = null;
    setupExpiresAt = null;
    lastActivityAt = now;
    _timeoutDelivered = false;
    _startTicker();
    notifyListeners();
  }

  void recordActivity() {
    if (stage == VerificationStage.idle || stage == VerificationStage.expired) {
      return;
    }
    lastActivityAt = _now();
    notifyListeners();
  }

  void recordIncorrectAttempt({int? serverRemaining}) {
    attemptsRemaining = serverRemaining ?? attemptsRemaining - 1;
    if (attemptsRemaining <= 0) {
      attemptsRemaining = 0;
      verificationLockedUntil = _now().add(lockoutDuration);
    }
    recordActivity();
  }

  void recordResend() {
    final now = _now();
    resendCount += 1;
    codeExpiresAt = now.add(codeLifetime);
    resendAvailableAt = now.add(resendCooldown);
    if (resendCount >= maximumResends) {
      resendLockedUntil = now.add(lockoutDuration);
    }
    recordActivity();
  }

  void beginPasswordSetup() {
    final now = _now();
    stage = VerificationStage.passwordSetup;
    setupExpiresAt = now.add(setupLifetime);
    lastActivityAt = now;
    _timeoutDelivered = false;
    notifyListeners();
  }

  void cancel() {
    stage = VerificationStage.idle;
    _ticker?.cancel();
    _ticker = null;
    codeExpiresAt = null;
    resendAvailableAt = null;
    verificationLockedUntil = null;
    resendLockedUntil = null;
    setupExpiresAt = null;
    lastActivityAt = null;
    _timeoutDelivered = false;
    notifyListeners();
  }

  Duration remaining(DateTime? target) {
    if (target == null) return Duration.zero;
    final value = target.difference(_now());
    return value.isNegative ? Duration.zero : value;
  }

  String format(Duration duration) {
    final seconds = duration.inSeconds +
        (duration.inMilliseconds.remainder(1000) > 0 ? 1 : 0);
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startTicker() {
    _ticker?.cancel();
    if (!_isObservingLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _isObservingLifecycle = true;
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (stage == VerificationStage.idle || stage == VerificationStage.expired) {
      return;
    }

    final now = _now();
    if (verificationLockedUntil != null &&
        !now.isBefore(verificationLockedUntil!)) {
      verificationLockedUntil = null;
      attemptsRemaining = maximumAttempts;
    }
    if (resendLockedUntil != null && !now.isBefore(resendLockedUntil!)) {
      resendLockedUntil = null;
      resendCount = 0;
      resendAvailableAt = now;
    }

    VerificationTimeoutReason? reason;
    if (inactivityRemaining == Duration.zero) {
      reason = VerificationTimeoutReason.inactivity;
    } else if (isOtpStage && codeRemaining == Duration.zero) {
      reason = VerificationTimeoutReason.codeExpired;
    } else if (isSetupStage && setupRemaining == Duration.zero) {
      reason = VerificationTimeoutReason.setupExpired;
    }

    if (reason != null && !_timeoutDelivered) {
      _timeoutDelivered = true;
      stage = VerificationStage.expired;
      _ticker?.cancel();
      notifyListeners();
      onTimeout(reason);
      return;
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  @override
  void dispose() {
    if (_isObservingLifecycle) WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }
}
