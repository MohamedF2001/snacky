import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';
import 'package:snacky/features/categories/domain/repositories/categorie_repository.dart';

class CreateCategorieUsecase {
  final CategorieRepository categorieRepository;

  CreateCategorieUsecase({required this.categorieRepository});

  Future<Either<Failure, CategorieEntity>> execute(CategorieEntity categorie) {
    return categorieRepository.createCategory(categorie);
  }
}
