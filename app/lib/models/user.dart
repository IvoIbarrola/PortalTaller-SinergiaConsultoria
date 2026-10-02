enum UserRole {
  insured,
  consultant,
  workshop,
}

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

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.workshopId,
  });
}
