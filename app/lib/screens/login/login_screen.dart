import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../consultant/consultant_home_screen.dart';
import '../insured/insured_home_screen.dart';
import '../workshop/workshop_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Ingresá email y contraseña.');
      return;
    }
    setState(() { _busy = true; _errorMessage = null; });
    final appState = AppState();
    final user = await appState.signIn(email, password);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _errorMessage = user == null ? appState.lastError ?? 'No se pudo iniciar sesión.' : null;
    });
    if (user != null) _openHome(user);
  }

  void _openHome(User user) {
    final Widget screen;

    switch (user.role) {
      case UserRole.insured:
        screen = const InsuredHomeScreen();
        break;
      case UserRole.consultant:
        screen = const ConsultantHomeScreen();
        break;
      case UserRole.workshop:
        screen = const WorkshopHomeScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configured = AppState().isSupabaseConfigured;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.car_repair_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SINERGIA · GESTIÓN DE SINIESTROS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.tealInk,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Portal Taller',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Ingresá con una cuenta habilitada para consultar los datos de Supabase.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Iniciar sesión',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Usá el email y la contraseña de tu cuenta.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.alternate_email)),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 20),
                          if (!configured) ...[
                            const SizedBox(height: 12),
                            Text('Supabase no está configurado. Definí SUPABASE_URL y SUPABASE_ANON_KEY.', style: TextStyle(color: theme.colorScheme.error)),
                          ],
                          FilledButton(
                            onPressed: _busy || !configured ? null : _submit,
                            child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Conectar y cargar datos'),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
