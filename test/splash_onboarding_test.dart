import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/splash/presentation/views/splash_page.dart';
import 'package:snacky/features/onboarding/presentation/views/onboarding_page.dart';

void main() {
  testWidgets('SplashPage shows logo and text', (WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashPage()),
        GoRoute(path: '/onboarding', builder: (context, state) => const Text('Onboarding')),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Snacky Admin'), findsOneWidget);

    // Allow the timer to complete
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('OnboardingPage shows pages and buttons', (WidgetTester tester) async {
     final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
        GoRoute(path: '/login', builder: (context, state) => const Text('Login')),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Gestion des Commandes'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);

    // Tap next
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Gestion du Menu'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Analyses et Stats'), findsOneWidget);

    await tester.tap(find.text('Démarrer'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });
}
