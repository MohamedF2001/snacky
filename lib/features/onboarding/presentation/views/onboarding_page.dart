/*
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Créez un menu que vos clients vont adorer',
      description:
          'Ajoutez des plats et gérez vos prix en quelques clics. Une interface intuitive pour un contrôle total.',
      image: 'assets/images/menu.png',
      buttonText: 'Continuer',
      isCentered: true,
    ),
    OnboardingItem(
      title: 'Gérez chaque commande avec confiance',
      description:
          'Suivez vos commandes en temps réel et optimisez votre cuisine.',
      image: 'assets/images/commande.png',
      buttonText: 'Continuer',
      isGlass: true,
    ),
    OnboardingItem(
      title: 'Boostez votre activité grâce aux données.',
      description:
          'Suivez vos performances, identifiez les tendances et prenez les meilleures décisions pour développer votre restaurant avec précision.',
      image: 'assets/images/analytinc.png',
      tag: 'SNACKY INSIGHTS',
      buttonText: "C'est parti !",
      highlightedWord: 'données.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    if (isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Stack(
        children: [
          // Background text for screen 2
          if (_currentPage == 1)
            Positioned(
              top: 100,
              left: 30,
              child: Opacity(
                opacity: 0.05,
                child: const Text(
                  'Snacky',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingContent(
                item: _items[index],
                onNext: () {
                  if (_currentPage == _items.length - 1) {
                    _finishOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutQuart,
                    );
                  }
                },
              );
            },
          ),

          // Top Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'PASSER',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 25,
            right: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _items.length,
                    (index) => _buildDot(index),
                  ),
                ),

                // Main Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _items.length - 1) {
                      _finishOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutQuart,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _items[_currentPage].buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF7A00) : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final String buttonText;
  final String? tag;
  final String? highlightedWord;
  final bool isGlass;
  final bool isCentered;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    this.tag,
    this.highlightedWord,
    this.isGlass = false,
    this.isCentered = false,
  });
}

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;
  final VoidCallback onNext;

  const OnboardingContent({super.key, required this.item, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Column(
          children: [
            // Illustration Area
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
                child: Center(
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white10,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.white30, size: 50),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment:
                      item.isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    if (item.tag != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.analytics_outlined,
                                size: 16, color: Color(0xFFFF7A00)),
                            const SizedBox(width: 8),
                            Text(
                              item.tag!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildTitle(),
                    const SizedBox(height: 20),
                    Text(
                      item.description,
                      textAlign: item.isCentered ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Glassmorphism overlay for screen 2
        if (item.isGlass)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: size.width * 0.85,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC2410C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 20,
                              shadowColor: const Color(0xFFC2410C).withOpacity(0.5),
                            ),
                            child: const Text(
                              'Démarrer',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    if (item.highlightedWord == null) {
      return Text(
        item.title,
        textAlign: item.isCentered ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      );
    }

    final parts = item.title.split(item.highlightedWord!);
    return RichText(
      textAlign: item.isCentered ? TextAlign.center : TextAlign.start,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          height: 1.1,
          fontFamily: 'Poppins',
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: item.highlightedWord,
            style: const TextStyle(color: Color(0xFFFF7A00)),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
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

/// Type de contenu à illustrer pour chaque slide.
enum _SlideType { orders, menu, analytics }

class _OnboardingSlide {
  final _SlideType type;
  final IconData icon;
  final Color accent;
  final String shortLabel;
  final String title;
  final String description;
  final List<String> features;

  const _OnboardingSlide({
    required this.type,
    required this.icon,
    required this.accent,
    required this.shortLabel,
    required this.title,
    required this.description,
    required this.features,
  });
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      type: _SlideType.orders,
      icon: Icons.receipt_long_rounded,
      accent: AppColors.primaryOrange,
      shortLabel: 'Commande #1042',
      title: 'Gestion des Commandes',
      description:
      "Suivez chaque commande en temps réel, de la prise en charge à la livraison, et ne ratez plus jamais une vente.",
      features: ['Statut en direct', 'Livraison & sur place', 'Reçus imprimables'],
    ),
    _OnboardingSlide(
      type: _SlideType.menu,
      icon: Icons.restaurant_menu_rounded,
      accent: AppColors.secondaryBlue,
      shortLabel: 'Tous les produits',
      title: 'Gestion du Menu',
      description:
      "Ajoutez vos plats, organisez-les par catégories et ajustez vos prix en quelques clics pour un menu toujours à jour.",
      features: ['Catégories illimitées', 'Photos & prix', 'Mise à jour instantanée'],
    ),
    _OnboardingSlide(
      type: _SlideType.analytics,
      icon: Icons.insights_rounded,
      accent: AppColors.success,
      shortLabel: 'Statistiques',
      title: 'Analyses et Stats',
      description:
      "Visualisez vos ventes, repérez vos plats les plus populaires et prenez les meilleures décisions pour développer votre restaurant.",
      features: ['Ventes en temps réel', 'Top des ventes', 'Rapports clairs'],
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    if (isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _slides[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildAnimatedSlide(index),
              ),
            ),
            const SizedBox(height: 8),
            _buildBottomControls(current),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_rounded,
                  color: Colors.white.withOpacity(0.5), size: 18),
              const SizedBox(width: 8),
              Text(
                'SNACKY ADMIN',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isLastPage ? 0 : 1,
            child: TextButton(
              onPressed: _isLastPage ? null : _finishOnboarding,
              child: Text(
                'PASSER',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSlide(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double distance = (index - _currentPage).toDouble();
        if (_pageController.hasClients && _pageController.position.haveDimensions) {
          final page = _pageController.page ?? _currentPage.toDouble();
          distance = (index - page).toDouble();
        }
        distance = distance.abs();
        if (distance > 1) distance = 1;
        final double scale = 1.0 - (distance * 0.08);
        final double opacity = (1.0 - (distance * 0.6)).clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: _SlideView(slide: _slides[index]),
    );
  }

  Widget _buildBottomControls(_OnboardingSlide current) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: List.generate(_slides.length, _buildDot)),
          ElevatedButton(
            onPressed: () => _isLastPage ? _finishOnboarding() : _goToNextPage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: current.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLastPage ? 'Démarrer' : 'Suivant',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final active = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? _slides[_currentPage].accent : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Contenu d'une slide : illustration + titre + description + points clés.
class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            flex: 5,
            child: Center(child: _MockScreenIllustration(slide: slide)),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: slide.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(slide.icon, size: 14, color: slide.accent),
                      const SizedBox(width: 6),
                      Text(
                        slide.shortLabel.toUpperCase(),
                        style: TextStyle(
                          color: slide.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  slide.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slide.features
                      .map((f) => _FeatureChip(label: f, color: slide.accent))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final Color color;

  const _FeatureChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini "capture d'écran" stylisée de la fonctionnalité mise en avant.
/// Volontairement dessinée avec des widgets (et non une vraie capture
/// d'écran) pour rester nette, cohérente avec la charte de l'app et
/// légère (aucun asset image supplémentaire requis).
class _MockScreenIllustration extends StatelessWidget {
  final _OnboardingSlide slide;

  const _MockScreenIllustration({required this.slide});

  @override
  Widget build(BuildContext context) {
    // On borne la taille de la carte par l'espace RÉELLEMENT disponible
    // (largeur ET hauteur), pas seulement par la largeur de l'écran :
    // ça évite tout overflow sur les écrans larges/courts (tablette,
    // desktop, paysage...).
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : screenWidth;
        final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : maxW;
        final width = maxW * 0.74 < maxH * 0.95 ? maxW * 0.74 : maxH * 0.95;
        return _buildCard(width);
      },
    );
  }

  Widget _buildCard(double width) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [slide.accent.withOpacity(0.22), Colors.transparent],
            ),
          ),
        ),
        Container(
          width: width,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: slide.accent.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: slide.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(slide.icon, color: slide.accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slide.shortLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.more_horiz_rounded,
                      color: Colors.white.withOpacity(0.25), size: 18),
                ],
              ),
              const SizedBox(height: 18),
              _buildContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (slide.type) {
      case _SlideType.orders:
        return _OrdersPreview(accent: slide.accent);
      case _SlideType.menu:
        return _MenuPreview(accent: slide.accent);
      case _SlideType.analytics:
        return _AnalyticsPreview(accent: slide.accent);
    }
  }
}

class _OrdersPreview extends StatelessWidget {
  final Color accent;

  const _OrdersPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Tacos Poulet Fromage', 'x2', '6 000 F', AppColors.statusPreparing, 'En cours'),
        const SizedBox(height: 12),
        _row('Double Beef Burger', 'x1', '3 500 F', AppColors.statusCompleted, 'Terminé'),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.white.withOpacity(0.08)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              '9 500 F',
              style: TextStyle(color: accent, fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String name, String qty, String price, Color statusColor, String status) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$qty · $status',
                style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _MenuPreview extends StatelessWidget {
  final Color accent;

  const _MenuPreview({required this.accent});

  // Vraies illustrations du dossier assets/images/categories/ déjà
  // déclarées dans pubspec.yaml — pas de nouvel asset à ajouter.
  static const List<(String, String, String)> _items = [
    ('assets/images/categories/hamburger.png', 'Burger', '3 500 F'),
    ('assets/images/categories/pizza.png', 'Pizza', '4 000 F'),
    ('assets/images/categories/tacos.png', 'Tacos', '3 000 F'),
    ('assets/images/categories/boisson.png', 'Boissons', '800 F'),
  ];

  @override
  Widget build(BuildContext context) {
    // Grille en hauteur FIXE (2x2) plutôt qu'un GridView + aspectRatio :
    // la hauteur ne dépend plus de la largeur de la carte, donc plus
    // aucun risque d'overflow sur les écrans larges/courts.
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCell(_items[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildCell(_items[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildCell(_items[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildCell(_items[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildCell((String, String, String) item) {
    final (imagePath, name, price) = item;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.fastfood_rounded, color: accent, size: 16);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  price,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsPreview extends StatelessWidget {
  final Color accent;

  const _AnalyticsPreview({required this.accent});

  static const List<double> _heights = [0.35, 0.55, 0.4, 0.7, 0.5, 0.9, 0.65];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ventes de la semaine',
              style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up_rounded, color: AppColors.success, size: 12),
                  SizedBox(width: 3),
                  Text(
                    '+24%',
                    style: TextStyle(color: AppColors.success, fontSize: 10.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _heights.map((h) {
              final isLast = h == _heights.last;
              return Container(
                width: 14,
                height: 90 * h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isLast ? accent : accent.withOpacity(0.35),
                      isLast ? accent.withOpacity(0.6) : accent.withOpacity(0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

