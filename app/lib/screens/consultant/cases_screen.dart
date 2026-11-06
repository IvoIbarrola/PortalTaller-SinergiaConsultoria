import 'package:flutter/material.dart';

import '../../models/repair_case.dart';
import '../../state/app_state.dart';
import '../../widgets/repair_case_card.dart';
import 'case_detail_screen.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  final _appState = AppState();
  final _searchController = TextEditingController();
  RepairCaseStatus? _status;
  String? _workshopId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _appState,
    builder: (context, _) {
      final query = _searchController.text.trim().toLowerCase();
      final cases = _appState.allCases.where((item) {
        if (_status != null && item.status != _status) return false;
        if (_workshopId != null) {
          if (_workshopId == 'unassigned') {
            if (item.workshopId != null) return false;
          } else if (item.workshopId != _workshopId) {
            return false;
          }
        }
        if (query.isEmpty) return true;
        final vehicle = _appState.getVehicleById(item.vehicleId);
        final insured = _appState.getUserById(item.insuredUserId);
        return item.claimNumber.toLowerCase().contains(query) ||
            (vehicle?.plate.toLowerCase().contains(query) ?? false) ||
            (insured?.name.toLowerCase().contains(query) ?? false);
      }).toList();

      return Scaffold(
        appBar: AppBar(title: const Text('Todos los casos')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<RepairCaseStatus?>(
                          initialValue: _status,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                          ),
                          items: [
                            const DropdownMenuItem<RepairCaseStatus?>(
                              value: null,
                              child: Text('Todos'),
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
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _workshopId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Taller',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ..._appState.workshops.map(
                              (workshop) => DropdownMenuItem<String?>(
                                value: workshop.id,
                                child: Text(workshop.name),
                              ),
                            ),
                            const DropdownMenuItem<String?>(
                              value: 'unassigned',
                              child: Text('Sin asignar'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _workshopId = value),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${cases.length} de ${_appState.allCases.length} casos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: cases.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay casos que coincidan con los filtros.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: cases.length,
                      itemBuilder: (context, index) {
                        final repairCase = cases[index];
                        final vehicle = _appState.getVehicleById(
                          repairCase.vehicleId,
                        );
                        if (vehicle == null) return const SizedBox.shrink();
                        return RepairCaseCard(
                          repairCase: repairCase,
                          vehicle: vehicle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CaseDetailScreen(caseId: repairCase.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}
