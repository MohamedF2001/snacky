import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/auth/domain/entities/user_entity.dart';
import 'package:snacky/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  Future<Either<Failure, UserEntity>> execute(String email, String password) {
    return authRepository.login(email, password);
  }
}
