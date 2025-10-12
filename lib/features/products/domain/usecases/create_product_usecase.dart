import 'dart:io';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/domain/repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository productRepository;

  CreateProductUseCase({required this.productRepository});

  // Future<Either<Failure, ProductEntity>> execute(
  //   ProductEntity product, {
  //   File? imageFile,
  //   Uint8List? imageBytes,
  // }) async {
  //   return await productRepository.createProduct(product, imageFile: imageFile);
  // }
  Future<Either<Failure, ProductEntity>> execute(
    ProductEntity product, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    // ✅ Passer les deux paramètres correctement
    return await productRepository.createProduct(
      product,
      imageFile: imageFile,
      imageBytes: imageBytes, // ✅ Ajouter ce paramètre manquant
    );
  }
}
