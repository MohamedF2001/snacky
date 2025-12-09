/*

import 'package:flutter/material.dart';
import 'package:snacky/features/products/presentation/widgets/admin_menu_widget.dart';

class AdminHomePage extends StatefulWidget {
  final Widget child; // ✅ le contenu qui change (route)

  const AdminHomePage({super.key, required this.child});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu latéral
          AdminMenuWidget(selectedIndex: _selectedIndex),
          // Contenu dynamique (route actuelle)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final slide =
                    Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    );
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: widget.child, // ✅ fourni par GoRouter ShellRoute
            ),
          ),
        ],
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/features/products/presentation/widgets/admin_menu_widget.dart';

class AdminHomePage extends StatefulWidget {
  final Widget child;

  const AdminHomePage({super.key, required this.child});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Détermine si on est en mode mobile
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      key: _scaffoldKey,
      // AppBar visible uniquement sur mobile
      appBar: isMobile
          ? AppBar(
        title: const Text('Snacky Admin'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
      )
          : null,
      // Drawer pour le menu mobile
      drawer: isMobile
          ? Drawer(
        child: AdminMenuWidget(
          selectedIndex: _selectedIndex,
          isMobile: true,
        ),
      )
          : null,
      body: Row(
        children: [
          // Menu latéral visible uniquement sur desktop
          if (!isMobile) AdminMenuWidget(selectedIndex: _selectedIndex),

          // Contenu dynamique
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                );
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
