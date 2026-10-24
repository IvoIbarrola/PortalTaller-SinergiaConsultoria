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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seguimiento de siniestros',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              '${cases.length} casos en la red',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
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
                const SizedBox(width: 10),
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
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Todos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cases.isEmpty
                  ? const Center(child: Text('Todavía no hay casos registrados.'))
                  : ListView.builder(
                      itemCount: cases.length,
                      itemBuilder: (context, index) {
                        final repairCase = cases[index];
                        final vehicle =
                            appState.getVehicleById(repairCase.vehicleId);
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
                                    CaseDetailScreen(caseId: repairCase.id),
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
