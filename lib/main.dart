import 'package:flutter/material.dart';
import 'screens/welcome/welcome_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const PlenoNexoApp());
}

class PlenoNexoApp extends StatelessWidget {
  const PlenoNexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlenoNexo',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
