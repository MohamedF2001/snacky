// features/products/domain/usecases/update_product_usecase.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/domain/repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository productRepository;

  UpdateProductUseCase({required this.productRepository});

  Future<Either<Failure, ProductEntity>> execute(
      ProductEntity product, {
        File? imageFile,
        Uint8List? imageBytes,
      }) async {
    return await productRepository.updateProduct(
      product,
      imageFile: imageFile,
      imageBytes: imageBytes,
    );
  }
}