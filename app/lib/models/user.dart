enum UserRole { insured, consultant, workshop }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.insured:
        return 'Asegurado';
      case UserRole.consultant:
        return 'Consultoría';
      case UserRole.workshop:
        return 'Taller';
    }
  }
}

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? workshopId;
  final String email;
  final String phone;

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.workshopId,
    this.email = '',
    this.phone = '',
  });

  User copyWith({String? name, String? email, String? phone}) => User(
    id: id,
    name: name ?? this.name,
    role: role,
    workshopId: workshopId,
    email: email ?? this.email,
    phone: phone ?? this.phone,
  );
}
