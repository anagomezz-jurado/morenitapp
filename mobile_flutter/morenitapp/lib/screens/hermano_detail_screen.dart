import 'package:flutter/material.dart';
import 'package:morenitapp/models/hermano.dart';

class HermanoDetailScreen extends StatelessWidget {
  final Hermano hermano;

  const HermanoDetailScreen({super.key, required this.hermano});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hermano.nombre)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DNI: ${hermano.dni}'),
            Text('Teléfono: ${hermano.telefono}'),
            Text('Fecha Nacimiento: ${hermano.fechaNacimiento}'),
            Text('Método de Pago: ${hermano.metodoPago}'),
          ],
        ),
      ),
    );
  }
}