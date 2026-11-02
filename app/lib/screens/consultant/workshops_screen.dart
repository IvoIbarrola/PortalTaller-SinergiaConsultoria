import 'package:flutter/material.dart';

import '../../models/workshop.dart';
import '../../state/app_state.dart';

class WorkshopsScreen extends StatelessWidget {
  const WorkshopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Talleres')),
          body: appState.workshops.isEmpty
              ? const Center(
                  child: Text('Todavía no hay talleres registrados.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.workshops.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final workshop = appState.workshops[index];
                    final caseCount = appState.allCases
                        .where((item) => item.workshopId == workshop.id)
                        .length;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: workshop.isActive
                                  ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                  : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              child: Icon(
                                Icons.handyman_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workshop.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text('${workshop.city} · $caseCount casos'),
                                  Text(
                                    'Calificación: ${workshop.rating.toStringAsFixed(1)} / 5',
                                  ),
                                  if (workshop.phone.isNotEmpty)
                                    Text(workshop.phone),
                                  if (workshop.address.isNotEmpty)
                                    Text(workshop.address),
                                  if (workshop.contactName.isNotEmpty)
                                    Text('Contacto: ${workshop.contactName}'),
                                  if (workshop.specialties.isNotEmpty)
                                    Text(workshop.specialties.join(' · ')),
                                  const SizedBox(height: 4),
                                  Text(
                                    workshop.isActive ? 'Activo' : 'Inactivo',
                                    style: TextStyle(
                                      color: workshop.isActive
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (appState.isDemoMode)
                              PopupMenuButton<String>(
                                tooltip: 'Administrar ${workshop.name}',
                                onSelected: (action) async {
                                  if (action == 'edit') {
                                    await _openWorkshopForm(
                                      context,
                                      workshop: workshop,
                                    );
                                  } else {
                                    try {
                                      await appState.setWorkshopActive(
                                        workshop.id,
                                        !workshop.isActive,
                                      );
                                    } catch (error) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'No se pudo actualizar el taller: $error',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(
                                      workshop.isActive
                                          ? 'Desactivar'
                                          : 'Reactivar',
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: appState.isDemoMode
              ? FloatingActionButton.extended(
                  onPressed: () => _openWorkshopForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo taller'),
                )
              : null,
        );
      },
    );
  }

  Future<void> _openWorkshopForm(
    BuildContext context, {
    Workshop? workshop,
  }) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => WorkshopFormScreen(workshop: workshop)),
    );
  }
}

class WorkshopFormScreen extends StatefulWidget {
  final Workshop? workshop;

  const WorkshopFormScreen({super.key, this.workshop});

  @override
  State<WorkshopFormScreen> createState() => _WorkshopFormScreenState();
}

class _WorkshopFormScreenState extends State<WorkshopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _ratingController = TextEditingController();
  final _specialtiesController = TextEditingController();
  final _appState = AppState();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final workshop = widget.workshop;
    _nameController.text = workshop?.name ?? '';
    _cityController.text = workshop?.city ?? '';
    _phoneController.text = workshop?.phone ?? '';
    _addressController.text = workshop?.address ?? '';
    _contactController.text = workshop?.contactName ?? '';
    _ratingController.text = (workshop?.rating ?? 0).toStringAsFixed(1);
    _specialtiesController.text = workshop?.specialties.join(', ') ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _ratingController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final specialties = _specialtiesController.text.split(',');
    try {
      final workshop = widget.workshop;
      if (workshop == null) {
        await _appState.createWorkshop(
          name: _nameController.text,
          city: _cityController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          contactName: _contactController.text,
          rating: double.parse(_ratingController.text.replaceAll(',', '.')),
          specialties: specialties,
        );
      } else {
        await _appState.updateWorkshop(
          workshop.copyWith(
            name: _nameController.text,
            city: _cityController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            contactName: _contactController.text,
            rating: double.parse(_ratingController.text.replaceAll(',', '.')),
            specialties: specialties,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el taller: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.workshop == null ? 'Nuevo taller' : 'Editar taller'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre *'),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'Ciudad *'),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Teléfono'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactController,
            decoration: const InputDecoration(labelText: 'Persona de contacto'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ratingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Calificación (0 a 5)',
            ),
            validator: (value) {
              final rating = double.tryParse(
                (value ?? '').replaceAll(',', '.'),
              );
              if (rating == null || rating < 0 || rating > 5) {
                return 'Ingresá una calificación entre 0 y 5.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _specialtiesController,
            decoration: const InputDecoration(
              labelText: 'Especialidades',
              hintText: 'Chapa y pintura, Mecánica',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Separá las especialidades con comas.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Guardando…' : 'Guardar taller'),
          ),
        ],
      ),
    ),
  );

  String? _requiredValidator(String? value) =>
      (value ?? '').trim().isEmpty ? 'Este campo es obligatorio.' : null;
}
