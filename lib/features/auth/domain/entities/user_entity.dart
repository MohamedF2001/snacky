// features/auth/domain/entities/user_entity.dart

class UserEntity {
  final String id;
  final String nom; // Changé de name à nom
  final String email;
  final String role;
  final String? token;
  final String? telephone;
  final String? adresse;

  UserEntity({
    required this.id,
    required this.nom, // Changé de name à nom
    required this.email,
    required this.role,
    this.token,
    this.telephone,
    this.adresse,
  });

  bool get isAdmin => role == 'Admin';
}
