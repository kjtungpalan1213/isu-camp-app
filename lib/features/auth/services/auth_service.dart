import 'dart:async';
import 'user_session.dart';

/// Result returned by authentication operations.
class AuthResult {
  final bool success;
  final String message;
  final bool isUserNotFound;
  final Map<String, dynamic>? user;

  AuthResult({
    required this.success,
    required this.message,
    this.isUserNotFound = false,
    this.user,
  });
}

/// Authentication Service Contract
///
/// ════════════════════════════════════════════════════════════════════════════
/// 📌 NOTE FOR BACKEND DEVELOPERS:
/// This file serves as the bridge between the Flutter UI and the Backend.
/// Replace or connect your Supabase Auth or REST API endpoints here.
/// ════════════════════════════════════════════════════════════════════════════
class AuthService {
  // Temporary in-memory mock database for UI/UX testing
  static final Map<String, Map<String, String>> _registeredUsers = {
    'leader_justine': {
      'username': 'LEADER_JUSTINE',
      'email': 'justine@isu.edu.ph',
      'password': 'Password123!',
      'studentId': '21-02384',
      'course': 'BS Information Technology',
      'college': 'CCSICT',
    },
    'student_demo': {
      'username': 'Student_Demo',
      'email': 'student@isu.edu.ph',
      'password': 'Password123!',
      'studentId': '22-01122',
      'course': 'BS Computer Science',
      'college': 'CCSICT',
    },
  };

  /// --------------------------------------------------------------------------
  /// LOGIN
  /// --------------------------------------------------------------------------
  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();

    // Mock network latency (600ms)
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: [BACKEND DEV] Connect your Supabase / API endpoint here
    // Example using Supabase:
    // final response = await Supabase.instance.client.auth.signInWithPassword(...);

    final key = cleanUsername.toLowerCase();

    // 1. Check if user exists in database
    if (!_registeredUsers.containsKey(key)) {
      return AuthResult(
        success: false,
        isUserNotFound: true,
        message:
            'Unable to log in: Account "$cleanUsername" does not exist in the database. You need to create an account first.',
      );
    }

    // 2. Check if password is correct
    final user = _registeredUsers[key]!;
    if (user['password'] != password) {
      return AuthResult(
        success: false,
        isUserNotFound: false,
        message:
            'Unable to log in: Incorrect username or password. Please check your credentials.',
      );
    }

    // 3. Update UserSession
    UserSession.setLoggedInUser(username: user['username'] ?? cleanUsername);
    if (user['email'] != null) UserSession.currentEmail = user['email']!;
    if (user['studentId'] != null) UserSession.studentId = user['studentId']!;
    if (user['course'] != null) UserSession.course = user['course']!;
    if (user['college'] != null) UserSession.college = user['college']!;

    return AuthResult(
      success: true,
      message: 'Login successful!',
      user: user,
    );
  }

  /// --------------------------------------------------------------------------
  /// REGISTER
  /// --------------------------------------------------------------------------
  static Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();

    // Mock network latency (600ms)
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: [BACKEND DEV] Connect your Supabase / API endpoint here
    // Example:
    // final res = await Supabase.instance.client.auth.signUp(email: cleanEmail, password: password);

    final key = cleanUsername.toLowerCase();
    if (_registeredUsers.containsKey(key)) {
      return AuthResult(
        success: false,
        message: 'Username "$cleanUsername" is already taken. Please choose another.',
      );
    }

    final newUser = {
      'username': cleanUsername,
      'email': cleanEmail,
      'password': password,
      'studentId': '23-${(10000 + cleanUsername.hashCode.abs() % 90000)}',
      'course': 'BS Information Technology',
      'college': 'CCSICT',
    };

    _registeredUsers[key] = newUser;
    UserSession.setRegisteredUser(
      username: cleanUsername,
      email: cleanEmail,
    );

    return AuthResult(
      success: true,
      message: 'Account created successfully in database! Please log in.',
      user: newUser,
    );
  }

  /// --------------------------------------------------------------------------
  /// RESET PASSWORD
  /// --------------------------------------------------------------------------
  static Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Mock network latency
    await Future.delayed(const Duration(milliseconds: 600));

    for (final entry in _registeredUsers.values) {
      if (entry['email']?.toLowerCase() == cleanEmail) {
        entry['password'] = newPassword;
        return AuthResult(
          success: true,
          message: 'Password updated successfully. Please log in with your new password.',
        );
      }
    }

    return AuthResult(
      success: false,
      message: 'No account found with the email "$email".',
    );
  }
}
