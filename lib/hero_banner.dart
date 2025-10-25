import 'package:flutter/material.dart';
import 'dart:async';

class HeroBannerWithTypewriter extends StatefulWidget {
  const HeroBannerWithTypewriter({super.key});

  @override
  State<HeroBannerWithTypewriter> createState() => _HeroBannerWithTypewriterState();
}

class _HeroBannerWithTypewriterState extends State<HeroBannerWithTypewriter>
    with SingleTickerProviderStateMixin {
  String _displayedText = "";
  final String _fullText = "Gérez votre fast-food en toute simplicité 🍔";
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _imageController;
  late Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();

    // Animation pour l'image
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _imageAnimation = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeOutBack,
    );

    _imageController.forward();

    // Démarrer l'animation typewriter après un court délai
    Future.delayed(const Duration(milliseconds: 300), () {
      _startTypewriterAnimation();
    });
  }

  void _startTypewriterAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade600,
              Colors.deepOrange.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        width: double.infinity,
        height: 320,
        child: Stack(
          children: [
            // Cercles décoratifs en arrière-plan
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Contenu principal
            Row(
              children: [
                // 🧠 Texte d'accroche avec animation typewriter
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge "Nouveau"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Gestion simplifiée",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Texte principal avec effet typewriter
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _displayedText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              // Curseur clignotant
                              if (_currentIndex < _fullText.length)
                                TextSpan(
                                  text: "|",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sous-titre
                        Text(
                          "Commandes • Produits • Statistiques",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Bouton CTA
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black26,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Commencer maintenant",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🖼️ Illustration avec animation
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: ScaleTransition(
                      scale: _imageAnimation,
                      child: Image.asset(
                        'assets/images/fast.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              size: 120,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}