/* class CategorieEntity {
  final String nom;
  final String description;

  CategorieEntity({required this.nom, required this.description});
}
 */

// features/categories/domain/entities/categorie_entity.dart
import 'package:equatable/equatable.dart';

class CategorieEntity extends Equatable {
  final String id;
  final String nom;
  final String description;
  final String? date;
  final int? v;

  const CategorieEntity({
    required this.id,
    required this.nom,
    required this.description,
    this.date,
    this.v,
  });

  @override
  List<Object?> get props => [id, nom, description, date, v];
}
