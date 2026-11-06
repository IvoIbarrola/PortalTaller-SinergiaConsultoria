import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getColor(ColorScheme colors, Brightness brightness) {
    switch (status.toLowerCase()) {
      case 'finalizado':
      case 'entregado':
      case 'listo para entregar':
        return brightness == Brightness.dark
            ? const Color(0xFF81C784)
            : const Color(0xFF287F68);
      case 'en reparación':
      case 'inspección':
      case 'control de calidad':
        return colors.primary;
      case 'en espera de repuestos':
      case 'esperando repuestos':
      case 'aprobación':
        return brightness == Brightness.dark
            ? const Color(0xFFFFCC80)
            : const Color(0xFFAA681C);
      case 'pendiente':
      case 'nuevo':
      case 'en revisión':
      case 'presupuesto':
      case 'taller asignado':
      case 'recibido':
        return colors.onSurfaceVariant;
      default:
        return colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(
      Theme.of(context).colorScheme,
      Theme.of(context).brightness,
    );

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
