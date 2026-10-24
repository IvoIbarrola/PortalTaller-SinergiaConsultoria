import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vehicle_card.dart';
import '../workshop/workshop_photos_screen.dart';
import 'insured_chat_screen.dart';

class InsuredCaseScreen extends StatelessWidget {
  final String caseId;

  const InsuredCaseScreen({super.key, required this.caseId});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final repairCase = appState.getCaseById(caseId);

    if (repairCase == null) {
      return const Scaffold(
        body: Center(child: Text('Caso no encontrado.')),
      );
    }

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
    final workshop = repairCase.workshopId == null
        ? null
        : appState.getWorkshopById(repairCase.workshopId!);
    final progressIndex = ((repairCase.progress / 100) * 3).round().clamp(0, 3);

    return Scaffold(
      appBar: AppBar(
        title: Text(repairCase.claimNumber),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estado del caso',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              StatusBadge(status: repairCase.status.label),
            ],
          ),
          const SizedBox(height: 20),
          ProgressTimeline(
            steps: const ['Inicio', 'Revisión', 'Reparación', 'Entrega'],
            currentIndex: progressIndex,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DETALLE DEL SINIESTRO',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.tealInk,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          )),
                  const SizedBox(height: 8),
                  Text(repairCase.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    minHeight: 6,
                    value: (repairCase.progress / 100).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${repairCase.progress}% completado',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Divider(height: 24),
                  _CaseDateRow(
                    label: 'Fecha de ingreso',
                    value: _formatDate(repairCase.entryDate),
                  ),
                  if (repairCase.estimatedDeliveryDate != null) ...[
                    const SizedBox(height: 10),
                    _CaseDateRow(
                      label: 'Entrega estimada',
                      value: _formatDate(repairCase.estimatedDeliveryDate!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          VehicleCard(
            vehicle: vehicle,
            status: repairCase.status.label,
          ),
          const SizedBox(height: 4),
          if (workshop != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.handyman_outlined),
                ),
                title: Text(workshop.name),
                subtitle: Text('${workshop.city} • ${workshop.phone}'),
              ),
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aún no se asignó un taller.'),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InsuredChatScreen(caseId: repairCase.id),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Abrir chat'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkshopPhotosScreen(
                    caseId: repairCase.id,
                    claimNumber: repairCase.claimNumber,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Ver registro fotográfico'),
          ),
        ],
      ),
    );
  }
}

class _CaseDateRow extends StatelessWidget {
  final String label;
  final String value;

  const _CaseDateRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
