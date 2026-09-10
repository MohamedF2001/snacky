import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.serverError({String? message}) = ServerError;
  const factory Failure.networkError() = NetworkError;
  const factory Failure.unauthorized() = Unauthorized;
  const factory Failure.notFound() = NotFound;
  const factory Failure.validationError({
    required Map<String, dynamic> errors,
  }) = ValidationError;
  const factory Failure.unexpectedError() = UnexpectedError;

  const Failure._();

  String get userMessage {
    return when(
      serverError: (message) => message ?? 'Erreur serveur. Veuillez réessayer plus tard.',
      networkError: () => 'Problème de connexion. Vérifiez votre internet.',
      unauthorized: () => 'Accès refusé. Veuillez vous reconnecter.',
      notFound: () => 'La ressource demandée est introuvable.',
      validationError: (errors) => errors.values.join('\n'),
      unexpectedError: () => 'Une erreur inattendue est survenue.',
    );
  }
}

