// features/settings/presentation/views/sections/demo_mode_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_widgets.dart';

class DemoModeSection extends ConsumerWidget {
  const DemoModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final isDemo = state.settings.demoMode;
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Mode démo',
          subtitle: 'Contrôlez l\'accès aux fonctions de modification',
        ),

        // Status card with big toggle
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDemo ? Colors.orange.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDemo ? Colors.orange.shade200 : Colors.green.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDemo ? Colors.orange.shade100 : Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDemo ? Icons.visibility_outlined : Icons.edit_outlined,
                  color: isDemo ? Colors.orange.shade700 : Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDemo ? 'Mode démo actif' : 'Mode normal actif',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDemo
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDemo
                          ? 'Créer, modifier et supprimer sont désactivés'
                          : 'Toutes les fonctions de modification sont actives',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDemo
                            ? Colors.orange.shade600
                            : Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDemo,
                onChanged: (v) => _confirmToggle(context, ref, v),
                activeColor: Colors.orange,
                activeTrackColor: Colors.orange.shade100,
                inactiveThumbColor: Colors.green,
                inactiveTrackColor: Colors.green.shade100,
              ),
            ],
          ),
        ),

        SettingsCard(
          title: 'Modules affectés',
          icon: Icons.security,
          children: [
            _BlockedModuleRow(
              icon: Icons.category_outlined,
              label: 'Catégories',
              isBlocked: isDemo,
            ),
            _BlockedModuleRow(
              icon: Icons.fastfood_outlined,
              label: 'Produits',
              isBlocked: isDemo,
            ),
            _BlockedModuleRow(
              icon: Icons.shopping_cart_outlined,
              label: 'Commandes',
              isBlocked: isDemo,
            ),
            _BlockedModuleRow(
              icon: Icons.local_offer_outlined,
              label: 'Promotions',
              isBlocked: isDemo,
            ),
          ],
        ),

        SettingsCard(
          title: 'À quoi sert ce mode ?',
          icon: Icons.info_outline,
          children: [
            SettingsRow(
              label: 'Présentation sans risque',
              subtitle:
              'Naviguez librement sans modifier les données de production',
              trailing: Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade400,
                size: 20,
              ),
            ),
            SettingsRow(
              label: 'Formation des équipes',
              subtitle: 'Montrez l\'interface aux nouveaux utilisateurs',
              trailing: Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade400,
                size: 20,
              ),
            ),
            SettingsRow(
              label: 'Démonstration client',
              subtitle: 'Présentez l\'app sans accès aux données réelles',
              trailing: Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade400,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmToggle(BuildContext context, WidgetRef ref, bool newValue) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(newValue ? 'Activer le mode démo' : 'Désactiver le mode démo'),
        content: Text(
          newValue
              ? 'Les actions de création, modification et suppression seront bloquées.'
              : 'Toutes les actions de modification seront réactivées. Agissez avec précaution.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(settingsProvider.notifier).toggleDemoMode(newValue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newValue ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(newValue ? 'Activer' : 'Désactiver'),
          ),
        ],
      ),
    );
  }
}

class _BlockedModuleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isBlocked;

  const _BlockedModuleRow({
    required this.icon,
    required this.label,
    required this.isBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      label: label,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBlocked ? Icons.lock_outline : Icons.lock_open_outlined,
            size: 16,
            color: isBlocked ? Colors.orange.shade600 : Colors.green.shade600,
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isBlocked ? Colors.orange.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isBlocked
                    ? Colors.orange.shade200
                    : Colors.green.shade200,
              ),
            ),
            child: Text(
              isBlocked ? 'Bloqué' : 'Actif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isBlocked
                    ? Colors.orange.shade800
                    : Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}