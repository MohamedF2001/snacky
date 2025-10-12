import 'dart:io';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/promotions/data/datasources/promotion_remote_data_source.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';
import 'package:snacky/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:snacky/features/promotions/data/mappers/promotion_mapper.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotions() async {
    final result = await remoteDataSource.getPromotions();

    return result.fold(
          (failure) => Left(failure),
          (promotions) => Right(promotions.map((p) => p.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, PromotionEntity>> createPromotion(PromotionEntity promotion) async {
    final data = {
      "nom": promotion.nom,
      "tarif": promotion.tarif,
      "produits": promotion.produits.map((p) => p.id).toList(),
      "dateDebut": promotion.dateDebut?.toIso8601String(),
      "dateFin": promotion.dateFin?.toIso8601String(),
    };

    final result = await remoteDataSource.createPromotion(data);

    return result.fold(
          (failure) => Left(failure),
          (model) => Right(model.toEntity()),
    );
  }


  @override
  Future<Either<Failure, PromotionEntity>> getPromotionById(String id) {
    // TODO: implement getPromotionById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deletePromotion(String id) async {
    final result = await remoteDataSource.deletePromotion(id);

    return result.fold(
          (failure) => Left(failure),
          (success) => Right(success), // success est un Unit
    );
  }
}
