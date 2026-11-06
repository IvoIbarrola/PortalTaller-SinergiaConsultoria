import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
import '../../widgets/progress_timeline.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vehicle_card.dart';
import '../insured/insured_chat_screen.dart';
import '../workshop/workshop_photos_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  final appState = AppState();
  String? _selectedWorkshopId;
  final TextEditingController _activityController = TextEditingController();

  static const List<String> _taskTitles = [
    'Denuncia recibida vía JotForm',
    'Ingresar en compañía',
    'Contactar al asegurado',
    'Enviar orden fast track (24hs)',
    'Relevamiento',
    'CLEAS vinculación',
    'CLEAS dictamen',
  ];
  static const List<String> _documentTitles = [
    'Licencia de conducir',
    'Cédula verde / azul',
    'Denuncia policial',
  ];

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repairCase = appState.getCaseById(widget.caseId);

    if (repairCase == null) {
      return const Scaffold(body: Center(child: Text('Caso no encontrado.')));
    }

    _selectedWorkshopId ??=
        repairCase.workshopId ??
        (appState.activeWorkshops.isNotEmpty
            ? appState.activeWorkshops.first.id
            : null);
    final vehicle =
        appState.getVehicleById(repairCase.vehicleId) ??
        const Vehicle(
          id: '',
          brand: 'Vehículo',
          model: 'Sin información',
          year: 0,
          plate: '',
          color: '',
          imageUrl: '',
        );
    final insured = appState.getUserById(repairCase.insuredUserId);
    final progressIndex = ((repairCase.progress / 100) * 3).round().clamp(0, 3);

    return Scaffold(
      appBar: AppBar(title: Text(repairCase.claimNumber)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ficha de siniestro',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              StatusBadge(status: repairCase.status.label),
            ],
          ),
          const SizedBox(height: 20),
          ProgressTimeline(
            steps: const ['Inicio', 'Revisión', 'Reparación', 'Entrega'],
            currentIndex: progressIndex,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMACIÓN DEL CASO',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    repairCase.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('Asegurado: ${insured?.name ?? 'Sin dato'}'),
                  Text(
                    'Ingreso: ${repairCase.entryDate.day}/${repairCase.entryDate.month}/${repairCase.entryDate.year}',
                  ),
                  if (repairCase.estimatedDeliveryDate != null)
                    Text(
                      'Entrega estimada: ${repairCase.estimatedDeliveryDate!.day}/${repairCase.estimatedDeliveryDate!.month}/${repairCase.estimatedDeliveryDate!.year}',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'ENCABEZADO DEL SINIESTRO',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                      if (repairCase.fastTrack)
                        const Chip(
                          avatar: Icon(Icons.bolt, size: 18),
                          label: Text('Fast track'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _detailRow('Compañía', repairCase.insurerCompany),
                  _detailRow('Ramo', repairCase.claimBranch),
                  _detailRow('Tipo', repairCase.claimType),
                  _detailRow('N.º de compañía', repairCase.companyClaimNumber),
                  _detailRow('Responsable', repairCase.responsible),
                  _detailRow('Origen', repairCase.origin),
                  _detailRow('ID JotForm', repairCase.jotformId),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATOS DE LA ASEGURADA',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _detailRow('DNI / CUIT', repairCase.insuredDni),
                  _detailRow('Teléfono', repairCase.insuredPhone),
                  _detailRow('Email', repairCase.insuredEmail),
                  _detailRow('Patente', vehicle.plate),
                  _detailRow('Conductor', repairCase.driver),
                  _detailRow('Broker', repairCase.broker),
                  _detailRow('PAS', repairCase.pasName),
                  _detailRow(
                    'Fecha del siniestro',
                    _formatDate(repairCase.incidentDate),
                  ),
                  _detailRow('Ubicación', repairCase.incidentLocation),
                  _detailRow(
                    'Terceros',
                    repairCase.hasThirdParties ? 'Sí' : 'No',
                  ),
                  _detailRow('Adjunto', repairCase.attachmentFilename),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESUMEN',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _detailRow(
                    'Días en gestión',
                    '${DateTime.now().difference(repairCase.entryDate).inDays} días',
                  ),
                  _detailRow('Ingresado', _formatDate(repairCase.entryDate)),
                  _detailRow('Origen', repairCase.origin),
                  _detailRow(
                    'Terceros',
                    repairCase.hasThirdParties ? 'Sí' : 'No',
                  ),
                  _detailRow(
                    'Responsable',
                    repairCase.responsible.isEmpty
                        ? 'Sin asignar'
                        : repairCase.responsible,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHECKLIST DE GESTIÓN · ${_taskTitles.where((task) => appState.isChecklistCompleted(widget.caseId, task)).length}/${_taskTitles.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._taskTitles.map(
                    (title) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: appState.isChecklistCompleted(
                        widget.caseId,
                        title,
                      ),
                      title: Text(title),
                      onChanged: (value) async {
                        try {
                          await appState.setChecklistCompleted(
                            widget.caseId,
                            title,
                            value == true,
                          );
                          if (mounted) setState(() {});
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No se pudo guardar el checklist: $error',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOCUMENTACIÓN',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._documentTitles.map(
                    (title) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: appState.isDocumentReceived(widget.caseId, title),
                      title: Text(title),
                      subtitle: Text(
                        appState.isDocumentReceived(widget.caseId, title)
                            ? 'Recibido'
                            : 'Pendiente',
                      ),
                      onChanged: (value) async {
                        try {
                          await appState.setDocumentReceived(
                            widget.caseId,
                            title,
                            value == true,
                          );
                          if (mounted) setState(() {});
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No se pudo guardar la documentación: $error',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOVEDADES E HISTORIAL',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sincronizado desde ${repairCase.origin} — ${repairCase.claimBranch} — ${repairCase.claimType}',
                  ),
                  for (final item in appState.activityForCase(widget.caseId))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: Text(item),
                      subtitle: const Text('Guardado en este dispositivo'),
                    ),
                  TextField(
                    controller: _activityController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText:
                          'Agregar novedad, llamada o respuesta de compañía',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final note = _activityController.text.trim();
                        if (note.isEmpty) return;
                        try {
                          await appState.addCaseActivity(widget.caseId, note);
                          if (!context.mounted) return;
                          setState(_activityController.clear);
                        } catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No se pudo guardar la novedad: $error',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedWorkshopId,
            decoration: const InputDecoration(labelText: 'Asignar taller'),
            items: appState.workshops
                .where(
                  (workshop) =>
                      workshop.isActive || workshop.id == repairCase.workshopId,
                )
                .map(
                  (workshop) => DropdownMenuItem(
                    value: workshop.id,
                    child: Text(workshop.name),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              try {
                await appState.assignWorkshop(widget.caseId, value);
                if (mounted) setState(() => _selectedWorkshopId = value);
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo asignar el taller: $error'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RepairCaseStatus>(
            initialValue: repairCase.status,
            decoration: const InputDecoration(labelText: 'Estado'),
            items: RepairCaseStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              try {
                await appState.updateCaseStatus(widget.caseId, value);
                if (mounted) setState(() {});
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo actualizar el estado: $error'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Avance de reparación · ${repairCase.progress}%',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: repairCase.progress.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (value) async {
              try {
                await appState.updateProgress(widget.caseId, value.round());
                if (mounted) setState(() {});
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo guardar el avance: $error'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          VehicleCard(vehicle: vehicle, status: repairCase.status.label),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InsuredChatScreen(caseId: repairCase.id),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Abrir chat'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkshopPhotosScreen(
                    caseId: repairCase.id,
                    claimNumber: repairCase.claimNumber,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Ver registro fotográfico'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin completar';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
