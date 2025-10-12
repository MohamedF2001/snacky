import 'dart:io';
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();

  /// 🔥 ajout du [File? imageFile] optionnel
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product, {
    File? imageFile,
    Uint8List? imageBytes,
  });

  Future<Either<Failure, List<ProductEntity>>> getProductsByCategorie(
    String categorieId,
  );
  Future<Either<Failure, ProductEntity>> getProductById(String id);

  Future<Either<Failure, ProductEntity>> updateProduct(
      ProductEntity product, {
        File? imageFile,
        Uint8List? imageBytes,
      });

  Future<Either<Failure, void>> deleteProduct(String id);
}
