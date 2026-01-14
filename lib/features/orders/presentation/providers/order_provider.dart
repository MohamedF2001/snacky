import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/core/network/api_client.dart';
import 'package:snacky/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:snacky/features/orders/data/repositories/order_repository_impl.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';

import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/delete_order_usecase.dart';
import '../../domain/usecases/get_order_by_Id_usecase.dart';
import '../../domain/usecases/get_order_by_client_usecase.dart';
import '../../domain/usecases/get_order_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';

// ============ ORDER LIST STATE ============
class OrderListState {
  final bool isLoading;
  final List<OrderEntity> orders;
  final Failure? error;
  final int page;
  final bool hasReachedMax;

  OrderListState({
    this.isLoading = false,
    this.orders = const [],
    this.error,
    this.page = 1,
    this.hasReachedMax = false,
  });

  OrderListState copyWith({
    bool? isLoading,
    List<OrderEntity>? orders,
    Failure? error,
    int? page,
    bool? hasReachedMax,
  }) {
    return OrderListState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      error: error,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// ============ ORDER LIST NOTIFIER ============
class OrderListNotifier extends StateNotifier<OrderListState> {
  final GetOrdersUseCase getOrdersUseCase;

  OrderListNotifier({required this.getOrdersUseCase})
      : super(OrderListState());

  Future<void> getOrders({bool loadMore = false}) async {
    if (state.isLoading) return;

    final nextPage = loadMore ? state.page + 1 : 1;

    state = state.copyWith(isLoading: true, error: null, page: nextPage);

    final result = await getOrdersUseCase.execute();

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          page: loadMore ? state.page : 1,
        );
      },
          (orders) {
        state = state.copyWith(
          isLoading: false,
          orders: loadMore ? [...state.orders, ...orders] : orders,
          hasReachedMax: orders.length < 20,
          error: null,
        );
      },
    );
  }

  // ✅ Nouvelle méthode pour mettre à jour une commande dans la liste
  void updateOrderInList(OrderEntity updatedOrder) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == updatedOrder.id) {
        return updatedOrder;
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ CREATE ORDER STATE ============
class CreateOrderState {
  final bool isLoading;
  final OrderEntity? order;
  final Failure? error;

  CreateOrderState({
    this.isLoading = false,
    this.order,
    this.error,
  });

  CreateOrderState copyWith({
    bool? isLoading,
    OrderEntity? order,
    Failure? error,
  }) {
    return CreateOrderState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      error: error,
    );
  }
}

// ============ CREATE ORDER NOTIFIER ============
class CreateOrderNotifier extends StateNotifier<CreateOrderState> {
  final CreateOrderUseCase createOrderUseCase;

  CreateOrderNotifier({required this.createOrderUseCase})
      : super(CreateOrderState());

  Future<void> createOrder(OrderEntity order) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await createOrderUseCase.execute(order);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
          (createdOrder) {
        state = state.copyWith(
          isLoading: false,
          order: createdOrder,
          error: null,
        );
      },
    );
  }

  void reset() {
    state = CreateOrderState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ GET ORDER BY ID STATE ============
class GetOrderByIdState {
  final bool isLoading;
  final OrderEntity? order;
  final bool success;
  final Failure? error;

  GetOrderByIdState({
    this.isLoading = false,
    this.success = false,
    this.order,
    this.error,
  });

  GetOrderByIdState copyWith({
    bool? isLoading,
    bool? success,
    OrderEntity? order,
    Failure? error,
  }) {
    return GetOrderByIdState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      order: order ?? this.order,
      error: error,
    );
  }
}

// ============ GET ORDER BY ID NOTIFIER ============
class GetOrderByIdNotifier extends StateNotifier<GetOrderByIdState> {
  final GetOrderByIdUseCase getOrderByIdUseCase;

  GetOrderByIdNotifier({required this.getOrderByIdUseCase})
      : super(GetOrderByIdState());

