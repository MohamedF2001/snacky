/*import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

// features/orders/domain/usecases/update_order_status_usecase.dart
class UpdateOrderStatusUseCase {
  final OrderRepository orderRepository;

  UpdateOrderStatusUseCase({required this.orderRepository});

  Future<Either<Failure, OrderEntity>> execute(String id, String statut) {
    return orderRepository.updateOrderStatus(id, statut);
  }
}*/



// features/orders/domain/usecases/update_order_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrderUseCase {
  final OrderRepository orderRepository;

  UpdateOrderUseCase({required this.orderRepository});

  Future<Either<Failure, OrderEntity>> execute(OrderEntity order) {
    return orderRepository.updateOrder(order);
  }
}

class UpdateOrderStatusUseCase {
  final OrderRepository orderRepository;

  UpdateOrderStatusUseCase({required this.orderRepository});

  Future<Either<Failure, OrderEntity>> execute(String id, String statut) {
    return orderRepository.updateOrderStatus(id, statut);
  }
}
