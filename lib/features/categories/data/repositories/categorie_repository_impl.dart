import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/categories/data/datasources/categorie_remote_data_source.dart';
import 'package:snacky/features/categories/data/mappers/categorie_mapper.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';
import 'package:snacky/features/categories/domain/repositories/categorie_repository.dart';

class CategorieRepositoryImpl implements CategorieRepository {
  final CategorieRemoteDataSource remoteDataSource;

  CategorieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategorieEntity>>> getCategories() async {
    final result = await remoteDataSource.getCategories();

    return result.fold(
      (failure) => Left(failure),
      (categories) => Right(categories.map((c) => c.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, CategorieEntity>> createCategory(
    CategorieEntity category,
  ) async {
    final categoryModel = category.toModel();
    final result = await remoteDataSource.createCategorie(categoryModel);

    return result.fold(
      (failure) => Left(failure),
      (createdCategory) => Right(createdCategory.toEntity()),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async {
    final result = await remoteDataSource.deleteCategorie(id);

    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success), // success est un Unit
    );
  }
}
