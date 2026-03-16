// features/settings/presentation/views/sections/about_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/settings_widgets.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'À propos',
          subtitle: 'Informations sur l\'application Snacky Admin',
        ),
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Center(child: Text('🍔', style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Snacky Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Tableau de bord d\'administration fast-food', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade200)),
                      child: Text('v1.0.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange.shade800)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SettingsCard(
          title: 'Stack technique',
          icon: Icons.code,
          children: [
            _InfoRow(label: 'Frontend', value: 'Flutter 3.x • Dart 3.x'),
            _InfoRow(label: 'State management', value: 'Riverpod'),
            _InfoRow(label: 'Navigation', value: 'GoRouter'),
            _InfoRow(label: 'HTTP Client', value: 'Dio'),
            _InfoRow(label: 'Backend', value: 'Node.js • Express'),
            _InfoRow(label: 'Base de données', value: 'MongoDB Atlas'),
            _InfoRow(label: 'Hébergement API', value: 'Vercel'),
            _InfoRow(label: 'Images', value: 'Cloudinary'),
          ],
        ),
        SettingsCard(
          title: 'Informations légales',
          icon: Icons.gavel_outlined,
          children: [
            SettingsRow(label: 'Politique de confidentialité', trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18), onTap: () {}),
            SettingsRow(label: 'Conditions d\'utilisation', trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18), onTap: () {}),
            SettingsRow(label: 'Licences open source', trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18), onTap: () {}),
          ],
        ),
        SettingsCard(
          title: 'Support',
          icon: Icons.support_agent_outlined,
          children: [
            SettingsRow(
              label: 'Signaler un bug',
              subtitle: 'Envoyez un rapport d\'erreur',
              trailing: Icon(Icons.bug_report_outlined, color: Colors.grey.shade400, size: 18),
              onTap: () {},
            ),
            SettingsRow(
              label: 'Copier les infos de débogage',
              subtitle: 'Version, OS, identifiant session',
              trailing: Icon(Icons.copy_outlined, color: Colors.grey.shade400, size: 18),
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'Snacky Admin v1.0.0 | Flutter 3.x | Node.js API'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Infos copiées dans le presse-papiers'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}