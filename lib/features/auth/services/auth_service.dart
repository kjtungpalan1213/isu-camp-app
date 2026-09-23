import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginException implements Exception {
  final String message;
  final int? retryAfterSeconds;
  final int? failedAttempts;
  final int? remainingAttempts;

  const LoginException(
    this.message, {
    this.retryAfterSeconds,
    this.failedAttempts,
    this.remainingAttempts,
  });

  @override
  String toString() => message;
}

class OtpException implements Exception {
  final String message;
  final int? attemptsRemaining;
  final int? retryAfterSeconds;

  const OtpException(
    this.message, {
    this.attemptsRemaining,
    this.retryAfterSeconds,
  });

  bool get isLocked => attemptsRemaining == 0 || retryAfterSeconds != null;

  @override
  String toString() => message;
}

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.kumpas.live',
  );

  static OtpException _otpException(
    http.Response response,
    Map<String, dynamic> data,
    String fallback,
  ) {
    final message = data['detail']?.toString() ?? fallback;
    final remainingMatch =
        RegExp(r'(\d+)\s+attempt\(s\)\s+remaining').firstMatch(message);
    final structuredRemaining = data['attempts_remaining'];
    final retryAfter = response.headers['retry-after'];
    return OtpException(
      message,
      attemptsRemaining: structuredRemaining is int
          ? structuredRemaining
          : remainingMatch == null
              ? (message.toLowerCase().contains('too many') ? 0 : null)
              : int.tryParse(remainingMatch.group(1)!),
      retryAfterSeconds: retryAfter == null ? null : int.tryParse(retryAfter),
    );
  }

  // =========================================================
  // LOGIN
  // =========================================================

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    final retryAfter = response.headers['retry-after'];
    final failedAttempts = response.headers['x-login-attempts'];
    final remainingAttempts = response.headers['x-login-attempts-remaining'];
    throw LoginException(
      data['detail'] ?? 'Login failed.',
      retryAfterSeconds: retryAfter == null ? null : int.tryParse(retryAfter),
      failedAttempts:
          failedAttempts == null ? null : int.tryParse(failedAttempts),
      remainingAttempts:
          remainingAttempts == null ? null : int.tryParse(remainingAttempts),
    );
  }

  // =========================================================
  // SIGN UP - REQUEST OTP
  // =========================================================

  static Future<Map<String, dynamic>> requestSignupOtp({
    required String username,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup/request-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw _otpException(
      response,
      data,
      'Failed to send verification code.',
    );
  }

  // =========================================================
  // SIGN UP - VERIFY OTP
  // =========================================================

  static Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required int otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw _otpException(response, data, 'OTP verification failed.');
  }

  // =========================================================
  // SIGN UP - SET PASSWORD
  // =========================================================

  static Future<Map<String, dynamic>> setSignupPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup/set-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['detail'] ?? 'Failed to create account.',
    );
  }

  // =========================================================
  // FORGOT PASSWORD - REQUEST OTP
  // =========================================================

  static Future<Map<String, dynamic>> requestForgotPasswordOtp({
    required String identifier,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/request-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw _otpException(
      response,
      data,
      'Failed to send password reset code.',
    );
  }

  // =========================================================
  // FORGOT PASSWORD - VERIFY OTP
  // =========================================================

  static Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String identifier,
    required int otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'otp': otp,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw _otpException(response, data, 'OTP verification failed.');
  }

  // =========================================================
  // FORGOT PASSWORD - RESET PASSWORD
  // =========================================================

  static Future<Map<String, dynamic>> resetForgotPassword({
    required String identifier,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password/reset-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['detail'] ?? 'Failed to reset password.',
    );
  }
}
