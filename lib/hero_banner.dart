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



class HeroBannerMobile extends StatefulWidget {
  const HeroBannerMobile({super.key});

  @override
  State<HeroBannerMobile> createState() => _HeroBannerMobileState();
}

class _HeroBannerMobileState extends State<HeroBannerMobile>
    with SingleTickerProviderStateMixin {
  String _displayedText = "";
  final String _fullText = "Gérez votre fast-food facilement 🍔";
  int _currentIndex = 0;
  Timer? _timer;

  late AnimationController _imageController;
  late Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();

    // Animation pour l'image
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _imageAnimation = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeOutBack,
    );

    _imageController.forward();

    // Animation typewriter
    Future.delayed(const Duration(milliseconds: 200), _startTypewriterAnimation);
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
    // Tailles adaptées au mobile
    final double containerHeight = 200;
    final double titleFontSize = 20;
    final double subtitleFontSize = 12;
    final double badgeFontSize = 10;
    final double imageScale = 0.6;
    final double horizontalPadding = 16;

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Container(
        height: containerHeight,
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(top: -40, right: -40, child: _buildCircle(150)),
            Positioned(bottom: -20, left: -20, child: _buildCircle(100)),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                "Gestion simplifiée",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: badgeFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Texte typewriter
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _displayedText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              if (_currentIndex < _fullText.length)
                                TextSpan(
                                  text: "|",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Sous-titre
                        Text(
                          "Commandes • Produits • Statistiques",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bouton CTA
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Commencer",
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Image réduite
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0, end: imageScale)
                          .animate(_imageAnimation),
                      child: Image.asset(
                        'assets/images/fast.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              size: 80,
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

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
    );
  }
}




class HeroBannerMobilee extends StatefulWidget {
  const HeroBannerMobilee({super.key});

  @override
  State<HeroBannerMobilee> createState() => _HeroBannerMobileeState();
}

class _HeroBannerMobileeState extends State<HeroBannerMobilee>
    with SingleTickerProviderStateMixin {
  String _displayedText = "";
  final String _fullText = "Gérez votre fast-food facilement 🍔";
  int _currentIndex = 0;
  Timer? _timer;

  late AnimationController _imageController;
  late Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _imageAnimation = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeOutBack,
    );

    _imageController.forward();

    Future.delayed(const Duration(milliseconds: 200), _startTypewriterAnimation);
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
    final double containerHeight = 200;
    final double titleFontSize = 20;
    final double subtitleFontSize = 12;
    final double badgeFontSize = 10;
    final double imageWidth = 120.0;
    final double horizontalPadding = 16;

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Container(
        height: containerHeight,
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(top: -40, right: -40, child: _buildCircle(150)),
            Positioned(bottom: -20, left: -20, child: _buildCircle(100)),

            // Image positionnée à gauche et débordant
            Positioned(
              right: -30,
              bottom: 0,
              top: 0,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0, end: 0.6).animate(_imageAnimation),
                child: Image.asset(
                  'assets/images/fast.png',
                  fit: BoxFit.cover,
                  width: imageWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: imageWidth,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.fastfood,
                        size: 80,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Contenu texte
            Padding(
              //padding: EdgeInsets.only(
              //    left: imageWidth * 0.6 + 16, right: 12, top: 16, bottom: 16),
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "Gestion simplifiée",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: badgeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Texte typewriter
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _displayedText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        if (_currentIndex < _fullText.length)
                          TextSpan(
                            text: "|",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sous-titre
                  Text(
                    "Commandes • Produits • Statistiques",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bouton CTA
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade700,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Commencer",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
    );
  }
}
