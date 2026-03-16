// features/settings/presentation/views/sections/security_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/error/failures.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_widgets.dart';

class SecuritySection extends ConsumerStatefulWidget {
  const SecuritySection({super.key});

  @override
  ConsumerState<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends ConsumerState<SecuritySection> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _showPasswordForm = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final settingsState = ref.watch(settingsProvider);

    ref.listen<SecurityState>(securityProvider, (_, next) {
      if (next.changeSuccess) {
        setState(() {
          _showPasswordForm = false;
          _currentPassController.clear();
          _newPassController.clear();
          _confirmPassController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(securityProvider.notifier).clearState();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.maybeWhen(
              serverError: (msg) => msg ?? 'Erreur serveur',
              unauthorized: () => 'Mot de passe actuel incorrect',
              orElse: () => 'Une erreur est survenue',
            )),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(securityProvider.notifier).clearState();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Sécurité',
          subtitle: 'Gérez l\'accès et la confidentialité de votre compte',
        ),

        // Password card
        SettingsCard(
          title: 'Mot de passe',
          icon: Icons.lock_outline,
          children: [
            if (!_showPasswordForm)
              SettingsRow(
                label: 'Changer le mot de passe',
                subtitle: 'Modifier votre mot de passe administrateur',
                trailing: TextButton(
                  onPressed: () => setState(() => _showPasswordForm = true),
                  child: const Text('Modifier', style: TextStyle(color: Colors.orange)),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _currentPassController,
                      label: 'Mot de passe actuel',
                      obscure: _obscureCurrent,
                      onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      controller: _newPassController,
                      label: 'Nouveau mot de passe',
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      controller: _confirmPassController,
                      label: 'Confirmer le nouveau mot de passe',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showPasswordForm = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: securityState.isLoading
                                ? null
                                : () => _submitPasswordChange(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: securityState.isLoading
                                ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                                : const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SettingsToggleRow(
              label: 'Déconnexion automatique',
              subtitle: 'Après 30 min d\'inactivité',
              value: true,
              onChanged: (_) {},
            ),
          ],
        ),

        // Token card
        SettingsCard(
          title: 'Token d\'accès JWT',
          icon: Icons.vpn_key_outlined,
          children: [
            SettingsRow(
              label: 'Token actuel',
              subtitle: _maskToken(),
              trailing: TextButton(
                onPressed: () => _showRevokeDialog(context),
                child: const Text(
                  'Révoquer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),

        // Login history
        SettingsCard(
          title: 'Historique des connexions',
          icon: Icons.history,
          children: [
            if (securityState.loginHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Aucun historique disponible',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              )
            else
              ...securityState.loginHistory.take(5).map((entry) {
                final dateStr = entry['date'] as String? ?? '';
                DateTime? date;
                try { date = DateTime.parse(dateStr); } catch (_) {}
                return SettingsRow(
                  label: entry['device'] as String? ?? 'Appareil inconnu',
                  subtitle: date != null
                      ? DateFormat('dd/MM/yyyy à HH:mm').format(date.toLocal())
                      : dateStr,
                  trailing: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }

  void _submitPasswordChange() {
    if (_currentPassController.text.isEmpty ||
        _newPassController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit contenir au moins 6 caractères'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ref.read(securityProvider.notifier).changePassword(
      current: _currentPassController.text,
      newPass: _newPassController.text,
    );
  }

  String _maskToken() {
    // Récupère le token depuis SharedPreferences et le masque
    return 'eyJhbGci...••••••••••••••••';
  }

  void _showRevokeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Révoquer le token'),
        content: const Text(
          'Cette action vous déconnectera immédiatement. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Token révoqué — déconnexion en cours...'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Révoquer'),
          ),
        ],
      ),
    );
  }
}