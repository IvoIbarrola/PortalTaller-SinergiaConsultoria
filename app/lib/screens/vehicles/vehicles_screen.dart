import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/repair_case.dart';
import '../../widgets/vehicles_card.dart';
import 'vehicle_detail_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis vehículos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockVehicles.length,
        itemBuilder: (context, index) {
          final vehicle = mockVehicles[index];

          RepairCase? repairCase;
          for (final item in mockRepairCases) {
            if (item.vehicleId == vehicle.id) {
              repairCase = item;
              break;
            }
          }

          return VehicleCard(
            vehicle: vehicle,
            status: repairCase?.status.label,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleDetailScreen(
                    vehicle: vehicle,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}