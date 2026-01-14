// features/orders/data/repositories/order_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:snacky/features/orders/data/mappers/order_mapper.dart';
import 'package:snacky/features/orders/data/models/order_model.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/domain/repositories/order_repository.dart';

import '../../../../core/utils/app_logger.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    final result = await remoteDataSource.getOrders();

    return result.fold(
          (failure) => Left(failure),
          (orders) => Right(orders.map((o) => o.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String id) async {
    final result = await remoteDataSource.getOrderById(id);

    return result.fold(
          (failure) => Left(failure),
          (order) => Right(order),
    );
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    // Conversion de l'entité vers le modèle
    final orderModel = OrderModel(
      id: order.id,
      client: order.client,
      nomClient: order.nomClient,
      telephone: order.telephone,
      produits: order.produits
          .map((p) => OrderProductModel(
        id: p.id,
        produit: p.produit,
        quantite: p.quantite,
      ))
          .toList(),
      coutTotal: order.coutTotal,
      statut: order.statut,
      numeroTable: order.numeroTable,
      surPlace: order.surPlace,
      livraison: order.livraison,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );

    logger.d("📤 OrderModel à envoyer: client = ${orderModel.client}");

    final result = await remoteDataSource.createOrder(orderModel);

    return result.fold(
          (failure) => Left(failure),
          (createdOrder) => Right(createdOrder.toEntity()),
    );
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
      String id,
      String statut,
      ) async {
    final result = await remoteDataSource.updateOrderStatus(id, statut);

    return result.fold(
          (failure) => Left(failure),
          (updatedOrder) => Right(updatedOrder.toEntity()),
    );
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrdersByClient(
      String clientId,
      ) async {
    final result = await remoteDataSource.getOrdersByClient(clientId);

    return result.fold(
          (failure) => Left(failure),
          (orders) => Right(orders.map((o) => o.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrder(OrderEntity order) async {
    // Conversion de l'entité vers le modèle
    final orderModel = OrderModel(
      id: order.id,
      client: order.client,
      nomClient: order.nomClient,
      telephone: order.telephone,
      produits: order.produits
          .map((p) => OrderProductModel(
        id: p.id,
        produit: p.produit,
        quantite: p.quantite,
      ))
          .toList(),
      coutTotal: order.coutTotal,
      statut: order.statut,
      numeroTable: order.numeroTable,
      surPlace: order.surPlace,
      livraison: order.livraison,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );

    logger.d('📤 OrderModel à mettre à jour: ${orderModel.id}');

    final result = await remoteDataSource.updateOrder(orderModel);

    return result.fold(
          (failure) => Left(failure),
          (updatedOrder) => Right(updatedOrder.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String id) async {
    final result = await remoteDataSource.deleteOrder(id);

    return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
    );
  }
}