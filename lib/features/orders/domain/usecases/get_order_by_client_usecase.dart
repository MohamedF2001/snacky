// features/orders/domain/usecases/get_orders_by_client_usecase.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersByClientUseCase {
  final OrderRepository orderRepository;

  GetOrdersByClientUseCase({required this.orderRepository});

  Future<Either<Failure, List<OrderEntity>>> execute(String clientId) {
    return orderRepository.getOrdersByClient(clientId);
  }
}