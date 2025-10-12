// features/orders/data/mappers/order_mapper.dart
import 'package:snacky/features/orders/data/models/order_model.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';

extension OrderProductMapper on OrderProductModel {
  OrderProductEntity toEntity() {
    return OrderProductEntity(
      id: id,
      produit: produit,
      quantite: quantite,
    );
  }
}

extension OrderProductEntityMapper on OrderProductEntity {
  OrderProductModel toModel() {
    return OrderProductModel(
      id: id,
      produit: produit,
      quantite: quantite,
    );
  }
}

extension OrderMapper on OrderModel {
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      client: client,
      nomClient: nomClient,
      telephone: telephone,
      produits: produits.map((p) => p.toEntity()).toList(),
      coutTotal: coutTotal,
      statut: statut,
      numeroTable: numeroTable,
      surPlace: surPlace,
      livraison: livraison,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension OrderEntityMapper on OrderEntity {
  OrderModel toModel() {
    return OrderModel(
      id: id,
      client: client,
      nomClient: nomClient,
      telephone: telephone,
      produits: produits
          .map((p) => OrderProductModel(
        id: p.id,
        produit: p.produit,
        quantite: p.quantite,
      ))
          .toList(),
      coutTotal: coutTotal,
      statut: statut,
      numeroTable: numeroTable,
      surPlace: surPlace,
      livraison: livraison,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}