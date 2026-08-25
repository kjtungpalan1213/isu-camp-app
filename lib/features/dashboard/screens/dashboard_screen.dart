import 'package:flutter/material.dart';
import 'map_view_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Currently, the dashboard just displays the full-screen map.
      // We can wrap this in a BottomNavigationBar later if needed.
      body: MapViewScreen(),
    );
  }
}
