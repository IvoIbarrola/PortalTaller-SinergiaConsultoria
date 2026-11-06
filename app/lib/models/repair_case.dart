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
      case RepairCaseStatus.newCase: return 'Nuevo ingreso';
      case RepairCaseStatus.inReview: return 'En revisión';
      case RepairCaseStatus.workshopAssigned: return 'Taller asignado';
      case RepairCaseStatus.received: return 'Recibido';
      case RepairCaseStatus.inspection: return 'Inspección';
      case RepairCaseStatus.estimate: return 'Presupuesto';
      case RepairCaseStatus.approval: return 'Aprobación';
      case RepairCaseStatus.awaitingParts: return 'Esperando repuestos';
      case RepairCaseStatus.inRepair: return 'En reparación';
      case RepairCaseStatus.qualityControl: return 'Control de calidad';
      case RepairCaseStatus.readyForDelivery: return 'Listo para entregar';
      case RepairCaseStatus.delivered: return 'Entregado';
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

  // Datos administrativos de la ficha de siniestro.
  final String insurerCompany;
  final String claimBranch;
  final String claimType;
  final bool fastTrack;
  final String companyClaimNumber;
  final String insuredDni;
  final String insuredPhone;
  final String insuredEmail;
  final String driver;
  final String broker;
  final String pasName;
  final DateTime? incidentDate;
  final String incidentLocation;
  final String origin;
  final String jotformId;
  final String attachmentFilename;
  final String responsible;
  final bool hasThirdParties;
  final DateTime? registeredAt;

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
    this.insurerCompany = '',
    this.claimBranch = 'Automotor',
    this.claimType = '',
    this.fastTrack = false,
    this.companyClaimNumber = '',
    this.insuredDni = '',
    this.insuredPhone = '',
    this.insuredEmail = '',
    this.driver = '',
    this.broker = '',
    this.pasName = '',
    this.incidentDate,
    this.incidentLocation = '',
    this.origin = 'Portal Taller',
    this.jotformId = '',
    this.attachmentFilename = '',
    this.responsible = '',
    this.hasThirdParties = false,
    this.registeredAt,
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
    String? insurerCompany,
    String? claimBranch,
    String? claimType,
    bool? fastTrack,
    String? companyClaimNumber,
    String? insuredDni,
    String? insuredPhone,
    String? insuredEmail,
    String? driver,
    String? broker,
    String? pasName,
    DateTime? incidentDate,
    String? incidentLocation,
    String? origin,
    String? jotformId,
    String? attachmentFilename,
    String? responsible,
    bool? hasThirdParties,
    DateTime? registeredAt,
  }) {
    return RepairCase(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      insuredUserId: insuredUserId ?? this.insuredUserId,
      claimNumber: claimNumber ?? this.claimNumber,
      description: description ?? this.description,
      status: status ?? this.status,
      entryDate: entryDate ?? this.entryDate,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      progress: progress ?? this.progress,
      workshopId: workshopId ?? this.workshopId,
      insurerCompany: insurerCompany ?? this.insurerCompany,
      claimBranch: claimBranch ?? this.claimBranch,
      claimType: claimType ?? this.claimType,
      fastTrack: fastTrack ?? this.fastTrack,
      companyClaimNumber: companyClaimNumber ?? this.companyClaimNumber,
      insuredDni: insuredDni ?? this.insuredDni,
      insuredPhone: insuredPhone ?? this.insuredPhone,
      insuredEmail: insuredEmail ?? this.insuredEmail,
      driver: driver ?? this.driver,
      broker: broker ?? this.broker,
      pasName: pasName ?? this.pasName,
      incidentDate: incidentDate ?? this.incidentDate,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      origin: origin ?? this.origin,
      jotformId: jotformId ?? this.jotformId,
      attachmentFilename: attachmentFilename ?? this.attachmentFilename,
      responsible: responsible ?? this.responsible,
      hasThirdParties: hasThirdParties ?? this.hasThirdParties,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}
