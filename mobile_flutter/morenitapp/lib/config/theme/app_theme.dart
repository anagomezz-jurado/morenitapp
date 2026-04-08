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
  final Widget? headerIcon;

  const MainBackground({
    super.key,
    required this.child,
    this.title,
    this.headerIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).appBarTheme.titleTextStyle;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo Verde Dinámico (35% de la altura)
          Container(
            width: double.infinity,
            height: size.height * 0.35,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // Contenido con Scroll para evitar el error de "Overflow"
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      // Título
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(title!, style: textStyle, textAlign: TextAlign.center),
                        ),

                      // Icono en Círculo
                      if (headerIcon != null)
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: headerIcon,
                        ),

                      // Espacio flexible que empuja la frase fuera del verde
                      const SizedBox(height: 30),

                      // El resto del contenido (Frase + Formulario)
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}