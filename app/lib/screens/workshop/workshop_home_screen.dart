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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cases.isEmpty
            ? const Center(child: Text('No hay casos asignados a este taller.'))
            : ListView.builder(
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  final repairCase = cases[index];
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
                          builder: (_) => WorkshopCaseScreen(caseId: repairCase.id),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
