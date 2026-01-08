import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/config/app_config.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      print('🔐 Attempting login to: ${AppConfig.baseUrl}/auth/admin/login');

      final response = await apiClient.dio.post(
        '/auth/admin/login',
        data: {'email': email, 'motDePasse': password},
      );

      print('✅ Login API Response: ${response.data}');

      final responseData = response.data;

      if (responseData['token'] != null && responseData['user'] != null) {
        final userModel = UserModel(
          id: responseData['user']['id'],
          nom: responseData['user']['nom'],
          email: responseData['user']['email'],
          role: responseData['user']['role'],
          token: responseData['token'],
        );

        print('👤 User model created: ${userModel.toJson()}');
        return Right(userModel);
      }

      print('❌ Invalid response structure');
      return Left(Failure.unexpectedError());
    } on DioException catch (e) {
      print('❌ DioException Type: ${e.type}');
      print('❌ DioException Message: ${e.message}');

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return Left(
          Failure.serverError(message: 'Erreur de connexion au serveur'),
        );
      } else if (e.response?.statusCode == 401) {
        return Left(Failure.unauthorized());
      } else if (e.response?.statusCode == 400) {
        return Left(
          Failure.validationError(errors: e.response?.data['errors'] ?? {}),
        );
      } else if (e.response?.statusCode == 500) {
        return Left(Failure.serverError(message: e.response?.data['message']));
      } else {
        return Left(
          Failure.serverError(message: 'Impossible de se connecter au serveur'),
        );
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      return Left(Failure.serverError(message: 'Erreur inattendue: $e'));
    }
  }
}
