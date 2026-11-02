import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../state/app_state.dart';
import '../../widgets/repair_case_card.dart';
import 'case_detail_screen.dart';

class ConsultantStatisticsScreen extends StatefulWidget {
  const ConsultantStatisticsScreen({super.key});

  @override
  State<ConsultantStatisticsScreen> createState() =>
      _ConsultantStatisticsScreenState();
}

class _ConsultantStatisticsScreenState
    extends State<ConsultantStatisticsScreen> {
  final _appState = AppState();
  final _searchController = TextEditingController();
  RepairCaseStatus? _status;
  String? _workshopId;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RepairCase> _filteredCases(List<RepairCase> cases) {
    final query = _searchController.text.trim().toLowerCase();
    return cases.where((item) {
      if (_status != null && item.status != _status) return false;
      if (_workshopId != null) {
        if (_workshopId == '') {
          if (item.workshopId != null) return false;
        } else if (item.workshopId != _workshopId) {
          return false;
        }
      }
      if (_dateRange != null) {
        final date = item.entryDate;
        final start = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final end = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
          23,
          59,
          59,
        );
        if (date.isBefore(start) || date.isAfter(end)) return false;
      }
      if (query.isEmpty) return true;
      final vehicle = _appState.getVehicleById(item.vehicleId);
      final insured = _appState.getUserById(item.insuredUserId);
      return item.claimNumber.toLowerCase().contains(query) ||
          (vehicle?.plate.toLowerCase().contains(query) ?? false) ||
          (insured?.name.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _dateRange,
      helpText: 'Filtrar por fecha de ingreso',
      saveText: 'Aplicar',
    );
    if (range != null) setState(() => _dateRange = range);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        final filtered = _filteredCases(_appState.allCases);
        final activeCount = filtered
            .where((item) => item.status != RepairCaseStatus.delivered)
            .length;
        final deliveredCount = filtered
            .where((item) => item.status == RepairCaseStatus.delivered)
            .length;
        final averageProgress = filtered.isEmpty
            ? 0
            : filtered.fold<int>(0, (total, item) => total + item.progress) ~/
                  filtered.length;
        final today = DateUtils.dateOnly(DateTime.now());
        final upcoming =
            filtered
                .where(
                  (item) =>
                      item.status != RepairCaseStatus.delivered &&
                      item.estimatedDeliveryDate != null &&
                      !DateUtils.dateOnly(item.estimatedDeliveryDate!)
                          .isBefore(today),
                )
                .toList()
              ..sort(
                (a, b) => a.estimatedDeliveryDate!.compareTo(
                  b.estimatedDeliveryDate!,
                ),
              );
        final statusCounts = {
          for (final status in RepairCaseStatus.values)
            status: filtered.where((item) => item.status == status).length,
        };
        final workshopCounts = <String, int>{};
        for (final item in filtered) {
          if (item.workshopId == null) continue;
          workshopCounts.update(
            item.workshopId!,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }
        final sortedWorkshopIds = workshopCounts.keys.toList()
          ..sort((a, b) => workshopCounts[b]!.compareTo(workshopCounts[a]!));

        return Scaffold(
          appBar: AppBar(title: const Text('Estadísticas')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Buscar siniestro, patente o asegurado',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RepairCaseStatus?>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: [
                  const DropdownMenuItem<RepairCaseStatus?>(
                    value: null,
                    child: Text('Todos los estados'),
                  ),
                  ...RepairCaseStatus.values.map(
                    (status) => DropdownMenuItem<RepairCaseStatus?>(
                      value: status,
                      child: Text(status.label),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _status = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _workshopId,
                decoration: const InputDecoration(labelText: 'Taller'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos los talleres'),
                  ),
                  ..._appState.workshops.map(
                    (workshop) => DropdownMenuItem<String?>(
                      value: workshop.id,
                      child: Text(workshop.name),
                    ),
                  ),
                  const DropdownMenuItem<String?>(
                    value: '',
                    child: Text('Sin asignar'),
                  ),
                ],
                onChanged: (value) => setState(() => _workshopId = value),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range_outlined),
                label: Text(
                  _dateRange == null
                      ? 'Elegir período de ingreso'
                      : '${_formatDate(_dateRange!.start)} – ${_formatDate(_dateRange!.end)}',
                ),
              ),
              if (_status != null ||
                  _workshopId != null ||
                  _dateRange != null ||
                  _searchController.text.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _status = null;
                        _workshopId = null;
                        _dateRange = null;
                      });
                    },
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Limpiar filtros'),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Resumen · ${filtered.length} casos',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricCard(label: 'Activos', value: '$activeCount'),
                  _MetricCard(label: 'Entregados', value: '$deliveredCount'),
                  _MetricCard(
                    label: 'Avance promedio',
                    value: '$averageProgress%',
                  ),
                  _MetricCard(
                    label: 'Próximas entregas',
                    value: '${upcoming.length}',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Casos por estado',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...RepairCaseStatus.values
                  .where((status) => statusCounts[status]! > 0)
                  .map(
                    (status) => _CountBar(
                      label: status.label,
                      value: statusCounts[status]!,
                      total: filtered.length,
                    ),
                  ),
              const SizedBox(height: 16),
              Text(
                'Casos por taller',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (sortedWorkshopIds.isEmpty)
                const Text('No hay casos asignados a talleres en este filtro.')
              else
                ...sortedWorkshopIds.map((id) {
                  final workshop = _appState.getWorkshopById(id);
                  return _CountBar(
                    label: workshop?.name ?? 'Taller no disponible',
                    value: workshopCounts[id]!,
                    total: filtered.length,
                  );
                }),
              finalUnassignedCount(filtered) > 0
                  ? _CountBar(
                      label: 'Sin asignar',
                      value: finalUnassignedCount(filtered),
                      total: filtered.length,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16),
              Text(
                'Próximas fechas de entrega',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (upcoming.isEmpty)
                const Text('No hay fechas de entrega próximas registradas.')
              else
                ...upcoming
                    .take(5)
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_outlined),
                        title: Text(item.claimNumber),
                        subtitle: Text(
                          '${_appState.getVehicleById(item.vehicleId)?.displayName ?? 'Vehículo'} · ${item.status.label}',
                        ),
                        trailing: Text(
                          _formatDate(item.estimatedDeliveryDate!),
                        ),
                        onTap: () => _openCase(context, item.id),
                      ),
                    ),
              const SizedBox(height: 16),
              Text(
                'Casos incluidos · ${filtered.length}',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (filtered.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No hay casos que coincidan con los filtros.'),
                  ),
                )
              else
                ...filtered.map((item) {
                  final vehicle = _appState.getVehicleById(item.vehicleId);
                  if (vehicle == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RepairCaseCard(
                      repairCase: item,
                      vehicle: vehicle,
                      onTap: () => _openCase(context, item.id),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  int finalUnassignedCount(List<RepairCase> cases) =>
      cases.where((item) => item.workshopId == null).length;

  Future<void> _openCase(BuildContext context, String caseId) =>
      Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => CaseDetailScreen(caseId: caseId)),
      );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 42) / 2,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class _CountBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;

  const _CountBar({
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label · $value'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: total == 0 ? 0 : value / total,
          semanticsLabel: '$label, $value de $total casos',
        ),
      ],
    ),
  );
}
