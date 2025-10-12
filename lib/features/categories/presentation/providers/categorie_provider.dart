import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/features/categories/data/datasources/categorie_remote_data_source.dart';
import 'package:snacky/features/categories/data/repositories/categorie_repository_impl.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';
import 'package:snacky/features/categories/domain/usecases/create_categorie_usecase.dart';
import 'package:snacky/features/categories/domain/usecases/delete_categorie_usecase.dart';
import 'package:snacky/features/categories/domain/usecases/get_categorie_usecase.dart';

// Categorie List State
class CategorieListState {
  final bool isLoading;
  final List<CategorieEntity> categories;
  final Failure? error;
  final bool hasReachedMax;

  CategorieListState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
    this.hasReachedMax = false,
  });

  CategorieListState copyWith({
    bool? isLoading,
    List<CategorieEntity>? categories,
    Failure? error,
    int? page,
    bool? hasReachedMax,
  }) {
    return CategorieListState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class CategorieListNotifier extends StateNotifier<CategorieListState> {
  final GetCategorieUsecase getCategorieUsecase;

  CategorieListNotifier({required this.getCategorieUsecase})
    : super(CategorieListState());

  Future<void> getCategories({bool loadMore = false}) async {
    if (state.isLoading) return;

    //final nextPage = loadMore ? state.page + 1 : 1;

    state = state.copyWith(isLoading: true, error: null);

    final result = await getCategorieUsecase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          //page: loadMore ? state.page : 1,
        );
      },
      (categories) {
        state = state.copyWith(
          isLoading: false,
          categories: loadMore
              ? [...state.categories, ...categories]
              : categories,
          hasReachedMax: categories.length < 20,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final categorieListNotifier =
    StateNotifierProvider<CategorieListNotifier, CategorieListState>((ref) {
      // TODO: Injecter le GetProductsUseCase correctement
      return CategorieListNotifier(
        getCategorieUsecase: GetCategorieUsecase(
          categorieRepository: CategorieRepositoryImpl(
            remoteDataSource: CategorieRemoteDataSource(apiClient: ApiClient()),
          ),
        ),
      );
    });

// Create Category State
class CreateCategoryState {
  final bool isLoading;
  final CategorieEntity? category;
  final Failure? error;

  CreateCategoryState({this.isLoading = false, this.category, this.error});

  CreateCategoryState copyWith({
    bool? isLoading,
    CategorieEntity? category,
    Failure? error,
  }) {
    return CreateCategoryState(
      isLoading: isLoading ?? this.isLoading,
      category: category ?? this.category,
      error: error ?? this.error,
    );
  }
}

class CreateCategoryNotifier extends StateNotifier<CreateCategoryState> {
  final CreateCategorieUsecase createCategoryUseCase;

  CreateCategoryNotifier({required this.createCategoryUseCase})
    : super(CreateCategoryState());

  Future<void> createCategory(CategorieEntity category) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await createCategoryUseCase.execute(category);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
      (createdCategory) {
        state = state.copyWith(
          isLoading: false,
          category: createdCategory,
          error: null,
        );
      },
    );
  }

  void reset() {
    state = CreateCategoryState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final createCategoryProvider =
    StateNotifierProvider<CreateCategoryNotifier, CreateCategoryState>((ref) {
      // TODO: Injecter le CreateCategoryUseCase correctement
      return CreateCategoryNotifier(
        createCategoryUseCase: CreateCategorieUsecase(
          categorieRepository: CategorieRepositoryImpl(
            remoteDataSource: CategorieRemoteDataSource(apiClient: ApiClient()),
          ),
        ),
      );
    });

// Delete Category State
class DeleteCategoryState {
  final bool isLoading;
  final bool success;
  final Failure? error;

  DeleteCategoryState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  DeleteCategoryState copyWith({
    bool? isLoading,
    bool? success,
    Failure? error,
  }) {
    return DeleteCategoryState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
}

class DeleteCategoryNotifier extends StateNotifier<DeleteCategoryState> {
  final DeleteCategoryUseCase deleteCategoryUseCase;

  DeleteCategoryNotifier({required this.deleteCategoryUseCase})
    : super(DeleteCategoryState());

  Future<void> deleteCategory(String id) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    final result = await deleteCategoryUseCase.execute(id);

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
    state = DeleteCategoryState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final deleteCategoryProvider =
    StateNotifierProvider<DeleteCategoryNotifier, DeleteCategoryState>((ref) {
      return DeleteCategoryNotifier(
        deleteCategoryUseCase: DeleteCategoryUseCase(
          CategorieRepositoryImpl(
            remoteDataSource: CategorieRemoteDataSource(apiClient: ApiClient()),
          ),
        ),
      );
    });
