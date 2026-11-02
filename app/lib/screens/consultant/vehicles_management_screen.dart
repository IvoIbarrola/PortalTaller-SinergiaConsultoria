import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';

class VehiclesManagementScreen extends StatelessWidget {
  const VehiclesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Vehículos')),
          body: appState.vehicles.isEmpty
              ? const Center(
                  child: Text('Todavía no hay vehículos registrados.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.vehicles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final vehicle = appState.vehicles[index];
                    final insured = appState.getUserById(vehicle.insuredUserId);
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.directions_car_outlined),
                        ),
                        title: Text(vehicle.displayName),
                        subtitle: Text(
                          '${vehicle.displayInfo} · ${insured?.name ?? 'Sin asegurado'}'
                          '${vehicle.vehicleType.isEmpty ? '' : '\n${vehicle.vehicleType}'}',
                        ),
                        isThreeLine: vehicle.vehicleType.isNotEmpty,
                        trailing: appState.isDemoMode
                            ? const Icon(Icons.edit_outlined)
                            : null,
                        onTap: appState.isDemoMode
                            ? () => _openVehicleForm(context, vehicle: vehicle)
                            : null,
                      ),
                    );
                  },
                ),
          floatingActionButton: appState.isDemoMode
              ? FloatingActionButton.extended(
                  onPressed: () => _openVehicleForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo vehículo'),
                )
              : null,
        );
      },
    );
  }

  Future<void> _openVehicleForm(
    BuildContext context, {
    Vehicle? vehicle,
  }) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: vehicle)),
    );
  }
}

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  final String? initialInsuredUserId;

  const VehicleFormScreen({super.key, this.vehicle, this.initialInsuredUserId});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _typeController = TextEditingController();
  final _trimController = TextEditingController();
  final _vinController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();
  final _appState = AppState();
  String? _insuredUserId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    _insuredUserId = vehicle?.insuredUserId.isNotEmpty == true
        ? vehicle!.insuredUserId
        : widget.initialInsuredUserId;
    _brandController.text = vehicle?.brand ?? '';
    _modelController.text = vehicle?.model ?? '';
    _yearController.text = (vehicle?.year ?? DateTime.now().year).toString();
    _plateController.text = vehicle?.plate ?? '';
    _colorController.text = vehicle?.color ?? '';
    _typeController.text = vehicle?.vehicleType ?? '';
    _trimController.text = vehicle?.trim ?? '';
    _vinController.text = vehicle?.vin ?? '';
    _mileageController.text = vehicle?.mileage?.toString() ?? '';
    _notesController.text = vehicle?.notes ?? '';
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _typeController.dispose();
    _trimController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = _insuredUserId;
    if (ownerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccioná un asegurado.')));
      return;
    }

    setState(() => _saving = true);
    try {
      final brand = _brandController.text.trim();
      final model = _modelController.text.trim();
      final year = int.parse(_yearController.text);
      final plate = _plateController.text.trim();
      final color = _colorController.text.trim();
      final vehicleType = _typeController.text.trim();
      final trim = _trimController.text.trim();
      final vin = _vinController.text.trim();
      final mileage = int.tryParse(_mileageController.text.trim());
      final notes = _notesController.text.trim();
      final vehicle = widget.vehicle;
      var vehicleId = vehicle?.id;
      if (vehicle == null) {
        await _appState.createVehicle(
          brand: brand,
          model: model,
          year: year,
          plate: plate,
          color: color,
          insuredUserId: ownerId,
          vehicleType: vehicleType,
          trim: trim,
          vin: vin,
          mileage: mileage,
          notes: notes,
        );
        vehicleId = _appState.vehicles.last.id;
      } else {
        await _appState.updateVehicle(
          Vehicle(
            id: vehicle.id,
            brand: brand,
            model: model,
            year: year,
            plate: plate,
            color: color,
            imageUrl: vehicle.imageUrl,
            insuredUserId: ownerId,
            vehicleType: vehicleType,
            trim: trim,
            vin: vin,
            mileage: mileage,
            notes: notes,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, vehicleId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el vehículo: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insuredUsers = _appState.users
        .where((user) => user.role == UserRole.insured)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle == null ? 'Nuevo vehículo' : 'Editar vehículo',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Marca *'),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Modelo *'),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Año *'),
              validator: (value) {
                final year = int.tryParse(value ?? '');
                if (year == null ||
                    year < 1900 ||
                    year > DateTime.now().year + 1) {
                  return 'Ingresá un año válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Patente *'),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _insuredUserId,
              decoration: const InputDecoration(labelText: 'Asegurado *'),
              items: insuredUsers
                  .map(
                    (user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Seleccioná un asegurado.' : null,
              onChanged: (value) => setState(() => _insuredUserId = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Tipo de vehículo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _trimController,
              decoration: const InputDecoration(labelText: 'Versión'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _vinController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Número de chasis / VIN',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kilometraje'),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return null;
                final mileage = int.tryParse(value!.trim());
                return mileage == null || mileage < 0
                    ? 'Ingresá un kilometraje válido.'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Observaciones'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Guardando…' : 'Guardar vehículo'),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) =>
      (value ?? '').trim().isEmpty ? 'Este campo es obligatorio.' : null;
}
