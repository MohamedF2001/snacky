import 'package:flutter/material.dart';

class AppInputStyles {
  static InputDecoration textFieldDecoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelStyle: TextStyle(
        color: Colors.black
      ),
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }
}
