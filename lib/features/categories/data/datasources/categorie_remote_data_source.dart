import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/core/utils/app_logger.dart';
import 'package:snacky/features/categories/data/models/categorie_model.dart';

class CategorieRemoteDataSource {
  final ApiClient apiClient;

  CategorieRemoteDataSource({required this.apiClient});

  Future<Either<Failure, List<CategorieModel>>> getCategories() async {
    try {
      // TODO: Adapter selon la documentation API exacte
      final response = await apiClient.dio.get('/categories');

      final categories = (response.data as List)
          .map((item) => CategorieModel.fromJson(item))
          .toList();

      for (var c in categories) {
        logger.d("Catégorie => id: ${c.id}, nom: ${c.nom}, desc: ${c.description}, date: ${c.date}, v: ${c.v}");
      }

      return Right(categories);
    } on DioException catch (e) {
      return Future.value(
        _handleDioError(e) as FutureOr<Either<Failure, List<CategorieModel>>>?,
      );
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, CategorieModel>> createCategorie(
    CategorieModel categorie,
  ) async {
    try {
      // TODO: Adapter selon la documentation API exacte
      final response = await apiClient.dio.post(
        '/categories',
        data: {'nom': categorie.nom, 'description': categorie.description},
      );

      return Right(CategorieModel.fromJson(response.data));
    } on DioException catch (e) {
      return Future.value(
        _handleDioError(e) as FutureOr<Either<Failure, CategorieModel>>?,
      );
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, Unit>> deleteCategorie(String id) async {
    try {
      // TODO: Adapter selon la route exacte (ici je suppose /categories/:id)
      final response = await apiClient.dio.delete('/categories/$id');

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

  Either<Failure, dynamic> _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Left(Failure.unauthorized());
    } else if (e.response?.statusCode == 400) {
      return Left(
        Failure.validationError(errors: e.response?.data['errors'] ?? {}),
      );
    } else if (e.response?.statusCode == 404) {
      return Left(Failure.notFound());
    } else if (e.response?.statusCode == 500) {
      return Left(Failure.serverError(message: e.response?.data['message']));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Left(Failure.networkError());
    } else {
      return Left(Failure.unexpectedError());
    }
  }
}
