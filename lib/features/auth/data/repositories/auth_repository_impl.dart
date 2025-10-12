import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:snacky/features/auth/data/mappers/user_mapper.dart';
import 'package:snacky/features/auth/domain/entities/user_entity.dart';
import 'package:snacky/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  // features/auth/data/repositories/auth_repository_impl.dart

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    final result = await remoteDataSource.login(email, password);

    return result.fold((failure) => Left(failure), (userModel) async {
      final userEntity = userModel.toEntity();

      // Sauvegarder le token et les infos utilisateur
      if (userEntity.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', userEntity.token!);
        await prefs.setString('userId', userEntity.id);
        await prefs.setString('userEmail', userEntity.email);
        await prefs.setString('userName', userEntity.nom);
        await prefs.setString('userRole', userEntity.role);
      }

      return Right(userEntity);
    });
  }

  // features/auth/data/repositories/auth_repository_impl.dart

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userRole');
    print('✅ User logged out and storage cleared');
  }

  // features/auth/data/repositories/auth_repository_impl.dart

  @override
  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');
    final userName = prefs.getString('userName');
    final userRole = prefs.getString('userRole');

    if (token != null && userId != null && userEmail != null) {
      return UserEntity(
        id: userId,
        nom: userName ?? '',
        email: userEmail,
        role: userRole ?? 'Client',
        token: token,
      );
    }

    return null;
  }
}
