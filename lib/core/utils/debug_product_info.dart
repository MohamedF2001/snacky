// core/utils/debug_product_info.dart
// Helper pour extraire les infos d'un produit peu importe son format

import 'package:snacky/core/utils/app_logger.dart';

class ProductInfo {
  final String name;
  final double price;
  final String? imageUrl;
  final String? id;

  ProductInfo({
    required this.name,
    required this.price,
    this.imageUrl,
    this.id,
  });

  static ProductInfo extractFromDynamic(dynamic product) {
    // Si c'est null
    if (product == null) {
      return ProductInfo(name: 'Produit inconnu', price: 0.0);
    }

    // Si c'est une String (juste l'ID)
    if (product is String) {
      return ProductInfo(
        name: 'Produit $product',
        price: 0.0,
        id: product,
      );
    }

    // Si c'est un ProductEntity
    if (product.runtimeType.toString().contains('ProductEntity') ||
        product.runtimeType.toString().contains('ProductModel')) {
      try {
        return ProductInfo(
          name: (product as dynamic).nom ?? 'Produit inconnu',
          price: ((product as dynamic).prix as num?)?.toDouble() ?? 0.0,
          imageUrl: (product as dynamic).imageUrl,
          id: (product as dynamic).id,
        );
      } catch (e) {
        logger.e("❌ Erreur extraction ProductEntity: $e");
      }
    }

    // Si c'est un Map
    if (product is Map) {
      return ProductInfo(
        name: product['nom']?.toString() ?? 'Produit inconnu',
        price: (product['prix'] as num?)?.toDouble() ?? 0.0,
        imageUrl: product['imageUrl']?.toString(),
        id: product['_id']?.toString() ?? product['id']?.toString(),
      );
    }

    // Cas par défaut
    logger.d("⚠️ Type de produit non géré: ${product.runtimeType}");
    logger.d("⚠️ Contenu: $product");
    return ProductInfo(name: 'Produit inconnu', price: 0.0);
  }
}

// Extension pour OrderProductEntity
extension OrderProductEntityExtension on dynamic {
  ProductInfo get productInfo {
    if (this == null) {
      return ProductInfo(name: 'Produit inconnu', price: 0.0);
    }

    // Accéder au champ produit
    try {
      final produit = (this as dynamic).produit;
      return ProductInfo.extractFromDynamic(produit);
    } catch (e) {
      logger.e("❌ Erreur extraction produit: $e");
      return ProductInfo(name: 'Produit inconnu', price: 0.0);
    }
  }
}