enum RepairCaseStatus {
  newCase,
  inReview,
  workshopAssigned,
  received,
  inspection,
  estimate,
  approval,
  awaitingParts,
  inRepair,
  qualityControl,
  readyForDelivery,
  delivered,
}

extension RepairCaseStatusX on RepairCaseStatus {
  String get label {
    switch (this) {
      case RepairCaseStatus.newCase:
        return 'Nuevo';
      case RepairCaseStatus.inReview:
        return 'En revisión';
      case RepairCaseStatus.workshopAssigned:
        return 'Taller asignado';
      case RepairCaseStatus.received:
        return 'Recibido';
      case RepairCaseStatus.inspection:
        return 'Inspección';
      case RepairCaseStatus.estimate:
        return 'Presupuesto';
      case RepairCaseStatus.approval:
        return 'Aprobación';
      case RepairCaseStatus.awaitingParts:
        return 'Esperando repuestos';
      case RepairCaseStatus.inRepair:
        return 'En reparación';
      case RepairCaseStatus.qualityControl:
        return 'Control de calidad';
      case RepairCaseStatus.readyForDelivery:
        return 'Listo para entregar';
      case RepairCaseStatus.delivered:
        return 'Entregado';
    }
  }
}

class RepairCase {
  final String id;
  final String vehicleId;
  final String insuredUserId;
  final String claimNumber;
  final String description;
  final RepairCaseStatus status;
  final DateTime entryDate;
  final DateTime? estimatedDeliveryDate;
  final int progress;
  final String? workshopId;

  const RepairCase({
    required this.id,
    required this.vehicleId,
    required this.insuredUserId,
    required this.claimNumber,
    required this.description,
    required this.status,
    required this.entryDate,
    this.estimatedDeliveryDate,
    required this.progress,
    this.workshopId,
  });

  RepairCase copyWith({
    String? id,
    String? vehicleId,
    String? insuredUserId,
    String? claimNumber,
    String? description,
    RepairCaseStatus? status,
    DateTime? entryDate,
    DateTime? estimatedDeliveryDate,
    int? progress,
    String? workshopId,
  }) {
    return RepairCase(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      insuredUserId: insuredUserId ?? this.insuredUserId,
      claimNumber: claimNumber ?? this.claimNumber,
      description: description ?? this.description,
      status: status ?? this.status,
      entryDate: entryDate ?? this.entryDate,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      progress: progress ?? this.progress,
      workshopId: workshopId ?? this.workshopId,
    );
  }
}