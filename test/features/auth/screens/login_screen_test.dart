import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isu_camp_app/features/auth/screens/login_screen.dart';

void main() {
  Widget buildSubject() {
    return const MaterialApp(home: LoginScreen());
  }

  testWidgets('renders the login form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(buildSubject());

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('rejects an invalid reset email', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'not-an-email');
    await tester.tap(find.text('Request Reset Code'));
    await tester.pump();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('Reset Password'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('valid reset email opens code verification', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'user@example.com');
    await tester.tap(find.text('Request Reset Code'));
    await tester.pumpAndSettle();

    expect(find.text('Verify Code'), findsOneWidget);
    expect(
        find.text(
            'Enter the simulated 6-digit verification code for user@example.com.'),
        findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });
}
