import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/features/products/data/datasources/product_remote_data_source.dart';
import 'package:snacky/features/products/data/repositories/product_repository_impl.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/domain/usecases/create_product_usecase.dart';
import 'package:snacky/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:snacky/features/products/domain/usecases/get_products_by_categorie_usecase.dart';
import 'package:snacky/features/products/domain/usecases/get_products_usecase.dart';

import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';

class ProductListState {
  final bool isLoading;
  final List<ProductEntity> products;
  final Failure? error;
  final int page;
  final bool hasReachedMax;

  ProductListState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.page = 1,
    this.hasReachedMax = false,
  });

  ProductListState copyWith({
    bool? isLoading,
    List<ProductEntity>? products,
    Failure? error,
    int? page,
    bool? hasReachedMax,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error ?? this.error,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final GetProductsUseCase getProductsUsecase;

  ProductListNotifier({required this.getProductsUsecase})
    : super(ProductListState());

  Future<void> getProduits({bool loadMore = false}) async {
    if (state.isLoading) return;

    final nextPage = loadMore ? state.page + 1 : 1;

    state = state.copyWith(isLoading: true, error: null, page: nextPage);

    final result = await getProductsUsecase.execute();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          page: loadMore ? state.page : 1,
        );
      },
      (products) {
        state = state.copyWith(
          isLoading: false,
          products: loadMore ? [...state.products, ...products] : products,
          hasReachedMax: products.length < 20,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class ProductByCategorieNotifier extends StateNotifier<ProductListState> {
  final GetProductsByCategorieUseCase getProductsByCategorieUsecase;

  ProductByCategorieNotifier({required this.getProductsByCategorieUsecase})
    : super(ProductListState());

  Future<void> getProductsByCategorie(
    String categorieId, {
    bool loadMore = false,
  }) async {
    if (state.isLoading) return;

    final nextPage = loadMore ? state.page + 1 : 1;

    state = state.copyWith(isLoading: true, error: null, page: nextPage);

    final result = await getProductsByCategorieUsecase.execute(categorieId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          page: loadMore ? state.page : 1,
        );
      },
      (products) {
        state = state.copyWith(
          isLoading: false,
          products: loadMore ? [...state.products, ...products] : products,
          hasReachedMax: products.length < 20,
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
final productListNotifier =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
      return ProductListNotifier(
        getProductsUsecase: GetProductsUseCase(
          productRepository: ProductRepositoryImpl(
            remoteDataSource: ProductRemoteDataSource(apiClient: ApiClient()),
          ),
        ),
      )..getProduits(); // charge dès le début
    });

// Pour produits d’une catégorie donnée
final productByCategorieNotifier =
    StateNotifierProvider.family<
      ProductByCategorieNotifier,
      ProductListState,
      String
    >((ref, categorieId) {
      return ProductByCategorieNotifier(
        getProductsByCategorieUsecase: GetProductsByCategorieUseCase(
          productRepository: ProductRepositoryImpl(
            remoteDataSource: ProductRemoteDataSource(apiClient: ApiClient()),
          ),
        ),
      )..getProductsByCategorie(categorieId);
    });


class CreateProductState {
  final bool isLoading;
  final ProductEntity? product;
  final Failure? error;

  CreateProductState({this.isLoading = false, this.product, this.error});

  CreateProductState copyWith({
    bool? isLoading,
    ProductEntity? product,
    Failure? error,
  }) {
    return CreateProductState(
      isLoading: isLoading ?? this.isLoading,
      product: product ?? this.product,
      error: error, // on écrase toujours pour pouvoir clear
    );
  }
}

class CreateProductNotifier extends StateNotifier<CreateProductState> {
  final CreateProductUseCase createProductUseCase;

  CreateProductNotifier({required this.createProductUseCase})
    : super(CreateProductState());

  /// 🔥 nouvelle signature avec [File? imageFile]
  Future<void> createProduct(
    ProductEntity product, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await createProductUseCase.execute(
      product,
      imageFile: imageFile,
      imageBytes: imageBytes,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
      (createdProduct) {
        state = state.copyWith(
          isLoading: false,
          product: createdProduct,
          error: null,
        );
      },
    );
  }

  void reset() {
    state = CreateProductState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final createProductProvider =
    StateNotifierProvider<CreateProductNotifier, CreateProductState>((ref) {
      return CreateProductNotifier(
        createProductUseCase: CreateProductUseCase(
          productRepository: ProductRepositoryImpl(
            remoteDataSource: ProductRemoteDataSource(apiClient: ApiClient()),
          ),
        ),
      );
    });

// Get Product By ID State
class GetProductByIdState {
  final bool isLoading;
  final ProductEntity? product;
  final bool success;
  final Failure? error;

  GetProductByIdState({
    this.isLoading = false,
    this.success = false,
    this.product,
    this.error,
  });

  GetProductByIdState copyWith({
    bool? isLoading,
    bool? success,
    ProductEntity? product,
    Failure? error,
  }) {
    return GetProductByIdState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      product: product ?? this.product,
      error: error, // on écrase toujours pour pouvoir clear
    );
  }
}

class GetProductByIdNotifier extends StateNotifier<GetProductByIdState> {
  final GetProductByIdUsecase getProductByIdUsecase;

  GetProductByIdNotifier({required this.getProductByIdUsecase})
    : super(GetProductByIdState());

  Future<void> getProductById(String id) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    final result = await getProductByIdUsecase.execute(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          success: false,
        );
      },
      (product) {
        // ici tu récupères bien ton produit
        state = state.copyWith(
          isLoading: false,
          success: true,
          product: product,
          error: null,
        );
      },
    );
  }

  void reset() => state = GetProductByIdState();

  void clearError() => state = state.copyWith(error: null);
}

final detailProductNotifier =
    StateNotifierProvider.family<
      GetProductByIdNotifier,
      GetProductByIdState,
      String
    >((ref, productId) {
      return GetProductByIdNotifier(
        getProductByIdUsecase: GetProductByIdUsecase(
          ProductRepositoryImpl(
            remoteDataSource: ProductRemoteDataSource(apiClient: ApiClient()),
          ),
        ),
      )..getProductById(productId); // <-- appel explicite de la méthode
    });

// ============ UPDATE PRODUCT STATE ============
class UpdateProductState {
  final bool isLoading;
  final ProductEntity? product;
  final Failure? error;

  UpdateProductState({
    this.isLoading = false,
    this.product,
    this.error,
  });

  UpdateProductState copyWith({
    bool? isLoading,
    ProductEntity? product,
    Failure? error,
  }) {
    return UpdateProductState(
      isLoading: isLoading ?? this.isLoading,
      product: product ?? this.product,
      error: error,
    );
  }
}

// ============ UPDATE PRODUCT NOTIFIER ============
class UpdateProductNotifier extends StateNotifier<UpdateProductState> {
  final UpdateProductUseCase updateProductUseCase;

  UpdateProductNotifier({required this.updateProductUseCase})
      : super(UpdateProductState());

  Future<void> updateProduct(
      ProductEntity product, {
        File? imageFile,
        Uint8List? imageBytes,
      }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await updateProductUseCase.execute(
      product,
      imageFile: imageFile,
      imageBytes: imageBytes,
    );

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
          (updatedProduct) {
        state = state.copyWith(
          isLoading: false,
          product: updatedProduct,
          error: null,
        );
      },
    );
  }

  void reset() {
    state = UpdateProductState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ DELETE PRODUCT STATE ============
class DeleteProductState {
  final bool isLoading;
  final bool success;
  final Failure? error;

  DeleteProductState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  DeleteProductState copyWith({
    bool? isLoading,
    bool? success,
    Failure? error,
  }) {
    return DeleteProductState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}

// ============ DELETE PRODUCT NOTIFIER ============
class DeleteProductNotifier extends StateNotifier<DeleteProductState> {
  final DeleteProductUseCase deleteProductUseCase;

  DeleteProductNotifier({required this.deleteProductUseCase})
      : super(DeleteProductState());

  Future<void> deleteProduct(String productId) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    final result = await deleteProductUseCase.execute(productId);

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          success: false,
        );
      },
          (_) {
        state = state.copyWith(
          isLoading: false,
          success: true,
          error: null,
        );
      },
    );
  }

  void reset() {
    state = DeleteProductState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ NOUVEAUX PROVIDERS ============

// Provider pour mettre à jour un produit
final updateProductProvider =
StateNotifierProvider<UpdateProductNotifier, UpdateProductState>((ref) {
  return UpdateProductNotifier(
    updateProductUseCase: UpdateProductUseCase(
      productRepository: ProductRepositoryImpl(
        remoteDataSource: ProductRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  );
});

// Provider pour supprimer un produit
final deleteProductProvider =
StateNotifierProvider<DeleteProductNotifier, DeleteProductState>((ref) {
  return DeleteProductNotifier(
    deleteProductUseCase: DeleteProductUseCase(
      productRepository: ProductRepositoryImpl(
        remoteDataSource: ProductRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  );
});

