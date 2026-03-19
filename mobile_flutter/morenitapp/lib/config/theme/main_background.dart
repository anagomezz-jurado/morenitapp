import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos resizeToAvoidBottomInset para que el teclado no rompa el diseño
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 1. Fondo Verde (El contenedor con bordes)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.28, // Un poquito más alto
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 20, 78, 23),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. Capa de Contenido
          SafeArea(
            child: Column(
              children: [
                // TÍTULO: Ahora está en un Column, así que el child NUNCA lo tapará
                if (title != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text(
                      title!,
                      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22, // Un pelín más pequeño para que quepa bien
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // EL CONTENIDO (Login, Registro, etc.)
                Expanded(
                  child: child, // El child ahora empieza debajo del título
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}