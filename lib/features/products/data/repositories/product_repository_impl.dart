import 'dart:io';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/categories/data/models/categorie_model.dart';
import 'package:snacky/features/products/data/datasources/product_remote_data_source.dart';
import 'package:snacky/features/products/data/mappers/product_mapper.dart';
import 'package:snacky/features/products/data/models/product_model.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/domain/repositories/product_repository.dart';

import '../../../../core/utils/app_logger.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    final result = await remoteDataSource.getProducts();

    return result.fold(
      (failure) => Left(failure),
      (products) => Right(products.map((p) => p.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    // ✅ Conversion corrigée : gérer les différents types de categorie
    dynamic categorieValue;

    if (product.categorie != null) {
      if (product.categorie is String) {
        // Si c'est déjà un String (ID), l'utiliser directement
        categorieValue = product.categorie;
      } else if (product.categorie is CategorieModel) {
        // Si c'est un CategorieModel, prendre l'ID
        categorieValue = (product.categorie as CategorieModel).id;
      } else {
        // Si c'est un autre type d'objet avec une propriété id
        try {
          categorieValue = product.categorie.id;
        } catch (e) {
          logger.w("⚠️ Erreur lors de l'accès à categorie.id: $e");
          categorieValue = product.categorie.toString();
        }
      }
    }

    final productModel = ProductModel(
      id: product.id,
      nom: product.nom,
      description: product.description,
      prix: product.prix,
      imageUrl: product.imageUrl,
      categorie: categorieValue, // ✅ Utiliser la valeur convertie
    );

    logger.d("🔍 ProductModel categorie: ${productModel.categorie} (${productModel.categorie.runtimeType})");

    final result = await remoteDataSource.createProduct(
      productModel,
      imageFile: imageFile,
      imageBytes: imageBytes,
    );

    return result.fold(
      (failure) => Left(failure),
      (createdProduct) => Right(createdProduct.toEntity()),
    );
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategorie(
    String categorieId,
  ) async {
    final result = await remoteDataSource.getProductsByCategorie(categorieId);

    return result.fold(
      (failure) => Left(failure),
      (products) => Right(products.map((p) => p.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    final result = await remoteDataSource.getProductById(id);

    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success), // success est un ProductEntity
    );
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
      ProductEntity product, {
        File? imageFile,
        Uint8List? imageBytes,
      }) async {
    // Conversion de l'entité vers le modèle
    dynamic categorieValue;

    if (product.categorie != null) {
      if (product.categorie is String) {
        categorieValue = product.categorie;
      } else if (product.categorie is CategorieModel) {
        categorieValue = (product.categorie as CategorieModel).id;
      } else {
        try {
          categorieValue = product.categorie.id;
        } catch (e) {
          logger.w("⚠️ Erreur lors de l'accès à categorie.id: $e");
          categorieValue = product.categorie.toString();
        }
      }
    }

    final productModel = ProductModel(
      id: product.id,
      nom: product.nom,
      description: product.description,
      prix: product.prix,
      imageUrl: product.imageUrl,
      categorie: categorieValue,
    );

    logger.d("📤 ProductModel à mettre à jour: ${productModel.id}");

    final result = await remoteDataSource.updateProduct(
      productModel,
      imageFile: imageFile,
      imageBytes: imageBytes,
    );

    return result.fold(
          (failure) => Left(failure),
          (updatedProduct) => Right(updatedProduct.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    final result = await remoteDataSource.deleteProduct(id);

    return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
    );
  }
}
