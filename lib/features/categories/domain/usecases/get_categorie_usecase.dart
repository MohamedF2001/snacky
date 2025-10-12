import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';
import 'package:snacky/features/categories/domain/repositories/categorie_repository.dart';

class GetCategorieUsecase {
  final CategorieRepository categorieRepository;

  GetCategorieUsecase({required this.categorieRepository});

  Future<Either<Failure, List<CategorieEntity>>> execute() {
    return categorieRepository.getCategories();
  }
}
