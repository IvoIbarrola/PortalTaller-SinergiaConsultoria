import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../state/app_state.dart';
import '../../widgets/repair_case_card.dart';
import '../settings/settings_screen.dart';
import 'calendar_screen.dart';
import 'case_detail_screen.dart';
import 'cases_screen.dart';
import 'consultant_statistics_screen.dart';
import 'new_case_screen.dart';
import 'vehicles_management_screen.dart';
import 'workshops_screen.dart';

class ConsultantHomeScreen extends StatelessWidget {
  const ConsultantHomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final cases = appState.allCases;
        final openCases = cases
            .where((item) => item.status != RepairCaseStatus.delivered)
            .toList();
        final assignedCases = openCases
            .where((item) => item.workshopId != null)
            .toList();
        final readyCases = openCases
            .where((item) => item.status == RepairCaseStatus.readyForDelivery)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Portal Taller'),
            actions: [
              IconButton(
                tooltip: 'Agenda',
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => _open(context, const CalendarScreen()),
              ),
              IconButton(
                tooltip: 'Configuración',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _open(context, const SettingsScreen()),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () {
                  appState.logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth
                  .clamp(0, 1200)
                  .toDouble();
              final horizontalPadding = contentWidth >= 1000
                  ? 40.0
                  : contentWidth >= 600
                  ? 28.0
                  : 20.0;
              final availableWidth = contentWidth - horizontalPadding * 2;
              final columns = contentWidth >= 1050
                  ? 3
                  : contentWidth >= 440
                  ? 2
                  : 1;
              final tileWidth = (availableWidth - (columns - 1) * 12) / columns;
              final wide = constraints.maxWidth >= 760;
              final recentCases = cases.take(5).toList();

              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hola, ${appState.currentUser?.name ?? 'equipo'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tu operación, en un solo lugar.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (wide)
                                FilledButton.icon(
                                  onPressed: () =>
                                      _open(context, const NewCaseScreen()),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Nuevo caso'),
                                ),
                            ],
                          ),
                          if (!wide) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () =>
                                    _open(context, const NewCaseScreen()),
                                icon: const Icon(Icons.add),
                                label: const Text('Nuevo caso'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _SummaryTile(
                                width: tileWidth,
                                label: 'Casos activos',
                                value: openCases.length,
                                icon: Icons.assignment_outlined,
                              ),
                              _SummaryTile(
                                width: tileWidth,
                                label: 'En talleres',
                                value: assignedCases.length,
                                icon: Icons.handyman_outlined,
                              ),
                              _SummaryTile(
                                width: tileWidth,
                                label: 'Listos para entregar',
                                value: readyCases.length,
                                icon: Icons.task_alt_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Accesos rápidos',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _open(context, const CasesScreen()),
                                icon: const Icon(Icons.list_alt_outlined),
                                label: const Text('Casos'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _open(context, const WorkshopsScreen()),
                                icon: const Icon(Icons.handyman_outlined),
                                label: const Text('Talleres'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _open(
                                  context,
                                  const VehiclesManagementScreen(),
                                ),
                                icon: const Icon(Icons.directions_car_outlined),
                                label: const Text('Vehículos'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _open(
                                  context,
                                  const ConsultantStatisticsScreen(),
                                ),
                                icon: const Icon(Icons.insights_outlined),
                                label: const Text('Estadísticas'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Casos recientes',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (cases.length > recentCases.length)
                                TextButton(
                                  onPressed: () =>
                                      _open(context, const CasesScreen()),
                                  child: const Text('Ver todos'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (recentCases.isEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Todavía no hay casos registrados.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...recentCases.map((repairCase) {
                              final vehicle = appState.getVehicleById(
                                repairCase.vehicleId,
                              );
                              if (vehicle == null) {
                                return const SizedBox.shrink();
                              }

                              return RepairCaseCard(
                                repairCase: repairCase,
                                vehicle: vehicle,
                                onTap: () => _open(
                                  context,
                                  CaseDetailScreen(caseId: repairCase.id),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double width;
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
