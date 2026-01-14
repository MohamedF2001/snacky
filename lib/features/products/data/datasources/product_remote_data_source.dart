import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/features/products/data/models/product_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

class ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSource({required this.apiClient});

  Future<Either<Failure, List<ProductModel>>> getProducts() async {
    try {
      final response = await apiClient.dio.get('/produits');

      final products = (response.data as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      return Right(products);
    } on DioException catch (e) {
      return Left(_handleDioError(e) as Failure);
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, List<ProductModel>>> getProductsByCategorie(
    String categorieId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/produits/categorie/$categorieId',
      );

      final produits = (response.data as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();

      return Right(produits);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // 🚀 Ici on considère que ce n'est pas une "erreur", juste aucun produit
        return Right([]);
      }
      //return Left(ServerFailure(e.message ?? "Erreur serveur"));
      return Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final response = await apiClient.dio.get('/produits/$id');

      if (response.statusCode == 200) {
        final data = response.data;

        final product = ProductEntity(
          id: data['_id'] as String?,
          nom: data['nom'] as String,
          description: data['description'] as String,
          prix: (data['prix'] as num).toDouble(),
          imageUrl: data['imageUrl'] as String?,
          categorie:
              data['categorie'], // tu pourras plus tard mapper vers une entité dédiée
        );

        return Right(product);
      } else {
        return Left(
          Failure.serverError(
            message: response.data['error'] ?? 'Erreur inconnue',
          ),
        );
      }
    } on DioException catch (e) {
      return _handleDioError<ProductEntity>(e); // ✅ ici on force le type
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, ProductModel>> createProduct(
    ProductModel product, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      // ✅ Validation des paramètres avant de continuer
      if (product.nom.isEmpty ||
          product.prix <= 0 ||
          product.categorie == null) {
        return Left(
          Failure.validationError(
            errors: {'validation': 'Nom, prix et catégorie sont requis'},
          ),
        );
      }

      Map<String, dynamic> formDataMap = {
        "nom": product.nom,
        "description": product.description,
        "prix": product.prix.toString(),
        "categorie": product.categorie
            .toString(), // ✅ S'assurer que c'est un String
      };

      bool imageAdded = false;

      // ✅ Améliorer la logique d'ajout d'image
      if (kIsWeb && imageBytes != null && imageBytes.isNotEmpty) {
        // Pour Web : utiliser les bytes
        formDataMap["image"] = MultipartFile.fromBytes(
          imageBytes,
          filename: "upload_${DateTime.now().millisecondsSinceEpoch}.png",
          contentType: MediaType('image', 'png'),
        );
        imageAdded = true;
        print("✅ Image ajoutée pour Web: ${imageBytes.length} bytes");
      } else if (!kIsWeb && imageFile != null && await imageFile.exists()) {
        // Pour Mobile : utiliser le fichier
        formDataMap["image"] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        imageAdded = true;
        print("✅ Image ajoutée pour Mobile: ${imageFile.path}");
      } else {
        print("⚠️ Aucune image à ajouter:");
        print("  kIsWeb: $kIsWeb");
        print("  imageBytes != null: ${imageBytes != null}");
        print("  imageFile != null: ${imageFile != null}");
        if (imageFile != null && !kIsWeb) {
          print("  imageFile exists: ${await imageFile.exists()}");
        }
      }

      final formData = FormData.fromMap(formDataMap);

      // ✅ Debug des données envoyées
      print("📦 Données à envoyer:");
      print("  Champs:");
      for (var field in formData.fields) {
        print("    ${field.key}: ${field.value}");
      }
      print("  Fichiers:");
      for (var file in formData.files) {
        print(
          "    ${file.key}: ${file.value.filename} (${file.value.length} bytes)",
        );
      }
      print("  Image ajoutée: $imageAdded");

      final response = await apiClient.dio.post(
        "/produits",
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            // Dio gère automatiquement Content-Type pour FormData
          },
          // ✅ Augmenter les timeouts pour l'upload d'image
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      print("📥 Réponse serveur (${response.statusCode}): ${response.data}");

      if (response.statusCode == 201 && response.data != null) {
        final produitJson = response.data['produit'];

        if (produitJson == null) {
          return Left(
            Failure.serverError(
              message:
                  "Réponse serveur invalide: pas de produit dans la réponse",
            ),
          );
        }

        // ✅ Transformer la réponse si nécessaire
        final transformedJson = Map<String, dynamic>.from(produitJson);

        // S'assurer que les champs requis sont présents
        transformedJson['nom'] = transformedJson['nom'] ?? product.nom;
        transformedJson['description'] =
            transformedJson['description'] ?? product.description;
        transformedJson['prix'] = transformedJson['prix'] ?? product.prix;

        final createdProduct = ProductModel.fromJson(transformedJson);
        print("✅ Produit créé avec succès: ${createdProduct.nom}");

        return Right(createdProduct);
      } else {
        return Left(
          Failure.serverError(
            message:
                response.statusMessage ??
                "Erreur lors de la création du produit",
          ),
        );
      }
    } on DioException catch (e) {
      print("❌ Erreur Dio: ${e.message}");
      print("❌ Type d'erreur: ${e.type}");
      if (e.response != null) {
        print("❌ Code de réponse: ${e.response?.statusCode}");
        print("❌ Données de réponse: ${e.response?.data}");
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      print("❌ Erreur inattendue: $e");
      print("❌ Stack trace: $stackTrace");
      return Left(Failure.unexpectedError());
    }
  }

  /// Mettre à jour un produit
  Future<Either<Failure, ProductModel>> updateProduct(
      ProductModel product, {
        File? imageFile,
        Uint8List? imageBytes,
      }) async {
    try {
      // Validation
      if (product.id == null || product.id!.isEmpty) {
        return Left(
          Failure.validationError(
            errors: {'id': 'ID de produit requis'},
          ),
        );
      }

      if (product.nom.isEmpty || product.prix <= 0) {
        return Left(
          Failure.validationError(
            errors: {'validation': 'Nom et prix sont requis'},
          ),
        );
      }

      Map<String, dynamic> formDataMap = {
        "nom": product.nom,
        "description": product.description,
        "prix": product.prix.toString(),
        "categorie": product.categorie.toString(),
      };

      bool imageAdded = false;

      // Ajouter l'image si fournie
      if (kIsWeb && imageBytes != null && imageBytes.isNotEmpty) {
        formDataMap["image"] = MultipartFile.fromBytes(
          imageBytes,
          filename: "upload_${DateTime.now().millisecondsSinceEpoch}.png",
          contentType: MediaType('image', 'png'),
        );
        imageAdded = true;
        print("✅ Image ajoutée pour mise à jour (Web)");
      } else if (!kIsWeb && imageFile != null && await imageFile.exists()) {
        formDataMap["image"] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        imageAdded = true;
        print("✅ Image ajoutée pour mise à jour (Mobile)");
      }

      final formData = FormData.fromMap(formDataMap);

      print("📦 Mise à jour du produit ${product.id}");
      print("  Image ajoutée: $imageAdded");

      final response = await apiClient.dio.put(
        "/produits/${product.id}",
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      print("🔥 Réponse serveur (${response.statusCode}): ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final produitJson = response.data['produit'] ?? response.data;

        if (produitJson == null) {
          return Left(
            Failure.serverError(
              message: "Réponse serveur invalide",
            ),
          );
        }

        final transformedJson = Map<String, dynamic>.from(produitJson);
        final updatedProduct = ProductModel.fromJson(transformedJson);

        print("✅ Produit mis à jour avec succès: ${updatedProduct.nom}");
        return Right(updatedProduct);
      } else {
        return Left(
          Failure.serverError(
            message: response.statusMessage ?? "Erreur lors de la mise à jour",
          ),
        );
      }
    } on DioException catch (e) {
      print("❌ Erreur Dio: ${e.message}");
      if (e.response != null) {
        print("❌ Code de réponse: ${e.response?.statusCode}");
        print("❌ Données de réponse: ${e.response?.data}");
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      print("❌ Erreur inattendue: $e");
      print("❌ Stack trace: $stackTrace");
      return Left(Failure.unexpectedError());
    }
  }

  /// Supprimer un produit
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      if (id.isEmpty) {
        return Left(
          Failure.validationError(
            errors: {'id': 'ID de produit requis'},
          ),
        );
      }

      print("🗑️ Suppression du produit: $id");

      final response = await apiClient.dio.delete('/produits/$id');

      print("🔥 Réponse suppression (${response.statusCode})");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Produit supprimé avec succès");
        return const Right(null);
      } else {
        return Left(
          Failure.serverError(
            message: response.statusMessage ?? "Erreur lors de la suppression",
          ),
        );
      }
    } on DioException catch (e) {
      print("❌ Erreur Dio lors de la suppression: ${e.message}");
      if (e.response != null) {
        print("❌ Code de réponse: ${e.response?.statusCode}");
        print("❌ Données de réponse: ${e.response?.data}");
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      print("❌ Erreur inattendue lors de la suppression: $e");
      print("❌ Stack trace: $stackTrace");
      return Left(Failure.unexpectedError());
    }
  }

  Either<Failure, T> _handleDioError<T>(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Left(
          Failure.validationError(
            errors: e.response?.data is Map
                ? e.response?.data['errors'] ??
                      {
                        'general':
                            e.response?.data['error'] ?? 'Erreur de validation',
                      }
                : {'general': 'Erreur de validation'},
          ),
        );
      case 401:
        return Left(Failure.unauthorized());
      case 404:
        return Left(Failure.notFound());
      case 500:
        return Left(
          Failure.serverError(
            message: e.response?.data is Map
                ? e.response?.data['message'] ?? 'Erreur serveur interne'
                : 'Erreur serveur interne',
          ),
        );
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return Left(Failure.networkError());
        } else {
          return Left(Failure.unexpectedError());
        }
    }
  }
}
