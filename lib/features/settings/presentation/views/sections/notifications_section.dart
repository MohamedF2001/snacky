// features/settings/presentation/views/sections/notifications_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_widgets.dart';

class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notif = state.settings.notifications;
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Notifications',
          subtitle: 'Choisissez les alertes que vous souhaitez recevoir',
        ),
        SettingsCard(
          title: 'Commandes',
          icon: Icons.shopping_cart_outlined,
          children: [
            SettingsToggleRow(
              label: 'Nouvelle commande reçue',
              subtitle: 'Alerte en temps réel',
              value: notif.newOrder,
              onChanged: (v) => notifier.updateNotification('newOrder', v),
            ),
            SettingsToggleRow(
              label: 'Commande en attente',
              subtitle: 'Rappel après 10 min sans action',
              value: notif.pendingOrder,
              onChanged: (v) => notifier.updateNotification('pendingOrder', v),
            ),
            SettingsToggleRow(
              label: 'Commande annulée',
              subtitle: 'Notification immédiate',
              value: notif.cancelledOrder,
              onChanged: (v) => notifier.updateNotification('cancelledOrder', v),
            ),
          ],
        ),
        SettingsCard(
          title: 'Stock & produits',
          icon: Icons.inventory_2_outlined,
          children: [
            SettingsToggleRow(
              label: 'Rupture de stock imminente',
              subtitle: 'Alerte quand le stock atteint le seuil critique',
              value: notif.lowStock,
              onChanged: (v) => notifier.updateNotification('lowStock', v),
            ),
            SettingsToggleRow(
              label: 'Nouveau produit ajouté',
              subtitle: 'Confirmation après création',
              value: notif.newProduct,
              onChanged: (v) => notifier.updateNotification('newProduct', v),
            ),
          ],
        ),
      ],
    );
  }
}