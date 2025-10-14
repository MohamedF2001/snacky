import 'package:flutter/material.dart';

class InfoClient extends StatefulWidget {
  final String nom;
  final String telephone;
  final String nbrProduits;
  const InfoClient({
    required this.nom,
    required this.telephone,
    required this.nbrProduits,
    super.key
  });

  @override
  State<InfoClient> createState() => _InfoClientState();
}

class _InfoClientState extends State<InfoClient> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.person, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.nom, style: const TextStyle(fontSize: 16))),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(Icons.phone, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(widget.telephone, style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),

        // Nombre de produits
        Row(
          children: [
            const Icon(Icons.shopping_bag, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              "${widget.nbrProduits} produit(s)",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
