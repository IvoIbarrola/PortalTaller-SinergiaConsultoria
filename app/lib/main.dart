import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';

void main() {
  runApp(const PortalTallerApp());
}

class MyApp extends PortalTallerApp {
  const MyApp({super.key});
}

class PortalTallerApp extends StatelessWidget {
  const PortalTallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Taller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const LoginScreen(),
    );
  }
}