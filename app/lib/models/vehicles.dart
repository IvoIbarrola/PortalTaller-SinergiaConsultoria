class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final String color;
  final String imageUrl;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
    required this.imageUrl,
  });

  String get displayName => '$brand $model';
}