  Future<void> getOrderById(String id) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    final result = await getOrderByIdUseCase.execute(id);

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          success: false,
        );
      },
          (order) {
        state = state.copyWith(
          isLoading: false,
          success: true,
          order: order,
          error: null,
        );
      },
    );
  }

  void reset() => state = GetOrderByIdState();

  void clearError() => state = state.copyWith(error: null);
}

// ============ UPDATE ORDER STATUS STATE ============
class UpdateOrderStatusState {
  final bool isLoading;
  final OrderEntity? order;
  final Failure? error;

  UpdateOrderStatusState({
    this.isLoading = false,
    this.order,
    this.error,
  });

  UpdateOrderStatusState copyWith({
    bool? isLoading,
    OrderEntity? order,
    Failure? error,
  }) {
    return UpdateOrderStatusState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      error: error,
    );
  }
}

// ============ UPDATE ORDER STATUS NOTIFIER ============
/*class UpdateOrderStatusNotifier extends StateNotifier<UpdateOrderStatusState> {
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  UpdateOrderStatusNotifier({required this.updateOrderStatusUseCase})
      : super(UpdateOrderStatusState());

  Future<void> updateOrderStatus(String id, String statut) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await updateOrderStatusUseCase.execute(id, statut);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
          (updatedOrder) {
        state = state.copyWith(
          isLoading: false,
          order: updatedOrder,
          error: null,
        );
      },
    );
  }

  void reset() {
    state = UpdateOrderStatusState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}*/

class UpdateOrderStatusNotifier extends StateNotifier<UpdateOrderStatusState> {
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final Ref ref;

  UpdateOrderStatusNotifier({
    required this.updateOrderStatusUseCase,
    required this.ref,
  }) : super(UpdateOrderStatusState());

