/* /* // features/product/presentation/views/admin_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await authNotifier.logout();
                // La navigation est gérée par le listener dans app.dart
              } catch (e) {
                print('❌ Error during logout: $e');
                // Fallback: naviguer vers login en cas d'erreur
                GoRouter.of(context).go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue, ${authState.user?.email ?? 'Admin'}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/products');
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text('Gérer les produits'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/products/create');
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text('Ajouter un produit'),
            ),
          ],
        ),
      ),
    );
  }
}
 */

// features/product/presentation/views/admin_home_page.dart

import 'package:flutter/material.dart';
import 'package:snacky/features/categories/presentation/views/categorie_list_page.dart';
import 'package:snacky/features/products/presentation/views/product_create_page.dart';
import 'package:snacky/features/products/presentation/views/all_product_page.dart';
import 'package:snacky/features/products/presentation/widgets/admin_menu_widget.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu latéral (à gauche)
          AdminMenuWidget(selectedIndex: _selectedIndex),
          // Espace principal (contenu)
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _selectedIndex,
              builder: (context, index, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    final slide =
                        Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        );
                    return SlideTransition(
                      position: slide,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _buildAdminPage(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPage(int index) {
    switch (index) {
      case 0: // Dashboard
        return _buildDashboardPage();
      case 1:
        return CategorieListPage();
      case 2: // Produits
        return const AllProductsPage();
      case 3: // Ajouter produit
        return const ProductCreatePage();
      case 4: // Paramètres
        return _buildSettingsPage();
      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildDashboardPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Tableau de Bord',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Bienvenue dans l\'administration Snacky Admin ',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Paramètres',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Configurez vos préférences',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
 */

// features/product/presentation/views/admin_home_page.dart

import 'package:flutter/material.dart';
import 'package:snacky/features/products/presentation/widgets/admin_menu_widget.dart';

class AdminHomePage extends StatefulWidget {
  final Widget child; // ✅ le contenu qui change (route)

  const AdminHomePage({super.key, required this.child});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu latéral
          AdminMenuWidget(selectedIndex: _selectedIndex),
          // Contenu dynamique (route actuelle)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final slide =
                    Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    );
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: widget.child, // ✅ fourni par GoRouter ShellRoute
            ),
          ),
        ],
      ),
    );
  }
}
