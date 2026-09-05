import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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

    throw Exception(
      data['detail'] ?? 'Login failed.',
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

    throw Exception(
      data['detail'] ?? 'Failed to send verification code.',
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

    throw Exception(
      data['detail'] ?? 'OTP verification failed.',
    );
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

    throw Exception(
      data['detail'] ?? 'Failed to send password reset code.',
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

    throw Exception(
      data['detail'] ?? 'OTP verification failed.',
    );
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