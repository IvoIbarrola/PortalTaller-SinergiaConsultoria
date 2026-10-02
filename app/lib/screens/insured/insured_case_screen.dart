import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
import '../../widgets/progress_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vehicle_card.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado del caso',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                    repairCase.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text('Fecha de ingreso: ${_formatDate(repairCase.entryDate)}'),
                  if (repairCase.estimatedDeliveryDate != null)
                    Text(
                      'Fecha estimada: ${_formatDate(repairCase.estimatedDeliveryDate!)}',
                    ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (repairCase.progress / 100).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 8),
                  Text('${repairCase.progress}% completado'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          VehicleCard(
            vehicle: vehicle,
            status: repairCase.status.label,
          ),
          const SizedBox(height: 12),
          if (workshop != null)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.build),
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
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
