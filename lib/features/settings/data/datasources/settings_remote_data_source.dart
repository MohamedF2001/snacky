// features/settings/data/datasources/settings_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';

import '../models/settings_models.dart';


class SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSource({required this.apiClient});

  /// GET /api/auth/profile — récupère le profil de l'admin connecté
  Future<Either<Failure, AdminProfileModel>> getAdminProfile() async {
    try {
      final response = await apiClient.dio.get('/auth/profile');

      if (response.statusCode == 200) {
        final data = response.data;
        final profile = AdminProfileModel(
          id: data['_id'] ?? data['id'] ?? '',
          nom: data['nom'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'Admin',
          telephone: data['telephone'],
        );
        return Right(profile);
      }
      return Left(Failure.serverError(message: 'Erreur lors du chargement du profil'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  /// PUT /api/auth/profile — met à jour le nom et email
  /// Note : l'API actuelle ne propose pas de route dédiée pour update profile
  /// On utilise une convention REST standard ici, à adapter selon le backend
  Future<Either<Failure, AdminProfileModel>> updateAdminProfile({
    required String nom,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final response = await apiClient.dio.put(
        '/auth/profile',
        data: {'nom': nom, 'email': email},
      );

      if (response.statusCode == 200) {
        final data = response.data['user'] ?? response.data;
        final profile = AdminProfileModel(
          id: data['_id'] ?? data['id'] ?? userId,
          nom: data['nom'] ?? nom,
          email: data['email'] ?? email,
          role: data['role'] ?? 'Admin',
          telephone: data['telephone'],
        );

        // Mettre à jour le cache local
        await prefs.setString('userName', profile.nom);
        await prefs.setString('userEmail', profile.email);

        return Right(profile);
      }
      return Left(Failure.serverError(message: 'Impossible de mettre à jour le profil'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  /// POST /api/auth/admin/change-password — change le mot de passe
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.dio.post(
        '/auth/admin/change-password',
        data: {
          'motDePasseActuel': currentPassword,
          'nouveauMotDePasse': newPassword,
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(Failure.serverError(message: 'Mot de passe actuel incorrect'));
      }
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  /// Ping le serveur pour vérifier la connexion
  Future<Either<Failure, ConnectionStatusModel>> checkApiConnection(
      String baseUrl) async {
    try {
      final stopwatch = Stopwatch()..start();

      // On utilise un endpoint léger — GET /api/categories
      final tempDio = Dio()
        ..options.baseUrl = baseUrl
        ..options.connectTimeout = const Duration(seconds: 5)
        ..options.receiveTimeout = const Duration(seconds: 5);

      await tempDio.get('/categories');
      stopwatch.stop();

      return Right(ConnectionStatusModel(
        isOnline: true,
        pingMs: stopwatch.elapsedMilliseconds,
        lastChecked: DateTime.now(),
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return Right(ConnectionStatusModel(
          isOnline: false,
          lastChecked: DateTime.now(),
        ));
      }
      // L'API répond (même avec une erreur) = elle est en ligne
      if (e.response != null) {
        return Right(ConnectionStatusModel(
          isOnline: true,
          pingMs: 0,
          lastChecked: DateTime.now(),
        ));
      }
      return Left(Failure.networkError());
    } catch (e) {
      return Left(Failure.unexpectedError());
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Failure.validationError(
          errors: e.response?.data is Map
              ? e.response?.data['errors'] ?? {'general': 'Données invalides'}
              : {'general': 'Données invalides'},
        );
      case 401:
        return Failure.unauthorized();
      case 404:
        return Failure.notFound();
      case 500:
        return Failure.serverError(
          message: e.response?.data is Map
              ? e.response?.data['message'] ?? 'Erreur serveur'
              : 'Erreur serveur',
        );
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return Failure.networkError();
        }
        return Failure.unexpectedError();
    }
  }
}