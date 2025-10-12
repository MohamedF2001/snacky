import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';

import '../repositories/promotion_repository.dart';

class GetPromotionUseCase {
  final PromotionRepository promotionRepository;

  GetPromotionUseCase({required this.promotionRepository});

  Future<Either<Failure, List<PromotionEntity>>> execute() {
    return promotionRepository.getPromotions();
  }
}
