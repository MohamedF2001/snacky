
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
