import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/repair_case_card.dart';
import 'insured_case_screen.dart';

class InsuredHomeScreen extends StatelessWidget {
  const InsuredHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final currentUser = appState.currentUser;

    if (currentUser == null || currentUser.role != UserRole.insured) {
      return const Scaffold(
        body: Center(
          child: Text('Debe iniciar sesión como asegurado.'),
        ),
      );
    }

    final cases = appState.casesForCurrentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis casos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appState.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: ListView(
          children: [
            Text(
              'Hola, ${currentUser.name}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Consultá el estado de tus siniestros y reparaciones.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tus siniestros',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${cases.length} ${cases.length == 1 ? 'caso' : 'casos'}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cases.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 36,
                        color: AppTheme.tealInk,
                      ),
                      const SizedBox(height: 12),
                      const Text('Todavía no tenés casos asociados.'),
                    ],
                  ),
                ),
              )
            else
              ...cases.map((repairCase) {
                final vehicle = appState.getVehicleById(repairCase.vehicleId) ??
                    const Vehicle(
                      id: '',
                      brand: 'Vehículo',
                      model: 'Sin información',
                      year: 0,
                      plate: '',
                      color: '',
                      imageUrl: '',
                    );

                return RepairCaseCard(
                  repairCase: repairCase,
                  vehicle: vehicle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InsuredCaseScreen(caseId: repairCase.id),
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}
