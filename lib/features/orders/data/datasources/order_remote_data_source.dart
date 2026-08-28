// features/orders/data/datasources/order_remote_data_source.dart
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/core/utils/app_logger.dart';
import 'package:snacky/features/orders/data/mappers/order_mapper.dart';
import 'package:snacky/features/orders/data/models/order_model.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';

import '../../../auth/data/models/user_model.dart';

class OrderRemoteDataSource {
  final ApiClient apiClient;


  OrderRemoteDataSource({required this.apiClient});

  /// Récupérer toutes les commandes
  Future<Either<Failure, List<OrderModel>>> getOrders() async {
    try {
      final response = await apiClient.dio.get('/orders');

      logger.d("📥 Raw API response received, count: ${(response.data as List).length}");

      final orders = (response.data as List)
          .map((item) {
        try {
          return OrderModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          logger.e("❌ Error parsing order $e");
          return null;
        }
      })
          .whereType<OrderModel>()
          .toList();

      logger.d("✅ Successfully parsed ${orders.length} orders");

      // ✅ Logger les statuts pour débogage
      for (var order in orders) {
        logger.d("📦 Order ${order.id}: statut = ${order.statut}");
      }

      return Right(orders);
    } on DioException catch (e) {
      logger.e("❌ DioException: ${e.message}");
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      logger.e("error",
          error: {
            "message": "Unexpected error $e",
            "stackTrace": stackTrace,
          });
      return Left(Failure.unexpectedError());
    }
  }

  /// Récupérer une commande par ID
  Future<Either<Failure, OrderEntity>> getOrderById(String id) async {
    try {
      final response = await apiClient.dio.get('/orders/$id');

      if (response.statusCode == 200) {
        final data = response.data;

        logger.d("📥 Order detail response: $data");

        // Vérifier les champs requis
        if (data['nomClient'] == null || data['telephone'] == null) {
          return Left(
            Failure.serverError(
              message: 'Données de commande incomplètes',
            ),
          );
        }

        // 🔥 FIX: Utiliser OrderModel.fromJson au lieu de créer manuellement l'entité
        try {
          final orderModel = OrderModel.fromJson(data);
          logger.d("✅ Order parsed successfully: ${orderModel.id}");
          return Right(orderModel.toEntity());
        } catch (e, stackTrace) {
          logger.e("Error",error: {
            "❌ Error parsing order: $e",
            "❌ Stack trace: $stackTrace"
          });
          return Left(
            Failure.serverError(
              message: 'Erreur lors du parsing de la commande: $e',
            ),
          );
        }
      } else {
        return Left(
          Failure.serverError(
            message: response.data['error'] ?? 'Erreur inconnue',
          ),
        );
      }
    } on DioException catch (e) {
      return _handleDioError<OrderEntity>(e);
    } catch (e, stackTrace) {
      logger.e("Error",
      error: {
        "❌ Unexpected error: $e",
        "❌ Stack trace: $stackTrace"
      }
      );
      return Left(Failure.unexpectedError());
    }
  }

  /// Créer une nouvelle commande
  /*Future<Either<Failure, OrderModel>> createOrder(OrderModel order) async {
    try {
      // Validation des paramètres
      if (order.nomClient.isEmpty ||
          order.telephone.isEmpty ||
          order.produits.isEmpty) {
        return Left(
          Failure.validationError(
            errors: {
              'validation': 'Nom, téléphone et produits sont requis'
            },
          ),
        );
      }

      final orderData = {
        "client": order.client is String
            ? order.client
            : (order.client?.id ?? order.client),
        "nomClient": order.nomClient,
        "telephone": order.telephone,
        "produits": order.produits
            .map((p) => {
          "produit": p.produit is String
              ? p.produit
              : (p.produit?.id ?? p.produit),
          "quantite": p.quantite,
        })
            .toList(),
        "coutTotal": order.coutTotal,
        "statut": order.statut,
        "surPlace": order.surPlace,
        "livraison": order.livraison,
      };

      // N'ajouter numeroTable que s'il n'est pas null
      if (order.numeroTable != null) {
        orderData["numeroTable"] = order.numeroTable;
      }

      logger.d("📦 Données à envoyer: $orderData");

      final response = await apiClient.dio.post(
        "/orders",
        data: orderData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      logger.d("🔥 Réponse serveur (${response.statusCode}): ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data == null) {
          return Left(
            Failure.serverError(
              message: "Réponse serveur vide",
            ),
          );
        }

        // 🔥 FIX: L'API retourne directement l'objet, pas dans une clé "commande"
        // Ancienne version (ne fonctionnait pas):
        // final commandeJson = response.data['commande'] ?? response.data;

        // Nouvelle version (correcte):
        final commandeJson = response.data;

        try {
          final createdOrder = OrderModel.fromJson(commandeJson);
          logger.d("✅ Commande créée avec succès: ${createdOrder.id}");
          return Right(createdOrder);
        } catch (e, stackTrace) {
          logger.e("❌ Erreur lors du parsing de la réponse: $e");
          logger.e("❌ Stack trace: $stackTrace");
          logger.e("❌ Données reçues: $commandeJson");
          return Left(
            Failure.serverError(
              message: "Erreur lors du traitement de la réponse: $e",
            ),
          );
        }
      } else {
        return Left(
          Failure.serverError(
            message: response.statusMessage ??
                "Erreur lors de la création de la commande",
          ),
        );
      }
    } on DioException catch (e) {
      logger.e("❌ Erreur",error: {
        "❌ Erreur Dio: ${e.message.toString()}",
        "❌ Type d'erreur: ${e.type.toString()}"
      });
      if (e.response != null) {
        logger.e("error",
            error:{
              "❌ Code de réponse: ${e.response?.statusCode}",
              "❌ Données de réponse: ${e.response?.data}",
            });
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      logger.e("error",error:{
        "❌ Erreur inattendue: $e",
        "❌ Stack trace: $stackTrace",
      });
      return Left(Failure.unexpectedError());
    }
  }*/

