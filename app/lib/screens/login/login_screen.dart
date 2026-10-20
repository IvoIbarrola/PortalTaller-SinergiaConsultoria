import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';
import '../consultant/consultant_home_screen.dart';
import '../insured/insured_home_screen.dart';
import '../workshop/workshop_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final appState = AppState();
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Ingresá un código para continuar.';
      });
      return;
    }

    if (_showPassword) {
      final user = appState.loginWithSpecialAccess(
        code,
        _passwordController.text,
      );

      if (user == null) {
        setState(() {
          _errorMessage = 'La contraseña ingresada es incorrecta.';
        });
        return;
      }

      _openHome(user);
      return;
    }

    final insuredUser = appState.loginWithClaimCode(code);

    if (insuredUser != null) {
      _openHome(insuredUser);
      return;
    }

    if (appState.isSpecialAccessCode(code)) {
      setState(() {
        _showPassword = true;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _errorMessage = 'El código ingresado no es válido.';
    });
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

    return Scaffold(
      appBar: AppBar(title: const Text('Portal Taller'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.car_repair_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ingresá a tu portal',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showPassword
                        ? 'Ingresá la contraseña para continuar.'
                        : 'Ingresá tu código de siniestro o código de acceso.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enabled: !_showPassword,
                    textInputAction: _showPassword
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onChanged: (_) {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      hintText: 'Ingresá tu código',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_showPassword) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_showPassword ? 'Ingresar' : 'Continuar'),
                    ),
                  ),
                  if (_showPassword) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showPassword = false;
                          _passwordController.clear();
                          _errorMessage = null;
                        });
                      },
                      child: const Text('Volver'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
