import 'package:flutter/material.dart';

import 'data/supabase_config.dart';
import 'screens/login/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await AppState().initialize();
  runApp(const PortalTallerApp());
}

class MyApp extends PortalTallerApp {
  const MyApp({super.key});
}

class PortalTallerApp extends StatelessWidget {
  const PortalTallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => MaterialApp(
        title: 'Portal Taller',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: appState.themeMode,
        home: const LoginScreen(),
      ),
    );
  }
}
