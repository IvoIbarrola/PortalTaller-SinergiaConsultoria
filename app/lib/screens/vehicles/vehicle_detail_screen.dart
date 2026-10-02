import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/vehicles.dart';
import '../../widgets/status_badge.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final repairCases = mockRepairCases
        .where(
          (repairCase) => repairCase.vehicleId == vehicle.id,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.displayName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      vehicle.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Patente',
                      value: vehicle.plate,
                    ),
                    _InfoRow(
                      label: 'Año',
                      value: vehicle.year.toString(),
                    ),
                    _InfoRow(
                      label: 'Color',
                      value: vehicle.color,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Reparaciones',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            if (repairCases.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No hay reparaciones registradas.',
                    ),
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
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            repairCase.claimNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          StatusBadge(
                            status: repairCase.status,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(repairCase.description),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: repairCase.progress / 100,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${repairCase.progress}% completado',
                      ),
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

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}