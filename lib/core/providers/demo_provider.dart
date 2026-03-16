// core/providers/demo_provider.dart
//
// Ce fichier REMPLACE "const bool demo = true" dans main.dart.
// Toutes les vues qui faisaient "import 'package:snacky/main.dart'"
// pour lire la variable `demo` doivent maintenant utiliser ce provider.
//
// Usage dans une vue :
//   final isDemo = ref.watch(demoProvider);
//   if (isDemo) { _showDemoDialog(); return; }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/features/settings/presentation/providers/settings_provider.dart';

/// Provider booléen simple : true = mode démo actif.
/// Dérive directement du settingsProvider pour rester synchronisé
/// avec SharedPreferences (persisté entre sessions).
final demoProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).settings.demoMode;
});