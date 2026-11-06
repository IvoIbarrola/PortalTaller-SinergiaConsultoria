class Workshop {
  final String id;
  final String name;
  final String city;
  final String phone;
  final double rating;
  final String address;
  final String contactName;
  final List<String> specialties;
  final bool isActive;

  const Workshop({
    required this.id,
    required this.name,
    required this.city,
    required this.phone,
    required this.rating,
    this.address = '',
    this.contactName = '',
    this.specialties = const [],
    this.isActive = true,
  });

  Workshop copyWith({
    String? name,
    String? city,
    String? phone,
    double? rating,
    String? address,
    String? contactName,
    List<String>? specialties,
    bool? isActive,
  }) => Workshop(
    id: id,
    name: name ?? this.name,
    city: city ?? this.city,
    phone: phone ?? this.phone,
    rating: rating ?? this.rating,
    address: address ?? this.address,
    contactName: contactName ?? this.contactName,
    specialties: specialties ?? this.specialties,
    isActive: isActive ?? this.isActive,
  );
}