  Future<void> updateOrderStatus(String id, String statut) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await updateOrderStatusUseCase.execute(id, statut);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
          (updatedOrder) {
        state = state.copyWith(
          isLoading: false,
          order: updatedOrder,
          error: null,
        );

        // ✅ Mettre à jour seulement l'élément modifié dans la liste
        ref.read(orderListNotifier.notifier).updateOrderInList(updatedOrder);
      },
    );
  }

  void reset() {
    state = UpdateOrderStatusState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ PROVIDERS ============

// Provider pour toutes les commandes
final orderListNotifier =
StateNotifierProvider<OrderListNotifier, OrderListState>((ref) {
  return OrderListNotifier(
    getOrdersUseCase: GetOrdersUseCase(
      orderRepository: OrderRepositoryImpl(
        remoteDataSource: OrderRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  )..getOrders();
});

// Provider pour les commandes d'un client
final ordersByClientNotifier = StateNotifierProvider.family<
    OrdersByClientNotifier,
    OrderListState,
    String>((ref, clientId) {
  return OrdersByClientNotifier(
    getOrdersByClientUseCase: GetOrdersByClientUseCase(
      orderRepository: OrderRepositoryImpl(
        remoteDataSource: OrderRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  )..getOrdersByClient(clientId);
});

// Provider pour créer une commande
final createOrderProvider =
StateNotifierProvider<CreateOrderNotifier, CreateOrderState>((ref) {
  return CreateOrderNotifier(
    createOrderUseCase: CreateOrderUseCase(
      orderRepository: OrderRepositoryImpl(
        remoteDataSource: OrderRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  );
});

// Provider pour récupérer une commande par ID
final detailOrderNotifier = StateNotifierProvider.family<
    GetOrderByIdNotifier,
    GetOrderByIdState,
    String>((ref, orderId) {
  return GetOrderByIdNotifier(
    getOrderByIdUseCase: GetOrderByIdUseCase(
      orderRepository: OrderRepositoryImpl(
        remoteDataSource: OrderRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  )..getOrderById(orderId);
});

// Provider pour mettre à jour le statut d'une commande
final updateOrderStatusProvider = StateNotifierProvider<
    UpdateOrderStatusNotifier,
    UpdateOrderStatusState>((ref) {
  return UpdateOrderStatusNotifier(
    updateOrderStatusUseCase: UpdateOrderStatusUseCase(
      orderRepository: OrderRepositoryImpl(
        remoteDataSource: OrderRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
    ref: ref
  );
});


// ============ ORDERS BY CLIENT STATE ============
class OrdersByClientNotifier extends StateNotifier<OrderListState> {
  final GetOrdersByClientUseCase getOrdersByClientUseCase;

  OrdersByClientNotifier({required this.getOrdersByClientUseCase})
      : super(OrderListState());

  Future<void> getOrdersByClient(String clientId, {
    bool loadMore = false,
  }) async {
    if (state.isLoading) return;

    final nextPage = loadMore ? state.page + 1 : 1;

    state = state.copyWith(isLoading: true, error: null, page: nextPage);

    final result = await getOrdersByClientUseCase.execute(clientId);

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
          page: loadMore ? state.page : 1,
        );
      },
          (orders) {
        state = state.copyWith(
          isLoading: false,
          orders: loadMore ? [...state.orders, ...orders] : orders,
          hasReachedMax: orders.length < 20,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ UPDATE ORDER STATE ============
class UpdateOrderState {
  final bool isLoading;
  final OrderEntity? order;
  final Failure? error;

  UpdateOrderState({
    this.isLoading = false,
    this.order,
    this.error,
  });

  UpdateOrderState copyWith({
    bool? isLoading,
    OrderEntity? order,
    Failure? error,
  }) {
    return UpdateOrderState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      error: error,
    );
  }
}

// ============ UPDATE ORDER NOTIFIER ============
class UpdateOrderNotifier extends StateNotifier<UpdateOrderState> {
  final UpdateOrderUseCase updateOrderUseCase;

  UpdateOrderNotifier({required this.updateOrderUseCase})
      : super(UpdateOrderState());

  Future<void> updateOrder(OrderEntity order) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await updateOrderUseCase.execute(order);

    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
          (updatedOrder) {
        state = state.copyWith(
          isLoading: false,
          order: updatedOrder,
          error: null,
        );
      },
    );
  }

  void reset() {
    state = UpdateOrderState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ DELETE ORDER STATE ============
class DeleteOrderState {
  final bool isLoading;
  final bool success;
  final Failure? error;

  DeleteOrderState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  DeleteOrderState copyWith({
    bool? isLoading,
    bool? success,
    Failure? error,
  }) {
    return DeleteOrderState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}

// ============ DELETE ORDER NOTIFIER ============
class DeleteOrderNotifier extends StateNotifier<DeleteOrderState> {
  final DeleteOrderUseCase deleteOrderUseCase;

  DeleteOrderNotifier({required this.deleteOrderUseCase})
      : super(DeleteOrderState());

  Future<void> deleteOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    final result = await deleteOrderUseCase.execute(orderId);

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
    state = DeleteOrderState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============ NOUVEAUX PROVIDERS ============

// Provider pour mettre à jour une commande
final updateOrderProvider =
StateNotifierProvider<UpdateOrderNotifier, UpdateOrderState>((ref) {
  return UpdateOrderNotifier(
    updateOrderUseCase: UpdateOrderUseCase(
      orderRepository: OrderRepositoryImpl(
        remoteDataSource: OrderRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  );
});

// Provider pour supprimer une commande
final deleteOrderProvider =
StateNotifierProvider<DeleteOrderNotifier, DeleteOrderState>((ref) {
  return DeleteOrderNotifier(
    deleteOrderUseCase: DeleteOrderUseCase(
      orderRepository: OrderRepositoryImpl(
        remoteDataSource: OrderRemoteDataSource(apiClient: ApiClient()),
      ),
    ),
  );
});