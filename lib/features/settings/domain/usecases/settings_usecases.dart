// features/settings/domain/usecases/settings_usecases.dart

import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class LoadSettingsUseCase {
  final SettingsRepository repository;
  LoadSettingsUseCase(this.repository);
  Future<AppSettingsEntity> execute() => repository.loadSettings();
}

class SaveSettingsUseCase {
  final SettingsRepository repository;
  SaveSettingsUseCase(this.repository);
  Future<void> execute(AppSettingsEntity settings) =>
      repository.saveSettings(settings);
}

class GetAdminProfileUseCase {
  final SettingsRepository repository;
  GetAdminProfileUseCase(this.repository);
  Future<Either<Failure, AdminProfileEntity>> execute() =>
      repository.getAdminProfile();
}

class UpdateAdminProfileUseCase {
  final SettingsRepository repository;
  UpdateAdminProfileUseCase(this.repository);
  Future<Either<Failure, AdminProfileEntity>> execute({
    required String nom,
    required String email,
  }) =>
      repository.updateAdminProfile(nom: nom, email: email);
}

class ChangePasswordUseCase {
  final SettingsRepository repository;
  ChangePasswordUseCase(this.repository);
  Future<Either<Failure, void>> execute({
    required String currentPassword,
    required String newPassword,
  }) =>
      repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}

class CheckApiConnectionUseCase {
  final SettingsRepository repository;
  CheckApiConnectionUseCase(this.repository);
  Future<Either<Failure, ConnectionStatusEntity>> execute() =>
      repository.checkApiConnection();
}

class ClearCacheUseCase {
  final SettingsRepository repository;
  ClearCacheUseCase(this.repository);
  Future<void> execute() => repository.clearLocalCache();
}