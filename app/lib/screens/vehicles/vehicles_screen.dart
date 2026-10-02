import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
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

          final repairCase = mockRepairCases
              .where(
                (repairCase) => repairCase.vehicleId == vehicle.id,
              )
              .firstOrNull;

          return VehicleCard(
            vehicle: vehicle,
            status: repairCase?.status,
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