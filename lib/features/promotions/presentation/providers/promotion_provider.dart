
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';
import 'package:snacky/features/promotions/domain/usecases/delete_promotion_usecase.dart';
import 'package:snacky/features/promotions/domain/usecases/get_promotion_usecase.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/promotion_remote_data_source.dart';
import '../../data/repositories/promotion_repository_impl.dart';
import '../../domain/usecases/create_promotion_usecase.dart';

class PromotionListState {
  final bool isLoading;
  final List<PromotionEntity> promotions;
  final Failure? error;
  final int page;
  final bool hasReachedMax;

  PromotionListState({
    this.isLoading = false,
    this.promotions = const [],
    this.error,
    this.page = 1,
    this.hasReachedMax = false,
  });

  PromotionListState copyWith({
    bool? isLoading,
    List<PromotionEntity>? promotions,
    Failure? error,
    int? page,
    bool? hasReachedMax,
  }) {
    return PromotionListState(
      isLoading: isLoading ?? this.isLoading,
      promotions: promotions ?? this.promotions,
      error: error ?? this.error,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class PromotionListNotifier extends StateNotifier<PromotionListState> {
  final GetPromotionUseCase getPromotionUsecase;

  PromotionListNotifier({required this.getPromotionUsecase})
      : super(PromotionListState());

  Future<void> getPromotions({bool loadMore = false}) async {
    if (state.isLoading) return;

    final nextPage = loadMore ? state.page + 1 : 1;

    state = state.copyWith(isLoading: true, error: null, page: nextPage);

    final result = await getPromotionUsecase.execute();

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          page: loadMore ? state.page : 1,
        );
      },
          (promotions) {
        state = state.copyWith(
          isLoading: false,
          promotions: loadMore ? [...state.promotions, ...promotions] : promotions,
          hasReachedMax: promotions.length < 20,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Pour TOUS les produits
final promotionListNotifier =
StateNotifierProvider<PromotionListNotifier, PromotionListState>((ref) {
  return PromotionListNotifier(
    getPromotionUsecase: GetPromotionUseCase(
      promotionRepository: PromotionRepositoryImpl(
        remoteDataSource: PromotionRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  )..getPromotions(); // charge dès le début
});

final createPromotionProvider = Provider<CreatePromotionUseCase>((ref) {
  return CreatePromotionUseCase(
    promotionRepository: PromotionRepositoryImpl(
      remoteDataSource: PromotionRemoteDataSource(apiClient: ApiClient()),
    ),
  );
});


// Delete Promotion State
class DeletePromotionState {
  final bool isLoading;
  final bool success;
  final Failure? error;

  DeletePromotionState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  DeletePromotionState copyWith({
    bool? isLoading,
    bool? success,
    Failure? error,
  }) {
    return DeletePromotionState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
}

class DeletePromotionNotifier extends StateNotifier<DeletePromotionState> {
  final DeletePromotionUseCase deletePromotionUseCase;

  DeletePromotionNotifier({required this.deletePromotionUseCase})
      : super(DeletePromotionState());

  Future<void> deletePromotion(String id) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    final result = await deletePromotionUseCase.execute(id);

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          success: false,
        );
      },
          (_) {
        state = state.copyWith(isLoading: false, success: true, error: null);
      },
    );
  }

  void reset() {
    state = DeletePromotionState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final deletePromotionProvider =
StateNotifierProvider<DeletePromotionNotifier, DeletePromotionState>((ref) {
  return DeletePromotionNotifier(
    deletePromotionUseCase: DeletePromotionUseCase(
      PromotionRepositoryImpl(
        remoteDataSource: PromotionRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  );
});
