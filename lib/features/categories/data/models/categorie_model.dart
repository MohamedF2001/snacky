/* import 'package:json_annotation/json_annotation.dart';

part 'categorie_model.g.dart';

// features/categorie/data/models/categorie_model.dart

@JsonSerializable()
class CategorieModel {
  @JsonKey(name: "_id")
  final String? id;

  final String nom;
  final String description;

  final String? date;

  @JsonKey(name: "__v")
  final int? v;

  CategorieModel({
    this.id,
    required this.nom,
    required this.description,
    this.date,
    this.v,
  });

  factory CategorieModel.fromJson(Map<String, dynamic> json) =>
      _$CategorieModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategorieModelToJson(this);
}

@JsonSerializable()
class CreateCategorieResponse {
  final String message;
  final CategorieModel categorie;

  CreateCategorieResponse({required this.message, required this.categorie});

  factory CreateCategorieResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateCategorieResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCategorieResponseToJson(this);
}
 */

// features/categories/data/models/categorie_model.dart
/* import 'package:json_annotation/json_annotation.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';

part 'categorie_model.g.dart';

@JsonSerializable()
class CategorieModel extends CategorieEntity {
  @JsonKey(name: "_id")
  final String? id;

  @override
  final String nom;

  @override
  final String description;

  @override
  final String? date;

  @JsonKey(name: "__v")
  @override
  final int? v;

  CategorieModel({
    this.id,
    required this.nom,
    required this.description,
    this.date,
    this.v,
  }) : super(id: id, nom: nom, description: description, date: date, v: v);

  factory CategorieModel.fromJson(Map<String, dynamic> json) =>
      _$CategorieModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategorieModelToJson(this);
}
 */

/* import 'package:json_annotation/json_annotation.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';

part 'categorie_model.g.dart';

@JsonSerializable()
class CategorieModel extends CategorieEntity {
  @JsonKey(name: "_id")
  @override
  final String? id;

  @override
  final String nom;

  @override
  final String description;

  @override
  final String? date;

  @JsonKey(name: "__v")
  @override
  final int? v;

  CategorieModel({
    this.id,
    required this.nom,
    required this.description,
    this.date,
    this.v,
  }) : super(id: id, nom: nom, description: description, date: date, v: v);

  factory CategorieModel.fromJson(Map<String, dynamic> json) =>
      _$CategorieModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategorieModelToJson(this);
}
 */

// features/categories/data/models/categorie_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';

part 'categorie_model.g.dart';

@JsonSerializable()
class CategorieModel extends CategorieEntity {
  @JsonKey(name: "_id")
  @override
  final String id;

  @override
  final String nom;

  @override
  final String description;

  @override
  final String? date;

  const CategorieModel({
    required this.id,
    required this.nom,
    required this.description,
    this.date,
  }) : super(id: id, nom: nom, description: description, date: date);

  factory CategorieModel.fromJson(Map<String, dynamic> json) =>
      _$CategorieModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategorieModelToJson(this);
}
