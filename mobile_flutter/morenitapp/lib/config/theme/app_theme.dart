import 'package:flutter/material.dart';

// CONFIGURACIÓN DEL TEMA
class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        fontFamily: 'Palatino', // Asegúrate de tener esta fuente en pubspec.yaml
        
        // Configuración de Colores
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF051906),
        ).copyWith(
          primary: const Color(0xFF09390C),
          secondary: const Color(0xFF3B673D),
        ),

        // Configuración global de AppBar y Títulos
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Color(0xFF2B2929), 
            size: 28
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// COMPONENTE DE FONDO REUTILIZABLE (MainBackground)
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
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).appBarTheme.titleTextStyle;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- CAPA 1: Fondo Verde de Cabecera (35% de altura) ---
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

          // --- CAPA 2: Contenido con Scroll ---
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),

                      // Título de la vista
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            title!, 
                            style: textStyle, 
                            textAlign: TextAlign.center
                          ),
                        ),

                      // Icono Flotante en Círculo
                      if (headerIcon != null)
                        _HeaderCircleIcon(child: headerIcon!),

                      const SizedBox(height: 30),

                      // Panel Blanco Inferior (Cuerpo de la vista)
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

// SUB-WIDGETS INTERNOS
class _HeaderCircleIcon extends StatelessWidget {
  final Widget child;

  const _HeaderCircleIcon({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12, 
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }
}