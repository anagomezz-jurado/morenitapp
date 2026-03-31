import 'package:flutter/material.dart';

// ----------------------------------------------------------------------------
// 1. CONFIGURACIÓN DEL TEMA (AppTheme)
// ----------------------------------------------------------------------------
class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        fontFamily: 'Palatino', // Asegúrate de tener esta fuente en pubspec.yaml
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 5, 25, 6),
        ).copyWith(
          primary: const Color.fromARGB(255, 9, 57, 12),
          secondary: const Color.fromARGB(255, 59, 103, 61),
        ),
        
        // Configuración global de AppBar y Títulos
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color.fromARGB(255, 43, 41, 41), size: 28),
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            
          ),
        ),
      );
}

// ----------------------------------------------------------------------------
// 2. COMPONENTE DE FONDO (MainBackground)
// ----------------------------------------------------------------------------
class MainBackground extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool centerTitle;

  const MainBackground({
    super.key,
    required this.child,
    this.title,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos los colores del tema actual para que todo sea consistente
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).appBarTheme.titleTextStyle;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // Evita que el teclado mueva los elementos del fondo
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 1. Fondo Superior (Usando el color primario del tema)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.28, 
            decoration: BoxDecoration(
              color: colors.primary, // <--- Conectado al AppTheme
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. Capa de Contenido (Título + Child)
          SafeArea(
            child: Column(
              children: [
                // TÍTULO: Estilo dinámico basado en el tema
                if (title != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text(
                      title!,
                      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                      style: textStyle, // <--- Conectado al AppTheme
                    ),
                  ),
                
                // EL CONTENIDO (Login, Registro, etc.)
                Expanded(
                  child: child, // Lo que pongas aquí aparecerá debajo del título
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}