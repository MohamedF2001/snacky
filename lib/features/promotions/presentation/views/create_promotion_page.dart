import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // ✅ pour formater les dates
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';
import 'package:snacky/features/promotions/presentation/providers/promotion_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

import '../../../../const/app_input_style.dart';
import '../../../products/presentation/providers/product_provider.dart'; // adapte le chemin

class CreatePromotionPage extends ConsumerStatefulWidget {
  const CreatePromotionPage({super.key});

  @override
  ConsumerState<CreatePromotionPage> createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends ConsumerState<CreatePromotionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _tarifController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;
  List<ProductEntity> _selectedProducts = [];

  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final createPromotionUsecase = ref.watch(createPromotionProvider);
    final productState = ref.watch(productListNotifier);

    if (productState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (productState.error != null) {
      return Center(child: Text("Erreur: ${productState.error}"));
    }

    // ✅ Format de date personnalisé
    String formatDate(DateTime? date) {
      if (date == null) return "";
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une promotion"),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // 🧾 Nom
                  TextFormField(
                    controller: _nomController,
                    decoration: AppInputStyles.textFieldDecoration(label: "Nom"),
                    validator: (v) => v == null || v.isEmpty ? "Nom requis" : null,
                  ),
                  const SizedBox(height: 16),

                  // 💰 Tarif
                  TextFormField(
                    controller: _tarifController,
                    keyboardType: TextInputType.number,
                    decoration: AppInputStyles.textFieldDecoration(label: "Tarif"),
                    validator: (v) => v == null || v.isEmpty ? "Tarif requis" : null,
                  ),
                  const SizedBox(height: 16),

                  // 🗓️ Dates côte à côte
                  Row(
                    children: [
                      // 📅 Date de début
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2030),
                              initialDate: DateTime.now(),
                            );
                            if (picked != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  _dateDebut = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: AppInputStyles.textFieldDecoration(
                                  label: "Date de début"),
                              controller: TextEditingController(
                                text: formatDate(_dateDebut),
                              ),
                              validator: (_) =>
                              _dateDebut == null ? "Date début requise" : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 📅 Date de fin
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2030),
                              initialDate: DateTime.now(),
                            );
                            if (picked != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  _dateFin = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: AppInputStyles.textFieldDecoration(
                                  label: "Date de fin"),
                              controller: TextEditingController(
                                text: formatDate(_dateFin),
                              ),
                              validator: (_) =>
                              _dateFin == null ? "Date fin requise" : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 🛍️ Sélection produits
                  const Text("Sélectionner les produits :",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  /*Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: productState.products.map((product) {
                      final isSelected = _selectedProducts.contains(product);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedProducts.remove(product);
                            } else {
                              _selectedProducts.add(product);
                            }
                          });
                        },
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.orange : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Image.network(product.imageUrl ?? '',
                                  height: 60, fit: BoxFit.cover),
                              const SizedBox(height: 4),
                              Text(product.nom,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),*/

                  SizedBox(
                    height: 140, // Hauteur fixe pour la liste horizontale
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: productState.products.length,
                      itemBuilder: (context, index) {
                        final product = productState.products[index];
                        final isSelected = _selectedProducts.contains(product);

                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 8), // Espace entre les éléments
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedProducts.remove(product);
                                } else {
                                  _selectedProducts.add(product);
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(product.imageUrl ?? '',
                                      height: 60, fit: BoxFit.cover),
                                  const SizedBox(height: 4),
                                  Text(product.nom,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🔘 Bouton de création
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate() ||
                          _selectedProducts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Veuillez remplir tous les champs"),
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      final promo = PromotionEntity(
                        nom: _nomController.text,
                        tarif:
                        double.tryParse(_tarifController.text) ?? 0.0,
                        produits: _selectedProducts,
                        dateDebut: _dateDebut!,
                        dateFin: _dateFin!,
                      );

                      final result =
                      await createPromotionUsecase.execute(promo);

                      if (!mounted) return;

                      result.fold(
                            (failure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                              Text("Erreur : ${failure.toString()}"),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                          setState(() => isSubmitting = false);
                        },
                            (success) {
                          ref
                              .read(promotionListNotifier.notifier)
                              .getPromotions();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text("Promotion créée avec succès !"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          context.pop();
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                    )
                        : const Text(
                      "Créer la promotion",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

