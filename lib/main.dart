import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'features/auth/data/fake_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/screens/get_started_screen.dart';

void main() {
  final AuthRepository authRepository = FakeAuthRepository();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MyApp(authRepository: authRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'ISU-CAMP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: GetStartedScreen(authRepository: authRepository),
    );
  }
}
