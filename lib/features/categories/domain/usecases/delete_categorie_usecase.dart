import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/categories/domain/repositories/categorie_repository.dart';

class DeleteCategoryUseCase {
  final CategorieRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(String id) async {
    return await repository.deleteCategory(id);
  }
}
