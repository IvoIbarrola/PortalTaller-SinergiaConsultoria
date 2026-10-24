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
                    _showPassword
                        ? 'Ingresá la contraseña para continuar.'
                        : 'Seguí el estado de tu siniestro o ingresá a las herramientas de gestión.',
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
                            _showPassword ? 'Acceso profesional' : 'Ingresar',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _showPassword
                                ? 'Completá tus datos de acceso.'
                                : 'Usá tu código de siniestro o código de acceso.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
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
                              prefixIcon:
                                  Icon(Icons.confirmation_number_outlined),
                            ),
                          ),
                          if (_showPassword) ...[
                            const SizedBox(height: 14),
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
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _submit,
                            child: Text(
                              _showPassword ? 'Ingresar' : 'Continuar',
                            ),
                          ),
                          if (_showPassword) ...[
                            const SizedBox(height: 4),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
