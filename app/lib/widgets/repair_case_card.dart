import 'package:flutter/material.dart';

import '../models/repair_case.dart';
import '../models/vehicle.dart';
import 'status_badge.dart';

class RepairCaseCard extends StatelessWidget {
  final RepairCase repairCase;
  final Vehicle vehicle;
  final VoidCallback? onTap;

  const RepairCaseCard({
    super.key,
    required this.repairCase,
    required this.vehicle,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      repairCase.claimNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  StatusBadge(status: repairCase.status.label),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vehicle.displayName,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(repairCase.description),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (repairCase.progress / 100).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${repairCase.progress}% completado'),
                  if (repairCase.estimatedDeliveryDate != null)
                    Text(
                      'Entrega: ${_formatDate(repairCase.estimatedDeliveryDate!)}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
