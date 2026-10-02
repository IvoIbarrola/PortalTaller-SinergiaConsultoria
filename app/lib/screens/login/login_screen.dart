import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';
import '../consultant/consultant_home_screen.dart';
import '../insured/insured_home_screen.dart';
import '../workshop/workshop_home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Widget _screenForRole(UserRole role) {
    switch (role) {
      case UserRole.insured:
        return const InsuredHomeScreen();
      case UserRole.consultant:
        return const ConsultantHomeScreen();
      case UserRole.workshop:
        return const WorkshopHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Taller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Selecciona tu perfil',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresá directamente para acceder a la vista correspondiente.',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: appState.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = appState.users[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.name.isEmpty ? '?' : user.name[0]),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.role.label),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        appState.loginAs(user);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _screenForRole(user.role),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
