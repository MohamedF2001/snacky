// features/orders/domain/usecases/create_order_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository orderRepository;

  CreateOrderUseCase({required this.orderRepository});

  Future<Either<Failure, OrderEntity>> execute(OrderEntity order) {
    return orderRepository.createOrder(order);
  }
}