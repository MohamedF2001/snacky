import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      final authState = ref.read(authProvider);
      
      // Si l'initialisation n'est pas finie, on attend un peu plus ou on écoute le changement
      if (authState.isInitializing) {
        // On vérifie à nouveau dans 500ms
        _navigateToNextDelayed();
      } else {
        if (authState.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  void _navigateToNextDelayed() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final authState = ref.read(authProvider);
      if (authState.isInitializing) {
        _navigateToNextDelayed();
      } else {
        if (authState.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Netflix-style black
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle gradient for depth
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  const Color(0xFFE50914).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _animation.drive(Tween(begin: 0.85, end: 1.0)),
              child: FadeTransition(
                opacity: _animation.drive(Tween(begin: 0.5, end: 1.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 180,
                      height: 180,
                    ),
                    const SizedBox(height: 32),
                    // Netflix-like red bar under logo (optional but fits theme)
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE50914).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SNACKY',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom loading indicator
          Positioned(
            bottom: 60,
            child: SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                minHeight: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
