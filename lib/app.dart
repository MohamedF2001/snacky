import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';
import 'package:snacky/features/auth/presentation/views/login_page.dart';
import 'package:snacky/features/categories/presentation/views/categorie_list_page.dart';
import 'package:snacky/features/categories/presentation/views/category_create_page.dart';
import 'package:snacky/features/orders/presentation/views/order_list_page.dart';
import 'package:snacky/features/products/presentation/views/admin_home_page.dart';
import 'package:snacky/features/products/presentation/views/details_product_page.dart';
import 'package:snacky/features/products/presentation/views/product_by_categorie_page.dart';
import 'package:snacky/features/products/presentation/views/product_create_page.dart';
import 'package:snacky/features/products/presentation/views/all_product_page.dart';
import 'package:snacky/features/products/presentation/views/product_edit_page.dart';
import 'package:snacky/features/promotions/presentation/views/all_promotion.dart';

import 'features/orders/presentation/views/order_create_page.dart';
import 'features/orders/presentation/views/order_detail_page.dart';
import 'features/orders/presentation/views/order_edit_page.dart';
import 'features/orders/presentation/views/order_list_page_with_filters.dart';
import 'features/promotions/presentation/views/create_promotion_page.dart';
import 'features/promotions/presentation/views/promotion_detail_page.dart';

/* final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/', name: 'home', redirect: (context, state) => '/login'),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const AllProductsPage(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategorieListPage(),
      ),
      GoRoute(
        path: '/products/create',
        name: 'createProduct',
        builder: (context, state) => const ProductCreatePage(),
      ),
      GoRoute(
        path: '/categories/:id/products',
        builder: (context, state) {
          final categorieId = state.pathParameters['id']!;
          final categorieNom = state.extra as String? ?? "Catégorie";

          return ProductsByCategoryPage(
            categorieId: categorieId,
            categorieNom: categorieNom,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final currentLocation = state.matchedLocation; // Utiliser matchedLocation
      final isLoggingIn = currentLocation == '/login';
      final isAtRoot = currentLocation == '/';

      // Si l'utilisateur n'est pas connecté et essaie d'accéder à une page protégée
      if (!isLoggedIn && !isLoggingIn && !isAtRoot) {
        return '/login';
      }

      // Si l'utilisateur est connecté et essaie d'accéder à login
      if (isLoggedIn && isLoggingIn) {
        return '/admin';
      }

      // Si à la racine, rediriger selon l'état de connexion
      if (isAtRoot) {
        return isLoggedIn ? '/admin' : '/login';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page non trouvée: ${state.matchedLocation}')),
    ),
  );
});

 */

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // 🔑 Ici le ShellRoute garde le menu/structure fixe
      ShellRoute(
        builder: (context, state, child) {
          return AdminHomePage(child: child);
          // AdminHomePage contient ton Scaffold + Menu
        },
        routes: [
          GoRoute(
            path: '/admin',
            name: 'dashboard',
            builder: (context, state) => Center(
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
            ),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategorieListPage(),
          ),
          GoRoute(
            path: '/categories/create',
            name: 'createCategory',
            builder: (context, state) => const CategoryCreatePage(),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => const AllProductsPage(),
          ),
          GoRoute(
            path: '/products/create',
            name: 'createProduct',
            builder: (context, state) => const ProductCreatePage(),
          ),
          GoRoute(
            path: '/products/edit/:id',
            name: 'editProduct',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductEditPage(productId: productId);
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => Center(
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
            ),
          ),
          GoRoute(
            path: '/categories/:id/products',
            builder: (context, state) {
              final categorieId = state.pathParameters['id']!;
              final categorieNom = state.extra as String? ?? "Catégorie";
              return ProductsByCategoryPage(
                categorieId: categorieId,
                categorieNom: categorieNom,
              );
            },
          ),
          GoRoute(
            path: '/products/:id',
            builder: (context, state) {
              final produitId = state.pathParameters['id']!;
              final productNom = state.extra as String? ?? "Produits";
              return DetailsProductPage(
                  produitId: produitId,
                  productNom: productNom,
              );
            },
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrderListPageWithFilters(),
          ),
          GoRoute(
              path: '/promotions',
            name: 'promotions',
            builder: (context, state) => const AllPromotionPage()
          ),
          GoRoute(
            path: '/promotions/create',
            builder: (context, state) => const CreatePromotionPage(),
          ),
          GoRoute(
              path: '/promotions/:id',
            builder: (context, state) {
              final promotionId = state.pathParameters['id']!;
              return PromotionDetailPage(promotionId: promotionId);
            },
          ),
          // Détails d'une commande
          GoRoute(
            path: '/orders/detail/:id',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return OrderDetailPageEnhanced(orderId: orderId);
            },
          ),
          // Modification d'une commande
          GoRoute(
            path: '/orders/edit/:id',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return OrderEditPage(orderId: orderId);
            },
          ),
          // Création d'une commande (si pas déjà fait)
          GoRoute(
            path: '/orders/create',
            builder: (context, state) => const OrderCreatePage(),
          ),
        ],
      ),
    ],

    // 🔒 Auth guard
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/admin';
      return null;
    },
  );
});

class FastFoodApp extends ConsumerWidget {
  const FastFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final router = ref.watch(routerProvider);

    // Écouter les changements d'état d'authentification
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        print('🔄 User logged out, navigating to login');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/login');
        });
      }
    });

    if (authState.isInitializing) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Initialisation...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'FastFood App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
