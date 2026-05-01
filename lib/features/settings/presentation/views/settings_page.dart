// features/settings/presentation/views/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'sections/profile_section.dart';
import 'sections/security_section.dart';
import 'sections/notifications_section.dart';
import 'sections/display_section.dart';
import 'sections/demo_mode_section.dart';
import 'sections/api_section.dart';
import 'sections/about_section.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _selectedIndex = 0;

  final List<_SidebarItem> _items = const [
    _SidebarItem(icon: Icons.person_outline, label: 'Profil', group: 'Compte'),
    //_SidebarItem(icon: Icons.lock_outline, label: 'Sécurité', group: null),
    _SidebarItem(
        icon: Icons.notifications_none,
        label: 'Notifications',
        group: 'Application'),
    _SidebarItem(icon: Icons.palette_outlined, label: 'Affichage', group: null),
    //_SidebarItem(icon: Icons.visibility_outlined, label: 'Mode démo', group: null),
    //_SidebarItem(icon: Icons.link, label: 'API & connexion', group: 'Données'),
    _SidebarItem(icon: Icons.info_outline, label: 'À propos', group: null),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Général',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              ' / ',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
            ),
            Text(
              'Paramètres',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // ─── Sidebar ──────────────────────────────────────────────────────
          _buildSidebar(),
          // ─── Content ──────────────────────────────────────────────────────
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ..._buildSidebarItems(),
          const Spacer(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildSidebarItems() {
    final widgets = <Widget>[];
    String? lastGroup;
    final colorScheme = Theme.of(context).colorScheme;

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.group != null && item.group != lastGroup) {
        lastGroup = item.group;
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              item.group!.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
                letterSpacing: 0.8,
              ),
            ),
          ),
        );
      }

      final isActive = _selectedIndex == i;
      widgets.add(
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: isActive ? colorScheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isActive ? colorScheme.primary : Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: _getSection(_selectedIndex),
        ),
      ),
    );
  }

  Widget _getSection(int index) {
    switch (index) {
      case 0:
        return const ProfileSection();
      //case 1:
      //  return const SecuritySection();
      case 1:
        return const NotificationsSection();
      case 2:
        return const DisplaySection();
      //case 3:
      //  return const DemoModeSection();
      //case 4:
      //  return const ApiSection();
      case 3:
        return const AboutSection();
      default:
        return const ProfileSection();
    }
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String? group;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.group,
  });
}