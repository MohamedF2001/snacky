// features/orders/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';

class OrderProductEntity extends Equatable {
  final dynamic produit; // Peut être un ProductEntity ou un String (ID)
  final int quantite;
  final String? id;

  const OrderProductEntity({
    required this.produit,
    this.quantite = 0,
    this.id,
  });

  @override
  List<Object?> get props => [produit, quantite, id];
}

class OrderEntity extends Equatable {
  final String? id;
  final dynamic client; // Peut être un UserEntity ou un String (ID)
  final String nomClient;
  final String telephone;
  final List<OrderProductEntity> produits;
  final double coutTotal;
  final String statut; // "en cours", "terminé", "annulé"
  final int? numeroTable;
  final bool surPlace;
  final bool livraison;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    this.id,
    this.client,
    this.nomClient = '',
    this.telephone = '',
    this.produits = const [],
    this.coutTotal = 0.0,
    this.statut = "en cours",
    this.numeroTable,
    this.surPlace = false,
    this.livraison = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    client,
    nomClient,
    telephone,
    produits,
    coutTotal,
    statut,
    numeroTable,
    surPlace,
    livraison,
    createdAt,
    updatedAt,
  ];
}