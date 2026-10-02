class RepairCase {
  final String id;
  final String vehicleId;
  final String claimNumber;
  final String description;
  final String status;
  final DateTime entryDate;
  final DateTime? estimatedDeliveryDate;
  final int progress;

  const RepairCase({
    required this.id,
    required this.vehicleId,
    required this.claimNumber,
    required this.description,
    required this.status,
    required this.entryDate,
    this.estimatedDeliveryDate,
    required this.progress,
  });
}