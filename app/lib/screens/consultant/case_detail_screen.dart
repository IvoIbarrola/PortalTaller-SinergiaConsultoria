import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
import '../../widgets/progress_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vehicle_card.dart';
import '../insured/insured_chat_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  final appState = AppState();
  String? _selectedWorkshopId;

  @override
  Widget build(BuildContext context) {
    final repairCase = appState.getCaseById(widget.caseId);

    if (repairCase == null) {
      return const Scaffold(
        body: Center(child: Text('Caso no encontrado.')),
      );
    }

    _selectedWorkshopId ??= repairCase.workshopId ??
      (appState.workshops.isNotEmpty ? appState.workshops.first.id : null);
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
                'Detalle del caso',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  Text(repairCase.description),
                  const SizedBox(height: 12),
                  Text('Asegurado: ${insured?.name ?? 'Sin dato'}'),
                  Text('Ingreso: ${repairCase.entryDate.day}/${repairCase.entryDate.month}/${repairCase.entryDate.year}'),
                  if (repairCase.estimatedDeliveryDate != null)
                    Text(
                      'Entrega estimada: ${repairCase.estimatedDeliveryDate!.day}/${repairCase.estimatedDeliveryDate!.month}/${repairCase.estimatedDeliveryDate!.year}',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedWorkshopId,
            decoration: const InputDecoration(
              labelText: 'Asignar taller',
              border: OutlineInputBorder(),
            ),
            items: appState.workshops
                .map(
                  (workshop) => DropdownMenuItem(
                    value: workshop.id,
                    child: Text(workshop.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              appState.assignWorkshop(widget.caseId, value);
              setState(() => _selectedWorkshopId = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RepairCaseStatus>(
            value: repairCase.status,
            decoration: const InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(),
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
          const SizedBox(height: 12),
          Text('Progreso: ${repairCase.progress}%'),
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
        ],
      ),
    );
  }
}
