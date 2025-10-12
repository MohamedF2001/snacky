import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snacky/app.dart';
import 'package:snacky/virtual.dart';

import 'const/app_theme.dart';

/* void main() {
  runApp(const MyApp());
} */
void main() {
  runApp(const ProviderScope(child: FastFoodApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),
      theme: AppTheme.lightTheme, // 🌈 applique ton thème global ici
      home: Virtual(),
      //const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
