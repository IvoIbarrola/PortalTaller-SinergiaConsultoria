import 'package:flutter/material.dart';

import '../../state/app_state.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final cases = appState.allCases.toList()
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cases.length,
        itemBuilder: (context, index) {
          final repairCase = cases[index];
          final estimated =
              repairCase.estimatedDeliveryDate ?? repairCase.entryDate;

          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.calendar_month)),
              title: Text(repairCase.claimNumber),
              subtitle: Text(
                'Ingreso: ${repairCase.entryDate.day}/${repairCase.entryDate.month}/${repairCase.entryDate.year}\n'
                'Entrega estimada: ${estimated.day}/${estimated.month}/${estimated.year}',
              ),
            ),
          );
        },
      ),
    );
  }
}
