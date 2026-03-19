import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        fontFamily: 'Palatino',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 5, 25, 6),
        ).copyWith(
          primary: const Color.fromARGB(255, 5, 25, 6),
          secondary: const Color.fromARGB(255, 67, 107, 68),
        ),
        // Configuración global de AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white, size: 28),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}