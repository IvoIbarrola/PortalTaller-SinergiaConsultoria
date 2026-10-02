enum RepairCaseStatus {
  pending,
  inRepair,
  awaitingParts,
  finished,
}

extension RepairCaseStatusX on RepairCaseStatus {
  String get label {
    switch (this) {
      case RepairCaseStatus.pending:
        return 'Pendiente';
      case RepairCaseStatus.inRepair:
        return 'En reparación';
      case RepairCaseStatus.awaitingParts:
        return 'En espera de repuestos';
      case RepairCaseStatus.finished:
        return 'Finalizado';
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
