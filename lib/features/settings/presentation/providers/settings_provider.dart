// features/settings/presentation/providers/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import '../../data/datasources/settings_local_data_source.dart';
import '../../data/datasources/settings_remote_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/usecases/settings_usecases.dart';

// ─── Settings State ───────────────────────────────────────────────────────────

class SettingsState {
  final bool isLoading;
  final AppSettingsEntity settings;
  final Failure? error;
  final String? successMessage;

  const SettingsState({
    this.isLoading = false,
    this.settings = const AppSettingsEntity(),
    this.error,
    this.successMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    AppSettingsEntity? settings,
    Failure? error,
    String? successMessage,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      error: error,
      successMessage: successMessage,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final LoadSettingsUseCase _load;
  final SaveSettingsUseCase _save;
  final ClearCacheUseCase _clearCache;

  SettingsNotifier({
    required LoadSettingsUseCase load,
    required SaveSettingsUseCase save,
    required ClearCacheUseCase clearCache,
  })  : _load = load,
        _save = save,
        _clearCache = clearCache,
        super(const SettingsState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final settings = await _load.execute();
    state = state.copyWith(isLoading: false, settings: settings);
  }

  Future<void> toggleDemoMode(bool value) async {
    final updated = state.settings.copyWith(demoMode: value);
    state = state.copyWith(settings: updated);
    await _save.execute(updated);
  }

  Future<void> updateApiUrl(String url) async {
    final updated = state.settings.copyWith(apiBaseUrl: url);
    state = state.copyWith(settings: updated);
    await _save.execute(updated);
  }

  Future<void> updateTimeouts({int? connect, int? receive}) async {
    final updated = state.settings.copyWith(
      connectTimeout: connect,
      receiveTimeout: receive,
    );
    state = state.copyWith(settings: updated);
    await _save.execute(updated);
  }

  Future<void> updateTheme(String theme) async {
    final updated = state.settings.copyWith(theme: theme);
    state = state.copyWith(settings: updated);
    await _save.execute(updated);
  }

  Future<void> updateCurrency(String currency) async {
    final updated = state.settings.copyWith(currency: currency);
    state = state.copyWith(settings: updated);
    await _save.execute(updated);
  }

  Future<void> updateNotification(String key, bool value) async {
    final notifs = state.settings.notifications;
    final updatedNotifs = notifs.copyWith(
      newOrder: key == 'newOrder' ? value : notifs.newOrder,
      pendingOrder: key == 'pendingOrder' ? value : notifs.pendingOrder,
      cancelledOrder: key == 'cancelledOrder' ? value : notifs.cancelledOrder,
      lowStock: key == 'lowStock' ? value : notifs.lowStock,
      newProduct: key == 'newProduct' ? value : notifs.newProduct,
    );
    final updated = state.settings.copyWith(notifications: updatedNotifs);
    state = state.copyWith(settings: updated);
    await _save.execute(updated);
  }

  Future<void> clearCache() async {
    state = state.copyWith(isLoading: true);
    await _clearCache.execute();
    state = state.copyWith(
      isLoading: false,
      successMessage: 'Cache vidé avec succès',
    );
  }

  void clearMessage() {
    state = state.copyWith(successMessage: null);
  }
}

// ─── Profile State ────────────────────────────────────────────────────────────

class ProfileState {
  final bool isLoading;
  final AdminProfileEntity? profile;
  final Failure? error;
  final bool updateSuccess;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
    this.updateSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    AdminProfileEntity? profile,
    Failure? error,
    bool? updateSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetAdminProfileUseCase _getProfile;
  final UpdateAdminProfileUseCase _updateProfile;

  ProfileNotifier({
    required GetAdminProfileUseCase getProfile,
    required UpdateAdminProfileUseCase updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getProfile.execute();
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f),
          (p) => state = state.copyWith(isLoading: false, profile: p),
    );
  }

  Future<void> updateProfile({required String nom, required String email}) async {
    state = state.copyWith(isLoading: true, error: null, updateSuccess: false);
    final result = await _updateProfile.execute(nom: nom, email: email);
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f),
          (p) => state = state.copyWith(
          isLoading: false, profile: p, updateSuccess: true),
    );
  }

  void clearState() {
    state = state.copyWith(error: null, updateSuccess: false);
  }
}

