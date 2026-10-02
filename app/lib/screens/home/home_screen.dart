import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/status_badge.dart';
import '../vehicles/vehicles_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeCases = mockRepairCases
        .where((repairCase) => repairCase.status != 'Finalizado')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Taller'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consultá el estado de tus vehículos y reparaciones.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.car_repair,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reparaciones activas',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${activeCases.length} vehículos en proceso',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimas reparaciones',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehiclesScreen(),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...activeCases.map(
              (repairCase) {
                final vehicle = mockVehicles.firstWhere(
                  (vehicle) => vehicle.id == repairCase.vehicleId,
                );

                return Card(
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
                            Expanded(
                              child: Text(
                                vehicle.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            StatusBadge(
                              status: repairCase.status,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(repairCase.description),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: repairCase.progress / 100,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${repairCase.progress}% completado',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}