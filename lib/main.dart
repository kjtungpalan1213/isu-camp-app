import 'package:flutter/material.dart';

import 'features/auth/screens/get_started_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KUMPAS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const GetStartedScreen(),
    );
  }
}
