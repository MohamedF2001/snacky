/*
// features/orders/domain/repositories/order_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders();

  Future<Either<Failure, OrderEntity>> getOrderById(String id);

  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);

  Future<Either<Failure, OrderEntity>> updateOrderStatus(
      String id,
      String statut,
      );

  Future<Either<Failure, List<OrderEntity>>> getOrdersByClient(
      String clientId,
      );
}*/

// features/orders/domain/repositories/order_repository.dart (mise à jour)
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders();

  Future<Either<Failure, OrderEntity>> getOrderById(String id);

  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);

  Future<Either<Failure, OrderEntity>> updateOrder(OrderEntity order);

  Future<Either<Failure, OrderEntity>> updateOrderStatus(
      String id,
      String statut,
      );

  Future<Either<Failure, void>> deleteOrder(String id);

  Future<Either<Failure, List<OrderEntity>>> getOrdersByClient(
      String clientId,
      );
}
