import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}