import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'finalizado':
      case 'entregado':
      case 'listo para entregar':
        return AppTheme.success;
      case 'en reparación':
      case 'inspección':
      case 'control de calidad':
        return AppTheme.tealInk;
      case 'en espera de repuestos':
      case 'esperando repuestos':
      case 'aprobación':
        return AppTheme.warning;
      case 'pendiente':
      case 'nuevo':
      case 'en revisión':
      case 'presupuesto':
      case 'taller asignado':
      case 'recibido':
        return AppTheme.mutedText;
      default:
        return AppTheme.attention;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}