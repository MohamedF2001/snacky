import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/promotions/domain/repositories/promotion_repository.dart';

class DeletePromotionUseCase {
  final PromotionRepository repository;

  DeletePromotionUseCase(this.repository);

  Future<Either<Failure, Unit>> execute(String id) async {
    return await repository.deletePromotion(id);
  }
}
