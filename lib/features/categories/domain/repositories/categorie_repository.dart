import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';

abstract class CategorieRepository {
  Future<Either<Failure, List<CategorieEntity>>> getCategories();
  Future<Either<Failure, CategorieEntity>> createCategory(
    CategorieEntity category,
  );
  Future<Either<Failure, Unit>> deleteCategory(String id); // ✅ nouvelle méthode
}
