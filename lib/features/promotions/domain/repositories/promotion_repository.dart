import 'dart:io';
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<Either<Failure, List<PromotionEntity>>> getPromotions();

  /// 🔥 ajout du [File? imageFile] optionnel
  Future<Either<Failure, PromotionEntity>> createPromotion(
      PromotionEntity promotion
      );

  Future<Either<Failure, PromotionEntity>> getPromotionById(String id);

  Future<Either<Failure, Unit>> deletePromotion(String id); // ✅ nouvelle méthode
}
