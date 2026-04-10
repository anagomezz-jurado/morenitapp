import 'package:flutter/material.dart';

class PlantillaWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final VoidCallback onSave;
  final bool isLoading;

  const PlantillaWrapper({
    super.key,
    required this.child,
    required this.title,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Color principal extraído del tema (usualmente el #714B67 que manejas)
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Gris muy claro de fondo
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Botón de guardado rápido en la AppBar
          if (!isLoading)
            IconButton(
              onPressed: onSave,
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Guardar',
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Contenido principal con scroll
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: child,
            ),
          ),

          // Pantalla de bloqueo opaca durante la carga
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.6),
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}