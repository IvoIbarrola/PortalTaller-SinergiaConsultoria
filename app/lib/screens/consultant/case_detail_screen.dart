import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../models/vehicle.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
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
  final Set<String> _completedTasks = {};
  final Set<String> _receivedDocuments = {};
  final List<String> _localActivity = [];
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
      return const Scaffold(
        body: Center(child: Text('Caso no encontrado.')),
      );
    }

    _selectedWorkshopId ??= repairCase.workshopId ??
      (appState.workshops.isNotEmpty ? appState.workshops.first.id : null);
    final vehicle = appState.getVehicleById(repairCase.vehicleId) ??
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
      appBar: AppBar(
        title: Text(repairCase.claimNumber),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detalle del caso',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                          color: AppTheme.tealInk,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(repairCase.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Text('Asegurado: ${insured?.name ?? 'Sin dato'}'),
                  Text('Ingreso: ${repairCase.entryDate.day}/${repairCase.entryDate.month}/${repairCase.entryDate.year}'),
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
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.tealInk,
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
                  Text('DATOS DE LA ASEGURADA',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.tealInk,
                          )),
                  const SizedBox(height: 8),
                  _detailRow('DNI / CUIT', repairCase.insuredDni),
                  _detailRow('Teléfono', repairCase.insuredPhone),
                  _detailRow('Email', repairCase.insuredEmail),
                  _detailRow('Patente', vehicle.plate),
                  _detailRow('Conductor', repairCase.driver),
                  _detailRow('Broker', repairCase.broker),
                  _detailRow('PAS', repairCase.pasName),
                  _detailRow('Fecha del siniestro', _formatDate(repairCase.incidentDate)),
                  _detailRow('Ubicación', repairCase.incidentLocation),
                  _detailRow('Terceros', repairCase.hasThirdParties ? 'Sí' : 'No'),
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
                  Text('CHECKLIST DE GESTIÓN · ${_completedTasks.length}/${_taskTitles.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.tealInk,
                          )),
                  const SizedBox(height: 8),
                  ..._taskTitles.map((title) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: _completedTasks.contains(title),
                        title: Text(title),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _completedTasks.add(title);
                          } else {
                            _completedTasks.remove(title);
                          }
                        }),
                      )),
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
                  Text('DOCUMENTACIÓN',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.tealInk,
                          )),
                  const SizedBox(height: 8),
                  ..._documentTitles.map((title) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: _receivedDocuments.contains(title),
                        title: Text(title),
                        subtitle: Text(_receivedDocuments.contains(title)
                            ? 'Recibido'
                            : 'Pendiente'),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _receivedDocuments.add(title);
                          } else {
                            _receivedDocuments.remove(title);
                          }
                        }),
                      )),
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
                  Text('NOVEDADES E HISTORIAL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.tealInk,
                          )),
                  const SizedBox(height: 8),
                  Text('Sincronizado desde ${repairCase.origin} — ${repairCase.claimBranch} — ${repairCase.claimType}'),
                  for (final item in _localActivity)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: Text(item),
                      subtitle: const Text('Registrado en esta sesión de demostración'),
                    ),
                  TextField(
                    controller: _activityController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Agregar novedad, llamada o respuesta de compañía',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () {
                        final note = _activityController.text.trim();
                        if (note.isEmpty) return;
                        setState(() {
                          _localActivity.insert(0, note);
                          _activityController.clear();
                        });
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
            value: _selectedWorkshopId,
            decoration: const InputDecoration(
              labelText: 'Asignar taller',
            ),
            items: appState.workshops
                .map(
                  (workshop) => DropdownMenuItem(
                    value: workshop.id,
                    child: Text(workshop.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              appState.assignWorkshop(widget.caseId, value);
              setState(() => _selectedWorkshopId = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RepairCaseStatus>(
            value: repairCase.status,
            decoration: const InputDecoration(
              labelText: 'Estado',
            ),
            items: RepairCaseStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              appState.updateCaseStatus(widget.caseId, value);
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Avance de reparación · ${repairCase.progress}%',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Slider(
            value: repairCase.progress.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (value) {
              appState.updateProgress(widget.caseId, value.round());
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          VehicleCard(
            vehicle: vehicle,
            status: repairCase.status.label,
          ),
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
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
