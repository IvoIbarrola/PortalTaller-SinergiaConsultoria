import 'package:flutter/material.dart';

import '../../data/supabase_config.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../consultant/consultant_home_screen.dart';
import '../insured/insured_home_screen.dart';
import '../insured/insured_access_result_screen.dart';
import '../workshop/workshop_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _claimController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _insuredMode = true;
  bool _busy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _claimController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitInsured() async {
    final claimNumber = _claimController.text.trim();
    final phone = _phoneController.text.trim();
    if (claimNumber.isEmpty || phone.isEmpty) {
      setState(() => _errorMessage = 'Ingresá el número de siniestro y el celular.');
      return;
    }
    final client = SupabaseConfig.client;
    if (client == null) {
      setState(() => _errorMessage = 'Supabase no está configurado.');
      return;
    }
    setState(() { _busy = true; _errorMessage = null; });
    try {
      final response = await client.functions.invoke(
        'insured-case-access',
        body: {'claimNumber': claimNumber, 'phone': phone},
      );
      if (!mounted) return;
      if (response.status < 200 || response.status >= 300 ||
          response.data is! Map || response.data['case'] is! Map) {
        setState(() => _errorMessage = 'No se pudo validar el siniestro y el celular.');
        return;
      }
      final caseData = Map<String, dynamic>.from(response.data['case'] as Map);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InsuredAccessResultScreen(caseData: caseData),
      ));
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'No se pudo validar el acceso. Revisá los datos e intentá nuevamente.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitProfessional() async {
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configured = AppState().isSupabaseConfigured;
    return Scaffold(
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              width: 68, height: 68, alignment: Alignment.center,
              decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.car_repair_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text('SINERGIA · GESTIÓN DE SINIESTROS', style: theme.textTheme.labelMedium?.copyWith(
              color: AppTheme.tealInk, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Text('Portal Taller', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            Text('Consultá el estado de tu siniestro o ingresá al portal profesional.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('Asegurado'), icon: Icon(Icons.person_outline)),
                ButtonSegment<bool>(value: false, label: Text('Taller / Consultoría'), icon: Icon(Icons.business_outlined)),
              ],
              selected: {_insuredMode},
              onSelectionChanged: _busy ? null : (selection) => setState(() {
                _insuredMode = selection.first; _errorMessage = null;
              }),
            ),
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(_insuredMode ? 'Consultar siniestro' : 'Iniciar sesión profesional',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(_insuredMode
                  ? 'Ingresá el número de siniestro y el celular registrado.'
                  : 'Usá el email y la contraseña de tu cuenta habilitada.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 20),
                if (_insuredMode) ...[
                  TextField(controller: _claimController, textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Número de siniestro', prefixIcon: Icon(Icons.assignment_outlined))),
                  const SizedBox(height: 14),
                  TextField(controller: _phoneController, keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done, onSubmitted: (_) => _submitInsured(),
                    decoration: const InputDecoration(labelText: 'Celular registrado', prefixIcon: Icon(Icons.phone_outlined))),
                ] else ...[
                  TextField(controller: _emailController, keyboardType: TextInputType.emailAddress,
                    autocorrect: false, textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.alternate_email))),
                  const SizedBox(height: 14),
                  TextField(controller: _passwordController, obscureText: true,
                    textInputAction: TextInputAction.done, onSubmitted: (_) => _submitProfessional(),
                    decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline))),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                if (!configured) ...[
                  const SizedBox(height: 12),
                  Text('Supabase no está configurado. Definí SUPABASE_URL y SUPABASE_ANON_KEY.',
                    style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy || !configured ? null : (_insuredMode ? _submitInsured : _submitProfessional),
                  child: _busy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_insuredMode ? 'Consultar siniestro' : 'Iniciar sesión'),
                ),
              ],
            ))),
          ]),
        ),
      ))),
    );
  }
}
