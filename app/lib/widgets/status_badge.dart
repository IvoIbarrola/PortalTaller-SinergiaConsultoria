import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'finalizado':
        return Colors.green;
      case 'en reparación':
        return Colors.blue;
      case 'en espera de repuestos':
        return Colors.orange;
      case 'pendiente':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}