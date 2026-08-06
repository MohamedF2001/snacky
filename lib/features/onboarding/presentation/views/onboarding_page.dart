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
