import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../widgets/repair_case_card.dart';
import 'workshop_case_screen.dart';

class WorkshopHomeScreen extends StatelessWidget {
  const WorkshopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final currentUser = appState.currentUser;

    if (currentUser == null || currentUser.role != UserRole.workshop) {
      return const Scaffold(
        body: Center(child: Text('Debe iniciar sesión como taller.')),
      );
    }

    final cases = appState.casesForCurrentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser.name),
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
      body: cases.isEmpty
          ? const Center(child: Text('No hay casos asignados a este taller.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: cases.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trabajos asignados',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Revisá el avance y actualizá cada reparación.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                final repairCase = cases[index - 1];
                final vehicle = appState.getVehicleById(repairCase.vehicleId);
                if (vehicle == null) {
                  return const SizedBox.shrink();
                }

                return RepairCaseCard(
                  repairCase: repairCase,
                  vehicle: vehicle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WorkshopCaseScreen(caseId: repairCase.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
