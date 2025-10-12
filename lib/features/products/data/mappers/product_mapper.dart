/* import 'package:snacky/features/products/data/models/product_model.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

extension ProductModelMapper on ProductModel {
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      nom: nom,
      description: description,
      imageUrl: imageUrl,
      prix: prix,
    );
  }
}

extension ProductEntityMapper on ProductEntity {
  ProductModel toModel() {
    return ProductModel(
      id: id,
      nom: nom,
      description: description,
      prix: prix,
      imageUrl: imageUrl,
    );
  }
}
 */

import 'package:snacky/features/products/data/models/product_model.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

extension ProductMapper on ProductModel {
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      nom: nom,
      description: description,
      prix: prix,
      imageUrl: imageUrl,
      categorie: categorie, // Peut être String ou CategorieModel
    );
  }
}

extension ProductEntityMapper on ProductEntity {
  ProductModel toModel() {
    return ProductModel(
      id: id,
      nom: nom,
      description: description,
      prix: prix,
      imageUrl: imageUrl,
      categorie: categorie, // Déjà géré dans ProductModel
    );
  }
}
