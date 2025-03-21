import 'package:esof/pages/landing_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoFinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3E8E4D)),
        useMaterial3: true,
      ),
      home: LandingPage(), // Now pointing to LandingPage instead of MapPage
    );
  }
}