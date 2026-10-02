import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';

class NewCaseScreen extends StatefulWidget {
  const NewCaseScreen({super.key});

  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  final _claimController = TextEditingController();
  final _descriptionController = TextEditingController();
  final appState = AppState();
  String? _selectedUserId;
  String? _selectedVehicleId;
  String? _selectedWorkshopId;

  @override
  void dispose() {
    _claimController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo caso'),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _claimController,
              decoration: const InputDecoration(
                labelText: 'Número de siniestro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _selectedUserId,
              decoration: const InputDecoration(
                labelText: 'Asegurado',
                border: OutlineInputBorder(),
              ),
              items: appState.users
                  .where((user) => user.role == UserRole.insured)
                  .map(
                    (user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedUserId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _selectedVehicleId,
              decoration: const InputDecoration(
                labelText: 'Vehículo',
                border: OutlineInputBorder(),
              ),
              items: appState.vehicles
                  .map(
                    (vehicle) => DropdownMenuItem(
                      value: vehicle.id,
                      child: Text('${vehicle.brand} ${vehicle.model}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedVehicleId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _selectedWorkshopId,
              decoration: const InputDecoration(
                labelText: 'Taller asignado (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sin asignar'),
                ),
                ...appState.workshops.map(
                  (workshop) => DropdownMenuItem<String?>(
                    value: workshop.id,
                    child: Text(workshop.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(
                () => _selectedWorkshopId = value == '' ? null : value,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (_selectedUserId == null || _selectedVehicleId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seleccioná asegurado y vehículo.'),
                    ),
                  );
                  return;
                }

                appState.createCase(
                  insuredUserId: _selectedUserId!,
                  vehicleId: _selectedVehicleId!,
                  claimNumber: _claimController.text.trim().isEmpty
                      ? 'SINI-${DateTime.now().millisecondsSinceEpoch}'
                      : _claimController.text.trim(),
                  description: _descriptionController.text.trim(),
                  workshopId: _selectedWorkshopId,
                );

                Navigator.pop(context);
              },
              child: const Text('Guardar caso'),
            ),
          ],
        ),
      ),
    );
  }
}
