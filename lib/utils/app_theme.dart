import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ----------------- CORES -----------------
  static const Color brancoPrincipal = Color(0xFFEFF5F5);
  static const Color pretoPrincipal = Color(0xFF0A1010);
  static const Color azul1 = Color(0xFF89ACC2);
  static const Color azul5 = Color(0xFF4B8DB5);
  static const Color azul8 = Color(0xFF337097);
  static const Color azul9 = Color(0xFF2C678C);
  static const Color azul10 = Color(0xFF255878);
  static const Color azul11 = Color(0xFF204F6C);
  static const Color azul12 = Color(0xFF163D55);
  static const Color azul13 = Color(0xFF123348);
  static const Color verde1 = Color(0xFF7FA291);
  static const Color verde8 = Color(0xFF4A7861);
  static const Color verde10 = Color(0xFF3B6953);
  static const Color verde11 = Color(0xFF325E49);
  static const Color verde13 = Color(0xFF254C39);
  static const Color vermelho1 = Color(0xFFD9534F);
  static const Color vermelho2 = Color(0xFFDA3D38);
  static const Color vermelho3 = Color(0xFFD12924);

  static final TextStyle tituloPrincipal = GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.normal,
    color: brancoPrincipal,
  );

  static final TextStyle tituloPrincipalNegrito = GoogleFonts.montserrat(
    fontSize: 30,
    color: pretoPrincipal,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle textoBotaoBranco = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: brancoPrincipal,
  );

  /// Texto padrão do corpo do app em fundos escuros. Fonte: Poppins.
  static final TextStyle corpoTextoBranco = GoogleFonts.poppins(
    color: brancoPrincipal,
  );

  /// Texto menor e mais claro em fundos escuros. Fonte: Poppins.
  static final TextStyle corpoTextoClaro = GoogleFonts.poppins(
    color: brancoPrincipal,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: pretoPrincipal,
      scaffoldBackgroundColor: brancoPrincipal,
      colorScheme: const ColorScheme.light(
        primary: azul13,
        secondary: azul5,
        surface: brancoPrincipal,
        onPrimary: brancoPrincipal,
        onSecondary: brancoPrincipal,
        onSurface: azul13,
        error: vermelho3,
        onError: brancoPrincipal,
      ),
      // O textTheme pode ser removido ou mantido como um fallback,
      // mas nossa fonte principal de estilos agora são as constantes acima.
      // Vou deixar em branco para reforçar a nova abordagem.
      textTheme: TextTheme(),

      // Estilos de widgets ainda podem ser úteis para evitar repetição.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brancoPrincipal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        // Você ainda pode definir um estilo de texto padrão para os inputs aqui
        labelStyle: GoogleFonts.poppins(color: azul13),
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
      ),
    );
  }
}
