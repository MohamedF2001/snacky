// features/orders/data/models/order_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/products/data/models/product_model.dart';
import 'package:snacky/features/auth/data/models/user_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderProductModel extends OrderProductEntity {
  @JsonKey(name: "_id")
  @override
  final String? id;

  @JsonKey(name: "produit", fromJson: _produitFromJson, toJson: _produitToJson)
  @override
  final dynamic produit;

  @JsonKey(name: "quantite", defaultValue: 0)
  @override
  final int quantite;

  const OrderProductModel({
    this.id,
    required this.produit,
    this.quantite = 0,
  }) : super(
    id: id,
    produit: produit,
    quantite: quantite,
  );
  static dynamic _produitFromJson(dynamic json) {
    if (json == null) return null;

    // Si c'est une String (juste l'ID)
    if (json is String) return json;

    // Si c'est un Map (objet complet du produit)
    if (json is Map<String, dynamic>) {
      try {
        // Essayer de parser comme ProductModel
        return ProductModel.fromJson(json);
      } catch (e) {
        print("⚠️ Impossible de parser le produit comme ProductModel: $e");
        // Si le parsing échoue, retourner le Map tel quel
        // Le widget pourra extraire les données directement
        return json;
      }
    }

    // Autre type inattendu
    print("⚠️ Type de produit inattendu: ${json.runtimeType}");
    return json;
  }

  static dynamic _produitToJson(dynamic produit) {
    if (produit == null) return null;
    if (produit is String) return produit;
    if (produit is ProductModel) return produit.toJson();
    return null;
  }

  factory OrderProductModel.fromJson(Map<String, dynamic> json) =>
      _$OrderProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderProductModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderModel extends OrderEntity {
  @JsonKey(name: "_id")
  @override
  final String? id;

  @JsonKey(name: "client", fromJson: _clientFromJson, toJson: _clientToJson)
  @override
  final dynamic client;

  @JsonKey(name: "nomClient")
  @override
  final String nomClient;

  @JsonKey(name: "telephone")
  @override
  final String telephone;

  @JsonKey(name: "produits")
  @override
  final List<OrderProductModel> produits;

  @JsonKey(name: "coutTotal", defaultValue: 0.0)
  @override
  final double coutTotal;

  @JsonKey(name: "statut", defaultValue: "en cours")
  @override
  final String statut;

  // Le problème principal : numeroTable est null dans l'API
  @JsonKey(name: "numeroTable")
  @override
  final int? numeroTable;

  @JsonKey(name: "surPlace", defaultValue: false)
  @override
  final bool surPlace;

  @JsonKey(name: "livraison", defaultValue: false)
  @override
  final bool livraison;

  @JsonKey(name: "createdAt")
  @override
  final DateTime? createdAt;

  @JsonKey(name: "updatedAt")
  @override
  final DateTime? updatedAt;

  @JsonKey(name: "__v")
  final int? v;

  const OrderModel({
    this.id,
    this.client,
    this.nomClient = '',
    this.telephone = '',
    this.produits = const [],
    this.coutTotal = 0.0,
    this.statut = "en cours",
    this.numeroTable, // Déjà nullable, c'est bon
    this.surPlace = false,
    this.livraison = false,
    this.createdAt,
    this.updatedAt,
    this.v,
  }) : super(
    id: id,
    client: client,
    nomClient: nomClient,
    telephone: telephone,
    produits: produits,
    coutTotal: coutTotal,
    statut: statut,
    numeroTable: numeroTable,
    surPlace: surPlace,
    livraison: livraison,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /*static dynamic _clientFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map<String, dynamic>) {
      try {
        return UserModel.fromJson(json);
      } catch (e) {
        print("❌ Error parsing client in _clientFromJson: $e");
        return null;
      }
    }
    return null;
  }

  static dynamic _clientToJson(dynamic client) {
    if (client == null) return null;
    if (client is String) return client;
    if (client is UserModel) return client.toJson();
    return null;
  }*/

  // Dans order_model.dart
  static dynamic _clientFromJson(dynamic json) {
    if (json == null) {
      print("⚠️ Client est null dans la réponse");
      return null;
    }

    if (json is String) {
      print("✅ Client est un ID: $json");
      return json;
    }

    if (json is Map<String, dynamic>) {
      try {
        print("✅ Client est un objet complet: ${json['nom']}");
        return UserModel.fromJson(json);
      } catch (e) {
        print("❌ Erreur parsing client objet: $e");
        // Fallback: retourner l'ID du client
        return json['_id'] as String?;
      }
    }

    print("⚠️ Type de client inattendu: ${json.runtimeType}");
    return null;
  }

  static dynamic _clientToJson(dynamic client) {
    // ✅ Quand on envoie, on envoie toujours null ou un String ID
    if (client == null) return null;
    if (client is String) return client;
    if (client is UserModel) return client.id; // ✅ Envoyer seulement l'ID, pas l'objet complet
    return null;
  }

  // Factory method personnalisée pour gérer les nulls correctement
  /*factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Gestion robuste de numeroTable
      int? parseNumeroTable(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is String) {
          // 🔥 FIX: Convertir la String en int
          return int.tryParse(value);
        }
        if (value is num) return value.toInt();
        return null;
      }

      // Gestion robuste des dates
      DateTime? parseDateTime(dynamic value) {
        if (value == null) return null;
        if (value is DateTime) return value;
        if (value is String) return DateTime.tryParse(value);
        return null;
      }

      // Gestion robuste des produits
      List<OrderProductModel> parseProduits(dynamic value) {
        if (value is List) {
          return value
              .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return OrderProductModel.fromJson(item);
              }
              return null;
            } catch (e) {
              print("❌ Error parsing product item: $e");
              return null;
            }
          })
              .whereType<OrderProductModel>()
              .toList();
        }
        return [];
      }

      // 🔥 FIX: Gestion robuste du téléphone (peut être String ou num)
      String parsePhone(dynamic value) {
        if (value == null) return '';
        if (value is String) return value;
        if (value is num) return value.toString();
        return value.toString();
      }

      return OrderModel(
        id: json['_id'] as String?,
        client: _clientFromJson(json['client']),
        nomClient: (json['nomClient'] as String?) ?? '',
        telephone: parsePhone(json['telephone']), // 🔥 Utiliser la fonction de parsing
        produits: parseProduits(json['produits']),
        coutTotal: (json['coutTotal'] as num?)?.toDouble() ?? 0.0,
        statut: (json['statut'] as String?) ?? 'en cours',
        numeroTable: parseNumeroTable(json['numeroTable']), // 🔥 Gère String ou int
        surPlace: (json['surPlace'] as bool?) ?? false,
        livraison: (json['livraison'] as bool?) ?? false,
        createdAt: parseDateTime(json['createdAt']),
        updatedAt: parseDateTime(json['updatedAt']),
        v: (json['__v'] as num?)?.toInt(),
      );
    } catch (e, stackTrace) {
      print("❌ Critical error in OrderModel.fromJson: $e");
      print("❌ Stack trace: $stackTrace");
      print("❌ Problematic JSON keys: ${json.keys}");
      print("❌ numeroTable value: ${json['numeroTable']} (type: ${json['numeroTable']?.runtimeType})");
      print("❌ telephone value: ${json['telephone']} (type: ${json['telephone']?.runtimeType})");
      rethrow;
    }
  }*/

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Gestion robuste du client
      dynamic parseClient(dynamic value) {
        if (value == null) {
          print("ℹ️ Client null dans la réponse");
          return null;
        }

        if (value is String) {
          print("ℹ️ Client est un ID: $value");
          return value;
        }

        if (value is Map<String, dynamic>) {
          try {
            print("ℹ️ Parsing client objet: ${value['nom']}");
            return UserModel.fromJson(value);
          } catch (e) {
            print("⚠️ Erreur parsing client objet, utilisation de l'ID: $e");
            // Fallback: utiliser l'ID
            return value['_id'] as String?;
          }
        }

        print("⚠️ Type de client inattendu: ${value.runtimeType}");
        return null;
      }

      // Gestion robuste de numeroTable
      int? parseNumeroTable(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
        if (value is num) return value.toInt();
        return null;
      }

      // Gestion robuste des dates
      DateTime? parseDateTime(dynamic value) {
        if (value == null) return null;
        if (value is DateTime) return value;
        if (value is String) return DateTime.tryParse(value);
        return null;
      }

      // Gestion robuste des produits
      List<OrderProductModel> parseProduits(dynamic value) {
        if (value is List) {
          return value
              .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return OrderProductModel.fromJson(item);
              }
              return null;
            } catch (e) {
              print("❌ Error parsing product item: $e");
              return null;
            }
          })
              .whereType<OrderProductModel>()
              .toList();
        }
        return [];
      }

      // Gestion robuste du téléphone
      String parsePhone(dynamic value) {
        if (value == null) return '';
        if (value is String) return value;
        if (value is num) return value.toString();
        return value.toString();
      }

      return OrderModel(
        id: json['_id'] as String?,
        client: parseClient(json['client']), // ✅ Gestion robuste
        nomClient: (json['nomClient'] as String?) ?? '',
        telephone: parsePhone(json['telephone']),
        produits: parseProduits(json['produits']),
        coutTotal: (json['coutTotal'] as num?)?.toDouble() ?? 0.0,
        statut: (json['statut'] as String?) ?? 'en cours',
        numeroTable: parseNumeroTable(json['numeroTable']),
        surPlace: (json['surPlace'] as bool?) ?? false,
        livraison: (json['livraison'] as bool?) ?? false,
        createdAt: parseDateTime(json['createdAt']),
        updatedAt: parseDateTime(json['updatedAt']),
        v: (json['__v'] as num?)?.toInt(),
      );
    } catch (e, stackTrace) {
      print("❌ Critical error in OrderModel.fromJson: $e");
      print("❌ Stack trace: $stackTrace");
      print("❌ JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}