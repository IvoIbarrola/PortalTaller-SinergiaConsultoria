import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';

const _errorReportEmail = 'ivo18ibarrola@gmail.com';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _appState = AppState();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _loadedUserId;
  bool _savingProfile = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadProfile(User? user) {
    if (user == null || user.id == _loadedUserId) return;
    _loadedUserId = user.id;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _savingProfile = true);
    try {
      await _appState.updateCurrentUserProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferencias del perfil guardadas.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el perfil: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _resetDemoData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar datos de demo'),
        content: const Text(
          'Se borrarán los cambios locales de casos, talleres y vehículos. '
          'La apariencia y las preferencias del perfil se conservarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _appState.resetDemoData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos de demostración reiniciados.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron reiniciar los datos: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _appState,
    builder: (context, _) {
      final user = _appState.currentUser;
      _loadProfile(user);
      return Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Preferencias',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<ThemeMode>(
                groupValue: _appState.themeMode,
                onChanged: (mode) {
                  if (mode != null) _changeTheme(mode);
                },
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      title: Text('Usar tema del sistema'),
                      secondary: Icon(Icons.brightness_auto_outlined),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text('Tema claro'),
                      secondary: Icon(Icons.light_mode_outlined),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text('Tema oscuro'),
                      secondary: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mi perfil',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre visible *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Ingresá tu nombre.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email de contacto',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (value) {
                          final email = (value ?? '').trim();
                          if (email.isNotEmpty &&
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(email)) {
                            return 'Ingresá un email válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono de contacto',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _appState.isDemoMode
                              ? 'El nombre se usa en la demo. Los datos se guardan en este dispositivo.'
                              : 'Personalización local: no modifica los datos de tu cuenta en el servidor.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _savingProfile ? null : _saveProfile,
                          child: Text(
                            _savingProfile ? 'Guardando…' : 'Guardar perfil',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ayuda',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: const Text('Reportar un error'),
                subtitle: const Text(
                  'Prepara un correo para que describas el problema.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const ErrorReportScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aplicación',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Portal Taller · Demo'),
                    subtitle: Text(
                      'Los datos de demostración se guardan en este dispositivo.',
                    ),
                  ),
                  if (_appState.isDemoMode) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.restart_alt),
                      title: const Text('Reiniciar datos de demo'),
                      subtitle: const Text(
                        'Restaura los ejemplos originales de la aplicación.',
                      ),
                      onTap: _resetDemoData,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  Future<void> _changeTheme(ThemeMode mode) async {
    try {
      await _appState.setThemeMode(mode);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la apariencia: $error')),
      );
    }
  }
}

class ErrorReportScreen extends StatefulWidget {
  const ErrorReportScreen({super.key});

  @override
  State<ErrorReportScreen> createState() => _ErrorReportScreenState();
}

class _ErrorReportScreenState extends State<ErrorReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  bool _openingEmail = false;

  @override
  void initState() {
    super.initState();
    _contactController.text = AppState().currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _prepareEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _openingEmail = true);
    final user = AppState().currentUser;
    final report = Uri(
      scheme: 'mailto',
      path: _errorReportEmail,
      queryParameters: {
        'subject': 'Reporte de error · Portal Taller',
        'body': [
          'Descripción del problema:',
          _descriptionController.text.trim(),
          '',
          'Perfil: ${user?.role.label ?? 'No identificado'}',
          'Nombre: ${user?.name ?? 'No identificado'}',
          if (_contactController.text.trim().isNotEmpty)
            'Contacto: ${_contactController.text.trim()}',
          '',
          'No se adjuntaron datos de siniestros ni información privada.',
        ].join('\n'),
      },
    );
    try {
      final opened = await launchUrl(
        report,
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      if (!opened) {
        _showMessage(
          'No se encontró una aplicación de correo. Revisá que haya una configurada en el teléfono.',
        );
        return;
      }
      _showMessage(
        'Revisá el borrador y presioná Enviar en tu aplicación de correo.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('No se pudo abrir el correo: $error');
    } finally {
      if (mounted) setState(() => _openingEmail = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reportar un error')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Contanos qué pasó y, si podés, qué pasos seguiste. Se abrirá un '
            'borrador dirigido al equipo de soporte; el reporte solo se envía '
            'cuando lo confirmes desde tu correo.',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            minLines: 5,
            maxLines: 8,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descripción del error *',
              hintText: '¿Qué ocurrió? ¿Qué esperabas que ocurriera?',
              alignLabelWithHint: true,
            ),
            validator: (value) => (value ?? '').trim().isEmpty
                ? 'Describí el problema para preparar el reporte.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email para contactarte (opcional)',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (value) {
              final email = (value ?? '').trim();
              if (email.isNotEmpty &&
                  !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Ingresá un email válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text(
            'No agregues contraseñas ni datos privados de siniestros. '
            'El reporte incluirá el rol y el nombre del perfil actual.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _openingEmail ? null : _prepareEmail,
            icon: const Icon(Icons.mail_outline),
            label: Text(
              _openingEmail ? 'Abriendo correo…' : 'Preparar reporte por email',
            ),
          ),
        ],
      ),
    ),
  );
}
