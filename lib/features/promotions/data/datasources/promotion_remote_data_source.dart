import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/features/promotions/data/models/promotion_model.dart';

import '../../../../core/error/failures.dart';

class PromotionRemoteDataSource {
  final ApiClient apiClient;

  PromotionRemoteDataSource({required this.apiClient});

  Future<Either<Failure, List<PromotionModel>>> getPromotions() async {
    try {
      final response = await apiClient.dio.get('/promotions');

      final promotions = (response.data as List)
          .map((item) => PromotionModel.fromJson(item))
          .toList();

      return Right(promotions);
    } on DioException catch (e) {
      return Left(_handleDioError(e) as Failure);
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  /*Future<Either<Failure, PromotionModel>> createPromotion(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/promotions', data: data);

      final promotion = PromotionModel.fromJson(response.data);
      return Right(promotion);
      *//*if (response.statusCode == 200 || response.statusCode == 201) {
        final promotion = PromotionModel.fromJson(response.data);
        return Right(promotion);
      } else {
        return Left(Failure.serverError(
          message: 'Erreur serveur (${response.statusCode}) : ${response.statusMessage}',
        ));
      }*//*
    } on DioException catch (e) {
      return _handleDioError<PromotionModel>(e); // ✅ correction ici
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }*/

  Future<Either<Failure, PromotionModel>> createPromotion(Map<String, dynamic> data) async {
    try {
      developer.log('📤 Envoi de la requête POST /promotions avec data: $data');

      final response = await apiClient.dio.post('/promotions', data: data);

      developer.log('📥 Réponse reçue - Status: ${response.statusCode}');
      developer.log('📥 Données de réponse: ${response.data}');

      // ✅ Vérification explicite du code de statut
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final promotion = PromotionModel.fromJson(response.data);
          developer.log('✅ Promotion créée avec succès: ${promotion.nom}');
          return Right(promotion);
        } catch (e) {
          developer.log('❌ Erreur de parsing JSON: $e');
          developer.log('❌ Data reçue: ${response.data}');
          return Left(Failure.unexpectedError());
        }
      } else {
        developer.log('⚠️ Code de statut inattendu: ${response.statusCode}');
        return Left(Failure.serverError(
          message: 'Erreur serveur (${response.statusCode})',
        ));
      }
    } on DioException catch (e) {
      developer.log('❌ DioException capturée: ${e.type}');
      developer.log('❌ Message: ${e.message}');
      developer.log('❌ Response: ${e.response?.data}');
      return Left(_handleDioErrorr(e));
    } catch (e) {
      developer.log('❌ Exception inattendue: $e');
      return Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, Unit>> deletePromotion(String id) async {
    try {
      // TODO: Adapter selon la route exacte (ici je suppose /categories/:id)
      final response = await apiClient.dio.delete('/promotions/$id');

      if (response.statusCode == 200) {
        // Succès → on renvoie Right(Unit) car pas besoin d'un objet
        return const Right(unit);
      } else {
        return Left(
          Failure.serverError(
            message: response.data['error'] ?? 'Erreur inconnue',
          ),
        );
      }
    } on DioException catch (e) {
      return Future.value(
        _handleDioError(e) as FutureOr<Either<Failure, Unit>>?,
      );
    } catch (e) {
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

  Failure _handleDioErrorr(DioException e) {
    developer.log('🔍 Traitement de l\'erreur Dio - Type: ${e.type}');
    developer.log('🔍 Status Code: ${e.response?.statusCode}');
    developer.log('🔍 Response Data: ${e.response?.data}');

    switch (e.response?.statusCode) {
      case 400:
        return Failure.validationError(
          errors: e.response?.data is Map
              ? e.response?.data['errors'] ??
              {
                'general':
                e.response?.data['error'] ?? 'Erreur de validation',
              }
              : {'general': 'Erreur de validation'},
        );
      case 401:
        return Failure.unauthorized();
      case 404:
        return Failure.notFound();
      case 500:
        return Failure.serverError(
          message: e.response?.data is Map
              ? e.response?.data['message'] ?? 'Erreur serveur interne'
              : 'Erreur serveur interne',
        );
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return Failure.networkError();
        } else {
          return Failure.unexpectedError();
        }
    }
  }
}