// ─── Security State ───────────────────────────────────────────────────────────

class SecurityState {
  final bool isLoading;
  final Failure? error;
  final bool changeSuccess;
  final List<Map<String, dynamic>> loginHistory;

  const SecurityState({
    this.isLoading = false,
    this.error,
    this.changeSuccess = false,
    this.loginHistory = const [],
  });

  SecurityState copyWith({
    bool? isLoading,
    Failure? error,
    bool? changeSuccess,
    List<Map<String, dynamic>>? loginHistory,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      changeSuccess: changeSuccess ?? this.changeSuccess,
      loginHistory: loginHistory ?? this.loginHistory,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final ChangePasswordUseCase _changePassword;
  final SettingsRepositoryImpl _repository;

  SecurityNotifier({
    required ChangePasswordUseCase changePassword,
    required SettingsRepositoryImpl repository,
  })  : _changePassword = changePassword,
        _repository = repository,
        super(const SecurityState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.getLoginHistory();
    state = state.copyWith(loginHistory: history);
  }

  Future<void> changePassword({
    required String current,
    required String newPass,
  }) async {
    state = state.copyWith(isLoading: true, error: null, changeSuccess: false);
    final result = await _changePassword.execute(
      currentPassword: current,
      newPassword: newPass,
    );
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f),
          (_) => state = state.copyWith(isLoading: false, changeSuccess: true),
    );
  }

  void clearState() {
    state = state.copyWith(error: null, changeSuccess: false);
  }
}

// ─── Connection State ─────────────────────────────────────────────────────────

class ConnectionState {
  final bool isChecking;
  final ConnectionStatusEntity? status;
  final Failure? error;

  const ConnectionState({
    this.isChecking = false,
    this.status,
    this.error,
  });

  ConnectionState copyWith({
    bool? isChecking,
    ConnectionStatusEntity? status,
    Failure? error,
  }) {
    return ConnectionState(
      isChecking: isChecking ?? this.isChecking,
      status: status ?? this.status,
      error: error,
    );
  }
}

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  final CheckApiConnectionUseCase _check;

  ConnectionNotifier({required CheckApiConnectionUseCase check})
      : _check = check,
        super(const ConnectionState());

  Future<void> check() async {
    state = state.copyWith(isChecking: true, error: null);
    final result = await _check.execute();
    result.fold(
          (f) => state = state.copyWith(isChecking: false, error: f),
          (s) => state = state.copyWith(isChecking: false, status: s),
    );
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

SettingsRepositoryImpl _buildRepo() {
  final api = ApiClient();
  return SettingsRepositoryImpl(
    localDataSource: SettingsLocalDataSource(),
    remoteDataSource: SettingsRemoteDataSource(apiClient: api),
  );
}

final settingsProvider =
StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repo = _buildRepo();
  return SettingsNotifier(
    load: LoadSettingsUseCase(repo),
    save: SaveSettingsUseCase(repo),
    clearCache: ClearCacheUseCase(repo),
  );
});

final profileProvider =
StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repo = _buildRepo();
  return ProfileNotifier(
    getProfile: GetAdminProfileUseCase(repo),
    updateProfile: UpdateAdminProfileUseCase(repo),
  );
});

final securityProvider =
StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  final repo = _buildRepo();
  return SecurityNotifier(
    changePassword: ChangePasswordUseCase(repo),
    repository: repo,
  );
});

final connectionProvider =
StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  final repo = _buildRepo();
  return ConnectionNotifier(check: CheckApiConnectionUseCase(repo));
});