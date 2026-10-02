import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/repair_case_card.dart';
import 'case_detail_screen.dart';

class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final cases = appState.allCases;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los casos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
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
                    builder: (_) => CaseDetailScreen(caseId: repairCase.id),
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
