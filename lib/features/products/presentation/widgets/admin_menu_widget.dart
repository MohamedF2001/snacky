/* // features/product/presentation/widgets/admin_menu_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

class AdminMenuWidget extends ConsumerWidget {
  final ValueNotifier<int> selectedIndex;

  const AdminMenuWidget({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    final items = [
      {"icon": Icons.dashboard, "label": "Dashboard"},
      {"icon": Icons.category, "label": "Categories"},
      {"icon": Icons.inventory_2, "label": "Produits"},
      {"icon": Icons.add_box, "label": "Ajouter Produit"},
      {"icon": Icons.settings, "label": "Paramètres"},
    ];

    return Container(
      width: 220,
      decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
      child: Column(
        children: [
          // Header avec informations utilisateur
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.user?.email ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  authState.user?.role ?? 'Administrateur',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (index) {
                return ValueListenableBuilder<int>(
                  valueListenable: selectedIndex,
                  builder: (context, currentIndex, _) {
                    final active = currentIndex == index;

                    return GestureDetector(
                      onTap: () => selectedIndex.value = index,
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
                          color: active ? Colors.white : Colors.transparent,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              items[index]["icon"] as IconData,
                              color: active
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              items[index]["label"] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? const Color(0xFF1E3A8A)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          // Bouton de déconnexion
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
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.red,
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
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

class AdminMenuWidget extends ConsumerWidget {
  final ValueNotifier<int> selectedIndex;

  const AdminMenuWidget({super.key, required this.selectedIndex});

  /// Mappe une route vers l'index du menu principal
  int _getMenuIndexFromRoute(String location) {
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/admin')) return 0;
    if (location.startsWith('/orders')) return 3;
    if (location.startsWith('/promotions')) return 4;
    if (location.startsWith('/settings')) return 5;
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
      {"icon": Icons.dashboard, "label": "Dashboard", "route": "/admin"},
      {"icon": Icons.category, "label": "Categories", "route": "/categories"},
      {"icon": Icons.inventory_2, "label": "Produits", "route": "/products"},
      {"icon": Icons.card_giftcard, "label": "Commandes", "route": "/orders"},
      {"icon": Icons.pix_rounded, 'label': "Promotions", "route": "/promotions"},
      {"icon": Icons.settings, "label": "Paramètres", "route": "/settings"},
    ];

    return Container(
      width: 220,
      decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
      child: Column(
        children: [
          // --- Header utilisateur ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.user?.email ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  authState.user?.role ?? 'Administrateur',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
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
                      color: active ? Colors.white : Colors.transparent,
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
                              ? const Color(0xFF1E3A8A)
                              : Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          items[index]["label"] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? const Color(0xFF1E3A8A)
                                : Colors.white,
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
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.red,
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
