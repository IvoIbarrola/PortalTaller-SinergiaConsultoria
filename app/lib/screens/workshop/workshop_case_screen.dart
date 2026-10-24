import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vehicle_card.dart';
import 'workshop_chat_screen.dart';
import 'workshop_photos_screen.dart';

class WorkshopCaseScreen extends StatefulWidget {
  final String caseId;

  const WorkshopCaseScreen({super.key, required this.caseId});

  @override
  State<WorkshopCaseScreen> createState() => _WorkshopCaseScreenState();
}

class _WorkshopCaseScreenState extends State<WorkshopCaseScreen> {
  final appState = AppState();

  @override
  Widget build(BuildContext context) {
    final repairCase = appState.getCaseById(widget.caseId);

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

    final insured = appState.getUserById(repairCase.insuredUserId);
    final progressIndex =
        ((repairCase.progress / 100) * 3).round().clamp(0, 3);

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
                'Caso asignado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              StatusBadge(status: repairCase.status.label),
            ],
          ),
          const SizedBox(height: 16),
          ProgressTimeline(
            steps: const ['Inicio', 'Revisión', 'Reparación', 'Entrega'],
            currentIndex: progressIndex,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMACIÓN DEL CASO',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.tealInk,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(repairCase.description),
                  const SizedBox(height: 12),
                  Text('Asegurado: ${insured?.name ?? 'Sin dato'}'),
                  if (repairCase.estimatedDeliveryDate != null)
                    Text(
                      'Entrega estimada: '
                      '${repairCase.estimatedDeliveryDate!.day}/'
                      '${repairCase.estimatedDeliveryDate!.month}/'
                      '${repairCase.estimatedDeliveryDate!.year}',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RepairCaseStatus>(
            value: repairCase.status,
            decoration: const InputDecoration(
              labelText: 'Estado',
            ),
            items: RepairCaseStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              appState.updateCaseStatus(widget.caseId, value);
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Avance de reparación · ${repairCase.progress}%',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Slider(
            value: repairCase.progress.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (value) {
              appState.updateProgress(widget.caseId, value.round());
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          VehicleCard(
            vehicle: vehicle,
            status: repairCase.status.label,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
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
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Registrar fotografías'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkshopChatScreen(
                    caseId: repairCase.id,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Abrir chat'),
          ),
        ],
      ),
    );
  }
}