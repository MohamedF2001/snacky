// features/settings/presentation/views/sections/api_section.dart

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_widgets.dart';

class ApiSection extends ConsumerStatefulWidget {
  const ApiSection({super.key});

  @override
  ConsumerState<ApiSection> createState() => _ApiSectionState();
}

class _ApiSectionState extends ConsumerState<ApiSection> {
  final _urlController = TextEditingController();
  bool _isEditingUrl = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final connState = ref.watch(connectionProvider);
    final settings = settingsState.settings;

    ref.listen<SettingsState>(settingsProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(settingsProvider.notifier).clearMessage();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'API & connexion',
          subtitle: 'Configuration du serveur backend Snacky',
        ),

        SettingsCard(
          title: 'Serveur',
          icon: Icons.dns_outlined,
          children: [
            // URL field
            if (!_isEditingUrl)
              SettingsRow(
                label: 'URL de l\'API',
                subtitle: settings.apiBaseUrl
                    .replaceAll('https://', '')
                    .replaceAll('https://corsproxy.io/?', ''),
                trailing: TextButton(
                  onPressed: () {
                    _urlController.text = 'https://snacky-api.vercel.app/api';
                    setState(() => _isEditingUrl = true);
                  },
                  child: const Text('Modifier', style: TextStyle(color: Colors.orange)),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'URL de l\'API',
                        hintText: 'https://monapi.com/api',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          const BorderSide(color: Colors.orange, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _isEditingUrl = false),
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
                            onPressed: () {
                              if (_urlController.text.isNotEmpty) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateApiUrl(_urlController.text.trim());
                                setState(() => _isEditingUrl = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Connection status
            SettingsRow(
              label: 'Statut de connexion',
              subtitle: _getLastCheckedText(connState.status?.lastChecked),
              trailing: _buildStatusBadge(connState),
            ),

            // Timeout
            SettingsRow(
              label: 'Timeout des requêtes',
              subtitle: 'Délai maximum avant erreur réseau',
              trailing: _TimeoutSelector(
                current: settings.connectTimeout,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .updateTimeouts(connect: v, receive: v),
              ),
            ),
          ],
        ),

        SettingsCard(
          title: 'Diagnostics',
          icon: Icons.monitor_heart_outlined,
          children: [
            SettingsRow(
              label: 'Tester la connexion',
              subtitle: connState.status != null
                  ? connState.status!.isOnline
                  ? 'Dernier ping : ${connState.status!.pingMs ?? 0} ms'
                  : 'Serveur inaccessible'
                  : 'Appuyez pour vérifier',
              trailing: connState.isChecking
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.orange, strokeWidth: 2),
              )
                  : ElevatedButton(
                onPressed: () =>
                    ref.read(connectionProvider.notifier).check(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Tester', style: TextStyle(fontSize: 13)),
              ),
            ),
            SettingsRow(
              label: 'Vider le cache local',
              subtitle:
              'Supprime les données temporaires (token conservé)',
              trailing: ElevatedButton(
                onPressed: settingsState.isLoading
                    ? null
                    : () => _confirmClearCache(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black87,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
                child: const Text('Vider', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ConnectionState connState) {
    if (connState.isChecking) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2),
      );
    }
    if (connState.status == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Inconnu',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600),
        ),
      );
    }
    final online = connState.status!.isOnline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: online ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: online ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            online ? 'En ligne' : 'Hors ligne',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: online ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ),
      ],
    );
  }

  String _getLastCheckedText(DateTime? lastChecked) {
    if (lastChecked == null) return 'Non vérifié';
    return 'Vérifié le ${DateFormat('dd/MM à HH:mm').format(lastChecked.toLocal())}';
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Vider le cache'),
        content: const Text(
          'Les données temporaires seront supprimées. Votre session restera active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(settingsProvider.notifier).clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _TimeoutSelector extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;

  const _TimeoutSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [10000, 15000, 30000, 60000];
    final labels = {
      10000: '10s',
      15000: '15s',
      30000: '30s',
      60000: '60s',
    };
    final safeValue = options.contains(current) ? current : 30000;
    return DropdownButton<int>(
      value: safeValue,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(8),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      items: options
          .map((o) => DropdownMenuItem<int>(
        value: o,
        child: Text(labels[o]!),
      ))
          .toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}