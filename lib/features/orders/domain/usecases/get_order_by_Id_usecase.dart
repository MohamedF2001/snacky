// features/orders/domain/usecases/get_order_by_id_usecase.dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository orderRepository;

  GetOrderByIdUseCase({required this.orderRepository});

  Future<Either<Failure, OrderEntity>> execute(String id) {
    return orderRepository.getOrderById(id);
  }
}