  Future<Either<Failure, OrderModel>> createOrder(OrderModel order) async {
    try {
      // Validation des paramètres
      if (order.nomClient.isEmpty ||
          order.telephone.isEmpty ||
          order.produits.isEmpty) {
        return Left(
          Failure.validationError(
            errors: {
              'validation': 'Nom, téléphone et produits sont requis'
            },
          ),
        );
      }

      final orderData = {
        // ✅ Ne pas envoyer le champ client du tout s'il est null
        // L'API va automatiquement assigner le client connecté
        if (order.client != null)
          "client": order.client is String
              ? order.client
              : (order.client is UserModel
              ? (order.client as UserModel).id
              : order.client),
        "nomClient": order.nomClient,
        "telephone": order.telephone,
        "produits": order.produits
            .map((p) => {
          "produit": p.produit is String
              ? p.produit
              : (p.produit?.id ?? p.produit),
          "quantite": p.quantite,
        })
            .toList(),
        "coutTotal": order.coutTotal,
        "statut": order.statut,
        "surPlace": order.surPlace,
        "livraison": order.livraison,
      };

      // N'ajouter numeroTable que s'il n'est pas null
      if (order.numeroTable != null) {
        orderData["numeroTable"] = order.numeroTable;
      }

      logger.d("📦 Données à envoyer: $orderData");

      final response = await apiClient.dio.post(
        "/orders",
        data: orderData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      logger.d("🔥 Réponse serveur (${response.statusCode}): ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data == null) {
          return Left(
            Failure.serverError(
              message: "Réponse serveur vide",
            ),
          );
        }

        // ✅ L'API retourne directement l'objet commande
        final commandeJson = response.data;

        try {
          final createdOrder = OrderModel.fromJson(commandeJson);
          logger.d("✅ Commande créée avec succès: ${createdOrder.id}");
          logger.d("✅ Client dans la réponse: ${createdOrder.client}");
          return Right(createdOrder);
        } catch (e, stackTrace) {
          logger.e("❌ Erreur lors du parsing de la réponse: $e");
          logger.e("❌ Stack trace: $stackTrace");
          logger.e("❌ Données reçues: $commandeJson");
          return Left(
            Failure.serverError(
              message: "Erreur lors du traitement de la réponse: $e",
            ),
          );
        }
      } else {
        return Left(
          Failure.serverError(
            message: response.statusMessage ??
                "Erreur lors de la création de la commande",
          ),
        );
      }
    } on DioException catch (e) {
      logger.e("❌ Erreur Dio: ${e.message}");
      if (e.response != null) {
        logger.e("❌ Code de réponse: ${e.response?.statusCode}");
        logger.e("❌ Données de réponse: ${e.response?.data}");
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      logger.e("❌ Erreur inattendue: $e");
      logger.e("❌ Stack trace: $stackTrace");
      return Left(Failure.unexpectedError());
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<Either<Failure, OrderModel>> updateOrderStatus(
      String id,
      String statut,
      ) async {
    try {
      logger.d("🔄 Mise à jour du statut de la commande $id vers $statut");

      final response = await apiClient.dio.put(
        '/orders/$id',
        data: {"statut": statut},
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      logger.d("📥 Réponse de mise à jour: ${response.data}");

      if (response.statusCode == 200) {
        final commandeJson = response.data['commande'] ?? response.data;

        final updatedOrder = OrderModel.fromJson(commandeJson);

        // ✅ Vérifier que le statut est bien mis à jour
        logger.d("✅ Statut mis à jour: ancien='?', nouveau='${updatedOrder.statut}'");
        logger.d("✅ Données complètes de la commande mise à jour: ${updatedOrder.toJson()}");

        return Right(updatedOrder);
      } else {
        return Left(
          Failure.serverError(
            message: response.statusMessage ?? "Erreur serveur",
          ),
        );
      }
    } on DioException catch (e) {
      logger.e("❌ Erreur lors de la mise à jour du statut: ${e.message}");
      if (e.response != null) {
        logger.e("❌ Réponse erreur: ${e.response?.data}");
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      logger.e("❌ Unexpected error: $e");
      logger.e("❌ Stack trace: $stackTrace");
      return Left(Failure.unexpectedError());
    }
  }

  /// Récupérer les commandes par client
  Future<Either<Failure, List<OrderModel>>> getOrdersByClient(
      String clientId,
      ) async {
    try {
      final response = await apiClient.dio.get(
        '/orders/client/$clientId',
      );

      final orders = (response.data as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();

      return Right(orders);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Right([]);
      }
      return Left(Failure.unexpectedError());
    }
  }

  /// Mettre à jour une commande complète
  Future<Either<Failure, OrderModel>> updateOrder(OrderModel order) async {
    try {
      // Validation des paramètres
      if (order.id == null || order.id!.isEmpty) {
        return Left(
          Failure.validationError(
            errors: {'id': 'ID de commande requis'},
          ),
        );
      }

      if (order.nomClient.isEmpty ||
          order.telephone.isEmpty ||
          order.produits.isEmpty) {
        return Left(
          Failure.validationError(
            errors: {
              'validation': 'Nom, téléphone et produits sont requis'
            },
          ),
        );
      }

      final orderData = {
        "nomClient": order.nomClient,
        "telephone": order.telephone,
        "produits": order.produits
            .map((p) => {
          "produit": p.produit is String
              ? p.produit
              : (p.produit?.id ?? p.produit),
          "quantite": p.quantite,
        })
            .toList(),
        "coutTotal": order.coutTotal,
        "statut": order.statut,
        "surPlace": order.surPlace,
        "livraison": order.livraison,
      };

      // N'ajouter numeroTable que s'il n'est pas null
      if (order.numeroTable != null) {
        orderData["numeroTable"] = order.numeroTable!;
      }

      logger.d("📦 Données de mise à jour à envoyer: $orderData");

      final response = await apiClient.dio.put(
        "/orders/${order.id}",
        data: orderData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      logger.d("🔥 Réponse serveur (${response.statusCode}): ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final commandeJson = response.data['commande'] ?? response.data;

        if (commandeJson == null) {
          return Left(
            Failure.serverError(
              message:
              "Réponse serveur invalide: pas de commande dans la réponse",
            ),
          );
        }

        final updatedOrder = OrderModel.fromJson(commandeJson);
        logger.d("✅ Commande mise à jour avec succès: ${updatedOrder.id}");

        return Right(updatedOrder);
      } else {
        return Left(
          Failure.serverError(
            message: response.statusMessage ??
                "Erreur lors de la mise à jour de la commande",
          ),
        );
      }
    } on DioException catch (e) {
      logger.e("❌ Erreur",error: {
        "❌ Erreur Dio: ${e.message.toString()}",
        "❌ Type d'erreur: ${e.type.toString()}"
      });
      if (e.response != null) {
        logger.e("error",
            error:{
              "❌ Code de réponse: ${e.response?.statusCode}",
              "❌ Données de réponse: ${e.response?.data}",
            });
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      logger.e("error",error:{
        "❌ Erreur inattendue $e",
        "❌ Stack trace: $stackTrace",
      });
      return Left(Failure.unexpectedError());
    }
  }

  /// Supprimer une commande
  Future<Either<Failure, void>> deleteOrder(String id) async {
    try {
      if (id.isEmpty) {
        return Left(
          Failure.validationError(
            errors: {'id': 'ID de commande requis'},
          ),
        );
      }

      logger.d("🗑️ Suppression de la commande: $id");

      final response = await apiClient.dio.delete('/orders/$id');

      logger.d("🔥 Réponse suppression (${response.statusCode}): ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        logger.d("✅ Commande supprimée avec succès");
        return const Right(null);
      } else {
        return Left(
          Failure.serverError(
            message: response.statusMessage ?? "Erreur lors de la suppression",
          ),
        );
      }
    } on DioException catch (e) {
      logger.e("❌ Erreur Dio lors de la suppression: ${e.message}");
      if (e.response != null) {
        logger.e("error",
        error:{
          "❌ Code de réponse: ${e.response?.statusCode}",
          "❌ Données de réponse: ${e.response?.data}",
        });
      }
      return Left(_handleDioError(e) as Failure);
    } catch (e, stackTrace) {
      logger.e("error",error:{
        "❌ Erreur inattendue lors de la suppression: $e",
        "❌ Stack trace: $stackTrace",
      });
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