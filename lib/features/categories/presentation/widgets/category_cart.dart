
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
    this.backgroundColor = const Color(0xFFFFE0B2), // Colors.orange[100]
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
                icon: /*isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    :*/ const Icon(Icons.delete, color: Colors.red),
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
    this.backgroundColor = AppColors.accentOrange
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
            /*Positioned(
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
            ),*/
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
}
