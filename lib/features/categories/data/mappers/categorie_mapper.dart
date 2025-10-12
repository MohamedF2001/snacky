import 'package:snacky/features/categories/data/models/categorie_model.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';

extension CategorieMapper on CategorieModel {
  CategorieEntity toEntity() {
    return CategorieEntity(nom: nom, description: description, id: id);
  }
}

extension CategorieEntityMapper on CategorieEntity {
  CategorieModel toModel() {
    return CategorieModel(nom: nom, description: description, id: id);
  }
}
