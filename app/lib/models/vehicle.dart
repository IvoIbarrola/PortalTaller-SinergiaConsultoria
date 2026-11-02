class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final String color;
  final String imageUrl;
  final String insuredUserId;
  final String vehicleType;
  final String trim;
  final String vin;
  final int? mileage;
  final String notes;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
    required this.imageUrl,
    this.insuredUserId = '',
    this.vehicleType = '',
    this.trim = '',
    this.vin = '',
    this.mileage,
    this.notes = '',
  });

  String get displayName => '$brand $model';

  String get displayInfo => '$year • $plate';

  Vehicle copyWith({
    String? brand,
    String? model,
    int? year,
    String? plate,
    String? color,
    String? imageUrl,
    String? insuredUserId,
    String? vehicleType,
    String? trim,
    String? vin,
    int? mileage,
    String? notes,
  }) => Vehicle(
    id: id,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year ?? this.year,
    plate: plate ?? this.plate,
    color: color ?? this.color,
    imageUrl: imageUrl ?? this.imageUrl,
    insuredUserId: insuredUserId ?? this.insuredUserId,
    vehicleType: vehicleType ?? this.vehicleType,
    trim: trim ?? this.trim,
    vin: vin ?? this.vin,
    mileage: mileage ?? this.mileage,
    notes: notes ?? this.notes,
  );
}
