// features/settings/presentation/views/sections/profile_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/auth/presentation/providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_widgets.dart';

class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key});

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);

    ref.listen<ProfileState>(profileProvider, (_, next) {
      if (next.updateSuccess) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(profileProvider.notifier).clearState();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${next.error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(profileProvider.notifier).clearState();
      }
    });

    final profile = profileState.profile;
    final initials = profile != null && profile.nom.isNotEmpty
        ? profile.nom.substring(0, profile.nom.length >= 2 ? 2 : 1).toUpperCase()
        : 'AD';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Profil administrateur',
          subtitle: 'Informations de votre compte admin',
        ),

        // Avatar card
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade100, blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                ),
                child: Center(
                  child: profileState.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    initials,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.nom ?? authState.user?.nom ?? 'Administrateur',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.email ?? authState.user?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  profile?.role ?? 'Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Edit form or info card
        SettingsCard(
          title: 'Identité',
          icon: Icons.badge_outlined,
          children: [
            if (!_isEditing) ...[
              SettingsRow(
                label: 'Nom complet',
                subtitle: profile?.nom ?? authState.user?.nom ?? '—',
                /*trailing: TextButton(
                  onPressed: () {
                    _nomController.text = profile?.nom ?? authState.user?.nom ?? '';
                    _emailController.text = profile?.email ?? authState.user?.email ?? '';
                    setState(() => _isEditing = true);
                  },
                  child: const Text(
                    'Modifier',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),*/
              ),
              SettingsRow(
                label: 'Adresse email',
                subtitle: profile?.email ?? authState.user?.email ?? '—',
              ),
              if (profile?.telephone != null)
                SettingsRow(
                  label: 'Téléphone',
                  subtitle: profile!.telephone!,
                ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        labelText: 'Nom complet',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: profileState.isLoading
                                ? null
                                : () {
                              if (_nomController.text.isNotEmpty &&
                                  _emailController.text.isNotEmpty) {
                                ref
                                    .read(profileProvider.notifier)
                                    .updateProfile(
                                  nom: _nomController.text.trim(),
                                  email: _emailController.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: profileState.isLoading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        // Session card
        SettingsCard(
          title: 'Session',
          icon: Icons.logout,
          children: [
            SettingsRow(
              label: 'Se déconnecter',
              subtitle: 'Terminer la session en cours',
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}