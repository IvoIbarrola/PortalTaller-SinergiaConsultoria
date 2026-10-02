import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
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
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, ${currentUser.name}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Consulta el estado de tus siniestros y reparaciones.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (cases.isEmpty)
              const Center(
                child: Text('Todavía no tenés casos asociados.'),
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
