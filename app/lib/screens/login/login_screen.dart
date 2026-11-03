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
      setState(
        () => _errorMessage = 'Ingresá el número de siniestro y el celular.',
      );
      return;
    }
    final client = SupabaseConfig.client;
    if (client == null) {
      setState(() => _errorMessage = 'Supabase no está configurado.');
      return;
    }
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final response = await client.functions.invoke(
        'insured-case-access',
        body: {'claimNumber': claimNumber, 'phone': phone},
      );
      if (!mounted) return;
      if (response.status < 200 ||
          response.status >= 300 ||
          response.data is! Map ||
          response.data['case'] is! Map) {
        setState(
          () => _errorMessage = 'No se pudo validar el siniestro y el celular.',
        );
        return;
      }
      final caseData = Map<String, dynamic>.from(response.data['case'] as Map);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InsuredAccessResultScreen(caseData: caseData),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      setState(
        () => _errorMessage = 'No se pudo validar el acceso. Revisá los datos e intentá nuevamente.',
      );
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
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    final appState = AppState();
    final user = await appState.signIn(email, password);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _errorMessage = user == null
          ? appState.lastError ?? 'No se pudo iniciar sesión.'
          : null;
    });
    if (user != null) _openHome(user);
  }

  Future<void> _enterDemo(UserRole role, {String? userId}) async {
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final user = await AppState().signInDemo(role, userId: userId);
      if (!mounted || user == null) return;
      _openHome(user);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'No se pudo abrir la demo local: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
    final appState = AppState();
    final configured = appState.isSupabaseConfigured;
    final loginForm = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.car_repair_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'GESTIÓN · TECNOLOGÍA · ALIANZAS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
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
                configured
                    ? 'Seguí tu siniestro o ingresá al portal de tu equipo.'
                    : 'Explorá el seguimiento de siniestros con datos de muestra.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (configured && appState.lastError != null) ...[
                const SizedBox(height: 12),
                Text(
                  appState.lastError!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (configured) ...[
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Asegurado'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Taller / Consultoría'),
                      icon: Icon(Icons.business_outlined),
                    ),
                  ],
                  selected: {_insuredMode},
                  onSelectionChanged: _busy
                      ? null
                      : (selection) => setState(() {
                          _insuredMode = selection.first;
                          _errorMessage = null;
                        }),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _insuredMode
                              ? 'Consultar siniestro'
                              : 'Iniciar sesión profesional',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _insuredMode
                              ? 'Ingresá el siniestro y el celular asociado.'
                              : 'Usá el acceso asignado a tu equipo.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_insuredMode) ...[
                          TextField(
                            controller: _claimController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Número de siniestro',
                              prefixIcon: Icon(Icons.assignment_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submitInsured(),
                            decoration: const InputDecoration(
                              labelText: 'Celular registrado',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                        ] else ...[
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submitProfessional(),
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
                          onPressed: _busy
                              ? null
                              : (_insuredMode
                                    ? _submitInsured
                                    : _submitProfessional),
                          child: _busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _insuredMode
                                      ? 'Consultar siniestro'
                                      : 'Iniciar sesión',
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DEMO LOCAL · DATOS FICTICIOS',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Elegí un perfil para probar la app. Los cambios se guardan en este dispositivo.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _enterDemo(UserRole.insured),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Entrar como asegurado'),
                        ),
                        const SizedBox(height: 8),
                        ...appState.users
                            .where((user) {
                              if (user.role != UserRole.workshop) {
                                return false;
                              }
                              return appState
                                      .getWorkshopById(user.workshopId ?? '')
                                      ?.isActive ==
                                  true;
                            })
                            .map(
                              (user) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: OutlinedButton.icon(
                                  onPressed: _busy
                                      ? null
                                      : () => _enterDemo(
                                          UserRole.workshop,
                                          userId: user.id,
                                        ),
                                  icon: const Icon(Icons.handyman_outlined),
                                  label: Text('Entrar como ${user.name}'),
                                ),
                              ),
                            ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _enterDemo(UserRole.consultant),
                          icon: const Icon(Icons.business_outlined),
                          label: const Text('Entrar como consultoría'),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _busy
                              ? null
                              : () async {
                                  try {
                                    await appState.resetDemoData();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Datos de demostración reiniciados.',
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudieron reiniciar los datos: $error',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reiniciar datos de demo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1000) return loginForm;
            return Row(
              children: [
                Expanded(flex: 5, child: _LoginBrandPanel(theme: theme)),
                Expanded(flex: 6, child: loginForm),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.ink,
      padding: const EdgeInsets.all(48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 36,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 3,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: AppTheme.teal,
                          ),
                        ),
                        Positioned(
                          left: 17,
                          top: 3,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: AppTheme.coral.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grupo Sinergia',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'CONECTAMOS. POTENCIAMOS.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.mint,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 72),
              Text(
                'GESTIÓN  +  TECNOLOGÍA  +  ALIANZAS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.mint,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Todo conectado.\nMás claro.',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  height: 1.12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.coral,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Un espacio compartido para seguir cada siniestro y acercar a las personas que lo hacen posible.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFD8E1DD),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
