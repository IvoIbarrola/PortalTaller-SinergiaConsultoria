import 'package:flutter/material.dart';

import 'data/supabase_config.dart';

import 'screens/login/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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