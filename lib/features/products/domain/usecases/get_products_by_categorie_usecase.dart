import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/domain/repositories/product_repository.dart';

class GetProductsByCategorieUseCase {
  final ProductRepository productRepository;

  GetProductsByCategorieUseCase({required this.productRepository});

  Future<Either<Failure, List<ProductEntity>>> execute(String categorieId) {
    return productRepository.getProductsByCategorie(categorieId);
  }
}
