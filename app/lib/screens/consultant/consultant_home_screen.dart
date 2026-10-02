import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/repair_case_card.dart';
import 'calendar_screen.dart';
import 'case_detail_screen.dart';
import 'cases_screen.dart';
import 'new_case_screen.dart';

class ConsultantHomeScreen extends StatelessWidget {
  const ConsultantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final cases = appState.allCases;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultoría'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarScreen(),
                ),
              );
            },
          ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Casos activos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewCaseScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo caso'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CasesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Todos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}
