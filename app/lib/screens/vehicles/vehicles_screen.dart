import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/user.dart';
import '../../state/app_state.dart';
import '../../widgets/vehicles_card.dart';
import 'vehicle_detail_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final currentUser = appState.currentUser;
    final vehicles = appState.vehicles.where((vehicle) {
      return currentUser?.role != UserRole.insured ||
          vehicle.insuredUserId.isEmpty ||
          vehicle.insuredUserId == currentUser?.id;
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];

          RepairCase? repairCase;
          for (final item in appState.allCases) {
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
                  builder: (_) => VehicleDetailScreen(vehicle: vehicle),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
