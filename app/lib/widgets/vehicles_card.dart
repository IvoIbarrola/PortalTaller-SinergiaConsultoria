import 'package:flutter/material.dart';

import '../models/vehicles.dart';
import 'status_badge.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final String? status;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 32,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.year} • ${vehicle.plate}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (status != null)
                      StatusBadge(status: status!),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}