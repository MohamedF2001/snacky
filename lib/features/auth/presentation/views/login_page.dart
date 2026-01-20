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
