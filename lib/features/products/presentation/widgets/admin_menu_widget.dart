/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

class AdminMenuWidget extends ConsumerWidget {
  final ValueNotifier<int> selectedIndex;

  const AdminMenuWidget({super.key, required this.selectedIndex});

  /// Mappe une route vers l'index du menu principal
  int _getMenuIndexFromRoute(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/admin')) return 1;
    if (location.startsWith('/categories')) return 2;
    if (location.startsWith('/products')) return 3;
    if (location.startsWith('/orders')) return 4;
    if (location.startsWith('/promotions')) return 5;
    if (location.startsWith('/settings')) return 6;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    //final location = GoRouter.of(context).location;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getMenuIndexFromRoute(location);

    final items = [
      {"icon": Icons.home, "label": "Home", "route": "/home"},
      {"icon": Icons.dashboard, "label": "Dashboard", "route": "/admin"},
      {"icon": Icons.category, "label": "Categories", "route": "/categories"},
      {"icon": Icons.inventory_2, "label": "Produits", "route": "/products"},
      {"icon": Icons.card_giftcard, "label": "Commandes", "route": "/orders"},
      {"icon": Icons.pix_rounded, 'label': "Promotions", "route": "/promotions"},
      {"icon": Icons.settings, "label": "Paramètres", "route": "/settings"},
    ];

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 220,
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Column(
        children: [
          // --- Header utilisateur ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 30, color: isDark ? Colors.white : AppColors.neutralBlack),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.user?.email ?? 'Admin',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  authState.user?.role ?? 'Administrateur',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // --- Menu principal ---
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final active = currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    selectedIndex.value = index;
                    GoRouter.of(context).go(items[index]["route"] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.accentOrange : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[index]["icon"] as IconData,
                          color: active
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          items[index]["label"] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // --- Déconnexion ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: GestureDetector(
              onTap: () async {
                try {
                  await authNotifier.logout();
                  GoRouter.of(context).go('/login');
                } catch (e) {
                  print('❌ Error during logout: $e');
                  GoRouter.of(context).go('/login');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryRed),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.primaryRed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color:AppColors.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

class AdminMenuWidget extends ConsumerWidget {
  final ValueNotifier<int> selectedIndex;
  final bool isMobile;

  const AdminMenuWidget({
    super.key,
    required this.selectedIndex,
    this.isMobile = false,
  });

  /// Mappe une route vers l'index du menu principal
  int _getMenuIndexFromRoute(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/admin')) return 1;
    if (location.startsWith('/categories')) return 2;
    if (location.startsWith('/products')) return 3;
    if (location.startsWith('/orders')) return 4;
    if (location.startsWith('/promotions')) return 5;
    if (location.startsWith('/settings')) return 6;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getMenuIndexFromRoute(location);

    final items = [
      {"icon": Icons.home, "label": "Home", "route": "/home"},
      {"icon": Icons.dashboard, "label": "Dashboard", "route": "/admin"},
      {"icon": Icons.category, "label": "Categories", "route": "/categories"},
      {"icon": Icons.inventory_2, "label": "Produits", "route": "/products"},
      {"icon": Icons.card_giftcard, "label": "Commandes", "route": "/orders"},
      {"icon": Icons.pix_rounded, 'label': "Promotions", "route": "/promotions"},
      {"icon": Icons.settings, "label": "Paramètres", "route": "/settings"},
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 220,
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Column(
        children: [
          // --- Header utilisateur ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.12))),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 30, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.user?.email ?? 'Admin',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  authState.user?.role ?? 'Administrateur',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // --- Menu principal ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final active = currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    selectedIndex.value = index;
                    GoRouter.of(context).go(items[index]["route"] as String);

                    // Ferme le drawer si on est en mode mobile
                    if (isMobile) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: active ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: active
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[index]["icon"] as IconData,
                          color: active
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          items[index]["label"] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Déconnexion ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: GestureDetector(
              onTap: () async {
                try {
                  await authNotifier.logout();

                  // Ferme le drawer si on est en mode mobile avant de rediriger
                  if (isMobile && context.mounted) {
                    Navigator.of(context).pop();
                  }

                  if (context.mounted) {
                    GoRouter.of(context).go('/login');
                  }
                } catch (e) {
                  print('❌ Error during logout: $e');
                  if (context.mounted) {
                    GoRouter.of(context).go('/login');
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryRed),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.primaryRed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

