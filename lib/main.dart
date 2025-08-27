import 'package:flutter/material.dart';
import 'screens/welcome/welcome_screen.dart';
import 'utils/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],

      home: const WelcomeScreen(),
    );
  }
}
