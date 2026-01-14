import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

// features/auth/data/models/user_model.dart

@JsonSerializable()
class UserModel {
  final String id;
  final String nom;
  final String email;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    this.token,
  });

  /*factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);*/

  // Dans user_model.dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: (json['_id'] as String?) ?? '',
        nom: (json['nom'] as String?) ?? '', // ✅ Valeur par défaut
        email: (json['email'] as String?) ?? '', // ✅ Valeur par défaut
        role: (json['role'] as String?) ?? '', // ✅ Valeur par défaut
        token: json['token'] as String?,
        // autres champs...
      );
    } catch (e) {
      print("❌ Error in UserModel.fromJson: $e");
      print("❌ JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
