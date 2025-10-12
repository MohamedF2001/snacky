/*
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../repositories/order_repository.dart';

class DeleteOrderUsecase {
  final OrderRepository repository;

  DeleteOrderUsecase({required this.repository});

  Future<Either<Failure, Unit>> execute(String orderId) {
    return repository.deleteOrder(orderId);
  }
}
*/

// features/orders/domain/usecases/delete_order_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import '../repositories/order_repository.dart';

class DeleteOrderUseCase {
  final OrderRepository orderRepository;

  DeleteOrderUseCase({required this.orderRepository});

  Future<Either<Failure, void>> execute(String orderId) {
    return orderRepository.deleteOrder(orderId);
  }
}


