// features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:snacky/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:snacky/features/auth/domain/entities/user_entity.dart';
import 'package:snacky/features/auth/domain/repositories/auth_repository.dart';
import 'package:snacky/features/auth/domain/usecases/login_usescase.dart';

class AuthState {
  final bool isLoading;
  final bool isInitializing;
  final UserEntity? user;
  final Failure? error;

  AuthState({
    this.isLoading = false,
    this.isInitializing = true,
    this.user,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isInitializing,
    UserEntity? user,
    Failure? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;

  AuthNotifier({required this.loginUseCase, required this.authRepository})
    : super(AuthState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user, isInitializing: false);
        print('✅ User loaded from storage: ${user.email}');
      } else {
        state = state.copyWith(isInitializing: false);
      }
    } catch (e) {
      print('❌ Error loading user: $e');
      state = state.copyWith(isInitializing: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    print('Attempting login with: $email');

    final result = await loginUseCase.execute(email, password);

    result.fold(
      (failure) {
        print('Login failed: $failure');
        state = state.copyWith(isLoading: false, error: failure);
      },
      (user) {
        print('Login successful: ${user.email}');
        state = state.copyWith(isLoading: false, user: user, error: null);
      },
    );
  }

  /*  Future<void> logout() async {
    try {
      await authRepository.logout();
      // Réinitialiser l'état avec isInitializing à false
      state = AuthState(isInitializing: false);
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
      // Même en cas d'erreur, réinitialiser avec isInitializing à false
      state = AuthState(isInitializing: false);
    }
  } */
  // features/auth/presentation/providers/auth_provider.dart

  Future<void> logout() async {
    try {
      print('🔒 Starting logout process...');
      await authRepository.logout();

      // Réinitialiser complètement l'état
      state = AuthState(isInitializing: false);

      print('✅ Logout completed. isAuthenticated: ${state.isAuthenticated}');
      print('✅ isInitializing: ${state.isInitializing}');
    } catch (e) {
      print('❌ Error during logout: $e');
      state = AuthState(isInitializing: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Le provider doit être DÉFINI EN DEHORS de la classe AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Créer les dépendances nécessaires
  final apiClient = ApiClient();
  final remoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  final loginUseCase = LoginUseCase(authRepository: authRepository);

  return AuthNotifier(
    loginUseCase: loginUseCase,
    authRepository: authRepository,
  );
});
