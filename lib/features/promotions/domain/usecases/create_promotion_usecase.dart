import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class CreatePromotionUseCase {
  final PromotionRepository promotionRepository;

  CreatePromotionUseCase({required this.promotionRepository});

  Future<Either<Failure, PromotionEntity>> execute(PromotionEntity promotion) {
    return promotionRepository.createPromotion(promotion);
  }
}
