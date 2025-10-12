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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
