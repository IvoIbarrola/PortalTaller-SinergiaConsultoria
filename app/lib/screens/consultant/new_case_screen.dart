import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';
import 'vehicles_management_screen.dart';

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
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Nuevo caso')),
        body: Form(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _claimController,
                decoration: const InputDecoration(
                  labelText: 'Número de siniestro',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _selectedUserId,
                decoration: const InputDecoration(labelText: 'Asegurado'),
                items: appState.users
                    .where((user) => user.role == UserRole.insured)
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedUserId = value;
                  _selectedVehicleId = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _selectedVehicleId,
                decoration: const InputDecoration(labelText: 'Vehículo'),
                items: appState.vehicles
                    .where(
                      (vehicle) =>
                          _selectedUserId == null ||
                          vehicle.insuredUserId.isEmpty ||
                          vehicle.insuredUserId == _selectedUserId,
                    )
                    .map(
                      (vehicle) => DropdownMenuItem(
                        value: vehicle.id,
                        child: Text('${vehicle.brand} ${vehicle.model}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedVehicleId = value),
              ),
              if (_selectedUserId != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final vehicleId = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleFormScreen(
                            initialInsuredUserId: _selectedUserId,
                          ),
                        ),
                      );
                      if (!mounted || vehicleId == null) return;
                      setState(() => _selectedVehicleId = vehicleId);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar vehículo para este asegurado'),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _selectedWorkshopId,
                decoration: const InputDecoration(
                  labelText: 'Taller asignado (opcional)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Sin asignar'),
                  ),
                  ...appState.activeWorkshops.map(
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
                onPressed: () async {
                  if (_selectedUserId == null || _selectedVehicleId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seleccioná asegurado y vehículo.'),
                      ),
                    );
                    return;
                  }

                  try {
                    await appState.createCase(
                      insuredUserId: _selectedUserId!,
                      vehicleId: _selectedVehicleId!,
                      claimNumber: _claimController.text.trim().isEmpty
                          ? 'SINI-${DateTime.now().millisecondsSinceEpoch}'
                          : _claimController.text.trim(),
                      description: _descriptionController.text.trim().isEmpty
                          ? 'Caso de demostración sin descripción.'
                          : _descriptionController.text.trim(),
                      workshopId: _selectedWorkshopId,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No se pudo guardar el caso: $error'),
                      ),
                    );
                  }
                },
                child: const Text('Guardar caso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
