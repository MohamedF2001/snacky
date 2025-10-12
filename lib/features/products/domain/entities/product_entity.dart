/* // features/products/domain/entities/produit_entity.dart
import 'package:equatable/equatable.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';

class ProductEntity extends Equatable {
  final String? id;
  final String nom;
  final String description;
  final double prix;
  final String? imageUrl;
  final CategorieEntity? categorie;

  const ProductEntity({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.imageUrl,
    this.categorie,
  });

  @override
  List<Object?> get props => [id, nom, description, prix, imageUrl, categorie];
}
 */

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String? id;
  final String nom;
  final String description;
  final double prix;
  final String? imageUrl;
  final dynamic categorie; // ✅ Changé de CategorieEntity? à dynamic

  const ProductEntity({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.imageUrl,
    this.categorie,
  });

  @override
  List<Object?> get props => [id, nom, description, prix, imageUrl, categorie];
}
