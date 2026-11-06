import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/vehicles.dart';
import '../../state/app_state.dart';
import '../../widgets/status_badge.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final repairCases = AppState().allCases
        .where((repairCase) => repairCase.vehicleId == vehicle.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(vehicle.displayName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 80,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      vehicle.displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Patente', value: vehicle.plate),
                    _InfoRow(label: 'Año', value: vehicle.year.toString()),
                    if (vehicle.color.isNotEmpty)
                      _InfoRow(label: 'Color', value: vehicle.color),
                    if (vehicle.vehicleType.isNotEmpty)
                      _InfoRow(label: 'Tipo', value: vehicle.vehicleType),
                    if (vehicle.trim.isNotEmpty)
                      _InfoRow(label: 'Versión', value: vehicle.trim),
                    if (vehicle.vin.isNotEmpty)
                      _InfoRow(label: 'Chasis / VIN', value: vehicle.vin),
                    if (vehicle.mileage != null)
                      _InfoRow(
                        label: 'Kilometraje',
                        value: '${vehicle.mileage} km',
                      ),
                    if (vehicle.notes.isNotEmpty)
                      _InfoRow(label: 'Observaciones', value: vehicle.notes),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Reparaciones',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (repairCases.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('No hay reparaciones registradas.'),
                  ),
                ),
              ),

            ...repairCases.map(
              (repairCase) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            repairCase.claimNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          StatusBadge(status: repairCase.status.label),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(repairCase.description),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: repairCase.progress / 100),
                      const SizedBox(height: 6),
                      Text('${repairCase.progress}% completado'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
