/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

import '../../../../const/app_colors.dart';
import '../../../../const/app_input_style.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final double _scale = 0.9;
  //double _opacity = 0;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Redirection après connexion réussie
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Utiliser goRouter pour la navigation
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/home');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: const Text('Connexion')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orangeAccent, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Connexion Admin",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: AppInputStyles.textFieldDecoration(
                            label: "Adresse mail",
                            icon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: AppInputStyles.textFieldDecoration(
                              label: "Mot de passe",
                            icon:  Icons.lock_outline,
                            suffixIcon:  IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ) ,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (authState.isLoading)
                          const Center(child: CircularProgressIndicator(color: Colors.orange))
                        else
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                authNotifier.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              }
                            },
                            child: const Text('Se connecter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        if (authState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _getErrorMessage(authState.error!),
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
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
      ),
    );
  }

  // Ajoutez cette méthode pour mieux formater les erreurs
  String _getErrorMessage(Failure failure) {
    return failure.when(
      serverError: (message) =>
          'Erreur serveur: ${message ?? "Veuillez réessayer"}',
      networkError: () => 'Erreur de réseau. Vérifiez votre connexion.',
      unauthorized: () => 'Email ou mot de passe incorrect',
      notFound: () => 'Ressource non trouvée',
      validationError: (errors) =>
          'Erreur de validation: ${errors.values.join(", ")}',
      unexpectedError: () => 'Erreur inattendue. Veuillez réessayer.',
    );
  }
}
*/

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/core/error/failures.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';

import '../../../../const/app_colors.dart';
import '../../../../const/app_input_style.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final size = MediaQuery.of(context).size;

    // Redirection après connexion réussie
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: GestureDetector(
        onTap: () => _focusNode.unfocus(),
        child: Stack(
          children: [
            // 🎨 Background décoratif avec motifs food
            _buildDecorativeBackground(),

            // 🍟 Logo flottant animé en arrière-plan
            _buildFloatingFoodIcons(),

            // 📱 Contenu principal
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildLoginCard(context, size, authState, authNotifier),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Background avec dégradé et motifs subtils
  Widget _buildDecorativeBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration:
      BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [Colors.grey.shade900, Colors.black, Colors.grey.shade800]
            : [Colors.orange.shade400, Colors.orangeAccent, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: FoodPatternPainter(isDark: isDark),
        child: Container(),
      ),
    );
  }

  // 🍔 Icônes food flottantes pour l'ambiance
  Widget _buildFloatingFoodIcons() {
    return IgnorePointer(
      child: Stack(
        children: [
          _buildFloatingIcon(Icons.fastfood, 0.1, 0.2, 2000),
          _buildFloatingIcon(Icons.local_pizza, 0.85, 0.15, 2500),
          _buildFloatingIcon(Icons.icecream, 0.15, 0.75, 2200),
          _buildFloatingIcon(Icons.local_drink, 0.8, 0.8, 1800),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, double x, double y, int duration) {
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: duration),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, sin(value * 6.28) * 15),
            child: child,
          );
        },
        child: Icon(
          icon,
          size: 32,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }

  // 🪪 Carte de connexion principale
  Widget _buildLoginCard(
      BuildContext context,
      Size size,
      dynamic authState,
      dynamic authNotifier,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxWidth: 420),
      margin: EdgeInsets.symmetric(horizontal: size.width > 600 ? 24 : 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🍔 Logo + Titre
              _buildHeader(),

              const SizedBox(height: 24),

              // 📧 Champ Email
              _buildEmailField(),

              const SizedBox(height: 16),

              // 🔐 Champ Mot de passe
              _buildPasswordField(),

              // ✅ Remember me + Forgot password
              _buildExtraOptions(),

              const SizedBox(height: 24),

              // 🔘 Bouton de connexion
              _buildLoginButton(authState, authNotifier),

              // ❌ Message d'erreur
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(authState.error!),
              ],

              const SizedBox(height: 20),

              // 👥 Footer avec infos
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // 🍔 Header avec logo et titre
  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Logo animé
        Container(
          padding: const EdgeInsets.all(16),
          decoration:BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orangeAccent, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Titre principal
        Text(
          "Snacky Admin",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Sous-titre
        Text(
          "Gérez votre fastfood en toute simplicité",
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 📧 Champ Email stylisé
  Widget _buildEmailField() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: _emailController,
      focusNode: _focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      decoration: AppInputStyles.textFieldDecoration(
        label: "Adresse email",
        //hint: "admin@snacky.com",
        icon: Icons.email_outlined,
      ).copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  // 🔐 Champ Mot de passe avec toggle visibility
  Widget _buildPasswordField() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _focusNode.unfocus(),
      style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      decoration: AppInputStyles.textFieldDecoration(
        label: "Mot de passe",
        //hint: "••••••••",
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          splashRadius: 20,
        ),
      ).copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        }
        if (value.length < 6) {
          return 'Minimum 6 caractères requis';
        }
        return null;
      },
    );
  }

  // ✅ Options supplémentaires
  Widget _buildExtraOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Remember me
        /*Row(
          children: [
            Theme(
              data: ThemeData(unselectedWidgetColor: Colors.grey),
              child: Checkbox(
                value: _rememberMe,
                activeColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Se souvenir",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),*/

        // Forgot password
        TextButton(
          onPressed: () {
            // TODO: Navigation vers forgot password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Fonctionnalité à venir 🚧"),
                backgroundColor: AppColors.accentOrange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text(
            "Mot de passe oublié ?",
            style: TextStyle(
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // 🔘 Bouton de connexion animé
  Widget _buildLoginButton(dynamic authState, dynamic authNotifier) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: authState.isLoading
          ? _buildLoadingButton()
          : ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          shadowColor: AppColors.accentOrange.withOpacity(0.4),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Se connecter",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // ⏳ Bouton avec loader
  Widget _buildLoadingButton() {
    return Container(
      decoration:
      BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orangeAccent, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  // ❌ Message d'erreur stylisé
  Widget _buildErrorMessage(Failure failure) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getErrorMessage(failure),
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 👥 Footer avec branding
  Widget _buildFooter() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: colorScheme.onSurface.withOpacity(0.1)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_rounded, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(
              "Connexion sécurisée • v1.0",
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "© 2026 Snacky. Tous droits réservés.",
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  // 🎯 Gestion de la connexion
  void _handleLogin() {
    final authNotifier = ref.read(authProvider.notifier);
    if (_formKey.currentState!.validate()) {
      _focusNode.unfocus();
      authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  // 📝 Formatage des messages d'erreur
  String _getErrorMessage(Failure failure) {
    return failure.when(
      serverError: (message) => '🔧 ${message ?? "Erreur serveur"}',
      networkError: () => '📡 Vérifiez votre connexion internet',
      unauthorized: () => '🔑 Email ou mot de passe incorrect',
      notFound: () => '❌ Compte introuvable',
      validationError: (errors) => '⚠️ ${errors.values.join(", ")}',
      unexpectedError: () => '😕 Une erreur est survenue',
    );
  }
}

// 🎨 Custom Painter pour motifs food en background
class FoodPatternPainter extends CustomPainter {
  final bool isDark;
  FoodPatternPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.white).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Grille de points subtils
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }

    // Lignes diagonales décoratives
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(-50, size.height * 0.3),
      Offset(size.width + 50, size.height * 0.7),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
