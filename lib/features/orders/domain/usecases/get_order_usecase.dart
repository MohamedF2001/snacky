import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository orderRepository;

  GetOrdersUseCase({required this.orderRepository});

  Future<Either<Failure, List<OrderEntity>>> execute() {
    return orderRepository.getOrders();
  }
}
