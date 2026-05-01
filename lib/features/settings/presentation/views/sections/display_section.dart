// features/settings/presentation/views/sections/display_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_widgets.dart';

class DisplaySection extends ConsumerWidget {
  const DisplaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Affichage',
          subtitle: 'Personnalisez l\'interface de l\'application',
        ),
        SettingsCard(
          title: 'Thème',
          icon: Icons.palette_outlined,
          children: [
            SettingsRow(
              label: 'Thème de l\'interface',
              subtitle: 'Clair, sombre ou automatique',
              trailing: _ThemeSelector(
                current: state.settings.theme,
                onChanged: (t) => notifier.updateTheme(t),
              ),
            ),
            SettingsRow(
              label: 'Langue',
              subtitle: 'Langue de l\'interface',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SettingsBadge(text: 'Français'),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
                ],
              ),
            ),
          ],
        ),
        SettingsCard(
          title: 'Tableau de bord',
          icon: Icons.dashboard_outlined,
          children: [
            SettingsRow(
              label: 'Devise affichée',
              subtitle: 'Unité monétaire dans les prix',
              trailing: _CurrencySelector(
                current: state.settings.currency,
                onChanged: (c) => notifier.updateCurrency(c),
              ),
            ),
            SettingsRow(
              label: 'Cartes du dashboard',
              subtitle: 'Chiffre d\'affaires, commandes, produits...',
              trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _ThemeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final themes = [
      {'key': 'light', 'label': 'Clair'},
      {'key': 'dark', 'label': 'Sombre'},
      {'key': 'auto', 'label': 'Auto'},
    ];
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButton<String>(
      value: current,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(8),
      dropdownColor: colorScheme.surface,
      style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
      items: themes
          .map((t) => DropdownMenuItem<String>(
        value: t['key'],
        child: Text(t['label']!),
      ))
          .toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _CurrencySelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const currencies = ['F CFA', 'EUR', 'USD', 'GBP'];
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButton<String>(
      value: currencies.contains(current) ? current : 'F CFA',
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(8),
      dropdownColor: colorScheme.surface,
      style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
      items: currencies
          .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}