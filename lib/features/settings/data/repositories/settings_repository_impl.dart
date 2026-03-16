// features/settings/data/repositories/settings_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snacky/core/error/failures.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../datasources/settings_remote_data_source.dart';
import '../models/settings_models.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<AppSettingsEntity> loadSettings() async {
    return await localDataSource.loadSettings();
  }

  @override
  Future<void> saveSettings(AppSettingsEntity settings) async {
    final model = AppSettingsModel(
      demoMode: settings.demoMode,
      apiBaseUrl: settings.apiBaseUrl,
      connectTimeout: settings.connectTimeout,
      receiveTimeout: settings.receiveTimeout,
      theme: settings.theme,
      language: settings.language,
      currency: settings.currency,
      notifications: settings.notifications,
    );
    await localDataSource.saveSettings(model);
  }

  @override
  Future<Either<Failure, AdminProfileEntity>> getAdminProfile() async {
    // D'abord, on essaie depuis l'API
    final remoteResult = await remoteDataSource.getAdminProfile();

    return remoteResult.fold(
          (failure) async {
        // En cas d'échec API, on charge depuis SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          final id = prefs.getString('userId') ?? '';
          final nom = prefs.getString('userName') ?? '';
          final email = prefs.getString('userEmail') ?? '';
          final role = prefs.getString('userRole') ?? 'Admin';

          if (id.isEmpty) return Left(failure);

          return Right(AdminProfileModel(
            id: id,
            nom: nom,
            email: email,
            role: role,
          ));
        } catch (_) {
          return Left(failure);
        }
      },
          (profile) => Right(profile),
    );
  }

  @override
  Future<Either<Failure, AdminProfileEntity>> updateAdminProfile({
    required String nom,
    required String email,
  }) async {
    return await remoteDataSource.updateAdminProfile(nom: nom, email: email);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<Either<Failure, ConnectionStatusEntity>> checkApiConnection() async {
    final settings = await localDataSource.loadSettings();
    // Construire l'URL brute sans le proxy CORS
    const rawUrl = 'https://snacky-api.vercel.app/api';
    return await remoteDataSource.checkApiConnection(rawUrl);
  }

  @override
  Future<void> clearLocalCache() async {
    await localDataSource.clearCache();
  }

  @override
  Future<List<Map<String, dynamic>>> getLoginHistory() async {
    return await localDataSource.getLoginHistory();
  }
}