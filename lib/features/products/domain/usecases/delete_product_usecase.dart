// features/products/domain/usecases/delete_product_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/products/domain/repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository productRepository;

  DeleteProductUseCase({required this.productRepository});

  Future<Either<Failure, void>> execute(String productId) {
    return productRepository.deleteProduct(productId);
  }
}
