/*
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../const/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String id;
  final String name;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;
  final Color backgroundColor;

  const CategoryCard({
    super.key,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
    this.isDeleting = false,
    this.backgroundColor = AppColors.chipPrice, // Colors.orange[100]
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageCat(imagePath),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: *//*isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    :*//* const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCat(String path) {
    if (path.startsWith("http")) {
      // Image depuis Internet => Shimmer
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          path,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 120, height: 120, color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fastfood, size: 40),
          ),
        ),
      );
    } else {
      // Image locale => pas besoin de shimmer
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, width: 120, height: 120, fit: BoxFit.cover),
      );
    }
  }
}

class CategoryCardTwo extends StatelessWidget {
  final String id;
  final String name;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;
  final Color backgroundColor;

  const CategoryCardTwo({
    super.key,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
    this.isDeleting = false,
    //this.backgroundColor = const Color(0x5CFFE0B2), // Colors.orange[100]
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageCat(imagePath),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            *//*Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: *//**//*isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    :*//**//* const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ),*//*
          ],
        ),
      ),
    );
  }

  Widget _buildImageCat(String path) {
    if (path.startsWith("http")) {
      // Image depuis Internet => Shimmer
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          path,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 60, height: 60, color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fastfood, size: 40),
          ),
        ),
      );
    } else {
      // Image locale => pas besoin de shimmer
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, width: 60, height: 60, fit: BoxFit.cover),
      );
    }
  }
}*/


import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../const/app_colors.dart';

/// Carte de catégorie optimisée pour l'affichage en LISTE (mobile)
class CategoryListCard extends StatelessWidget {
  final String id;
  final String name;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;
  final Color backgroundColor;

  const CategoryListCard({
    super.key,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
    this.isDeleting = false,
    this.backgroundColor = AppColors.chipPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image à gauche
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildImageCat(imagePath),
            ),

            // Nom de la catégorie au centre
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Voir les produits",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Icône de navigation à droite
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCat(String path) {
    if (path.startsWith("http")) {
      // Image depuis Internet
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          path,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fastfood,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      // Image locale
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fastfood,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}

/// Carte de catégorie pour affichage en GRILLE (desktop/tablette)
class CategoryCard extends StatelessWidget {
  final String id;
  final String name;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;
  final Color backgroundColor;

  const CategoryCard({
    super.key,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
    this.isDeleting = false,
    this.backgroundColor = AppColors.chipPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageCat(imagePath),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCat(String path) {
    if (path.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          path,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 120, height: 120, color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fastfood, size: 40),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, width: 120, height: 120, fit: BoxFit.cover),
      );
    }
  }
}

/// Carte de catégorie compacte (CategoryCardTwo)
class CategoryCardTwo extends StatelessWidget {
  final String id;
  final String name;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;
  final Color backgroundColor;

  const CategoryCardTwo({
    super.key,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
    this.isDeleting = false,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageCat(imagePath),
                const SizedBox(height: 18),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCat(String path) {
    if (path.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          path,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 60, height: 60, color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fastfood, size: 40),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, width: 60, height: 60, fit: BoxFit.cover),
      );
    }
  }
}