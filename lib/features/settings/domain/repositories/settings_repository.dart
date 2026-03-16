// features/settings/domain/repositories/settings_repository.dart

import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<AppSettingsEntity> loadSettings();
  Future<void> saveSettings(AppSettingsEntity settings);
  Future<Either<Failure, AdminProfileEntity>> getAdminProfile();
  Future<Either<Failure, AdminProfileEntity>> updateAdminProfile({
    required String nom,
    required String email,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, ConnectionStatusEntity>> checkApiConnection();
  Future<void> clearLocalCache();
  Future<List<Map<String, dynamic>>> getLoginHistory();
}