import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';
import 'package:snacky/features/auth/presentation/views/login_page.dart';
import 'package:snacky/features/categories/presentation/views/categorie_list_page.dart';
import 'package:snacky/features/categories/presentation/views/category_create_page.dart';
import 'package:snacky/features/dashboard/dashboard_page.dart';
import 'package:snacky/features/products/presentation/views/admin_home_page.dart';
import 'package:snacky/features/products/presentation/views/details_product_page.dart';
import 'package:snacky/features/products/presentation/views/product_by_categorie_page.dart';
import 'package:snacky/features/products/presentation/views/product_create_page.dart';
import 'package:snacky/features/products/presentation/views/all_product_page.dart';
import 'package:snacky/features/products/presentation/views/product_edit_page.dart';
import 'package:snacky/features/onboarding/presentation/views/onboarding_page.dart';
import 'package:snacky/features/promotions/presentation/views/all_promotion.dart';
import 'package:snacky/features/splash/presentation/views/splash_page.dart';

import 'features/orders/presentation/views/order_create_page.dart';
import 'features/orders/presentation/views/order_detail_page.dart';
import 'features/orders/presentation/views/order_edit_page.dart';
import 'features/orders/presentation/views/order_list_page_with_filters.dart';
import 'features/promotions/presentation/views/create_promotion_page.dart';
import 'features/promotions/presentation/views/promotion_detail_page.dart';
import 'const/app_theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/settings/presentation/views/settings_page.dart';
import 'home.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // On ne "watch" pas ici pour éviter de recréer le router à chaque changement d'auth
  // On utilise plutôt une redirection basée sur l'état actuel
  
  return GoRouter(
    initialLocation: '/splash',
    // Permet de rafraîchir le router quand l'état d'authentification change
    refreshListenable: _AuthListenable(ref),
    routes: [
      // Ajout d'une route racine par défaut pour éviter l'erreur de route initiale
      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // 🔑 Ici le ShellRoute garde le menu/structure fixe
      ShellRoute(
        builder: (context, state, child) {
          return AdminHomePage(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => Home(),
          ),
          GoRoute(
            path: '/admin',
            name: 'dashboard',
            builder: (context, state) => DashboardPage(),
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
            builder: (context, state) => const SettingsPage(),
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
            builder: (context, state) => const AllPromotionPage(),
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
          GoRoute(
            path: '/orders/detail/:id',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return OrderDetailPageEnhanced(orderId: orderId);
            },
          ),
          GoRoute(
            path: '/orders/edit/:id',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return OrderEditPage(orderId: orderId);
            },
          ),
          GoRoute(
            path: '/orders/create',
            builder: (context, state) => const OrderCreatePage(),
          ),
        ],
      ),
    ],

    // 🔒 Auth guard
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (isSplash || isOnboarding) return null;

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';

      return null;
    },
  );
});

// Classe utilitaire pour écouter le provider dans GoRouter
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

class FastFoodApp extends ConsumerWidget {
  const FastFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final router = ref.watch(routerProvider);
    final settingsState = ref.watch(settingsProvider);

    ThemeMode themeMode;
    switch (settingsState.settings.theme) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    // Écouter les changements d'état d'authentification
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        print('🔄 User logged out, navigating to login');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/login');
        });
      }
    });

    return MaterialApp.router(
      title: 'FastFood App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
