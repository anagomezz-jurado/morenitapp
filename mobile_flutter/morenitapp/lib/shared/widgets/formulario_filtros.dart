import 'package:flutter/material.dart';

class FiltroContenedorTemplate extends StatelessWidget {
  final Widget child;
  final String label;

  const FiltroContenedorTemplate({
    super.key, 
    required this.child, 
    this.label = "Filtros Avanzados"
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // --- AQUÍ ESTÁ EL TRUCO ---
    // Envolvemos todo en un Theme local para que el 'child' (AdvancedFilterBar)
    // vea nuestro color primario como su color principal de Material 3.
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor, // Esto quita el morado de los botones
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Línea superior decorativa
              Container(height: 3, color: primaryColor),
              
              // Cabecera
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12, right: 16),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_outlined, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  ],
                ),
              ),
              
              // El contenido (Donde está el botón que salía morado)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: child, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}