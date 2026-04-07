import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/libros/presentation/providers/libro_provider.dart';
import '../../domain/entities/libro.dart';

class LibrosScreen extends ConsumerWidget {
  const LibrosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos el watch para obtener la lista de libros del provider
    final libros = ref.watch(librosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Libros de la Hermandad', 
          style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildHeader(
            context, 
            ref, 
            'Buscar libro por nombre...', 
            () => _showLibroForm(context, ref)
          ),
          Expanded(
            child: _buildTableContainer(
              libros.isEmpty 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF714B67)))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                        columns: const [
                          DataColumn(label: Text('CÓDIGO')),
                          DataColumn(label: Text('NOMBRE DEL LIBRO')),
                          DataColumn(label: Text('AÑO')),
                          DataColumn(label: Text('TOTAL ANUNC.')),
                          DataColumn(label: Text('ACCIONES')),
                        ],
                        rows: libros.map((l) => DataRow(cells: [
                          DataCell(Text(l.codLibro)),
                          DataCell(Text(l.nombre)),
                          DataCell(Text(l.anio.toString())),
                          DataCell(Text('${l.totalAnunciantes.toStringAsFixed(2)} €')),
                          DataCell(_buildActionButtons(
                            onEdit: () => _showLibroForm(context, ref, libro: l),
                            onDelete: () => _confirmarEliminacion(context, ref, l),
                          )),
                        ])).toList(),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FORMULARIO DE CREACIÓN / EDICIÓN ---
  void _showLibroForm(BuildContext context, WidgetRef ref, {Libro? libro}) {
    final codCtrl = TextEditingController(text: libro?.codLibro ?? '');
    final nomCtrl = TextEditingController(text: libro?.nombre ?? '');
    final anioCtrl = TextEditingController(text: libro?.anio.toString() ?? '');
    final descCtrl = TextEditingController(text: libro?.descripcion ?? '');
    final importeCtrl = TextEditingController(text: libro?.importe.toString() ?? '0.0');

    _showStyledDialog(
      context,
      title: libro == null ? 'Nuevo Libro' : 'Modificar Libro',
      content: [
        _buildTextField(codCtrl, 'Código Libro'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre del Libro'),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildTextField(anioCtrl, 'Año', isNumeric: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(importeCtrl, 'Importe Base', isNumeric: true)),
          ],
        ),
        const SizedBox(height: 15),
        _buildTextField(descCtrl, 'Descripción', maxLines: 2),
      ],
      onSave: () {
        final Map<String, dynamic> datos = {
          'cod_libro': codCtrl.text,
          'nombre': nomCtrl.text,
          'anio': int.tryParse(anioCtrl.text) ?? 0,
          'descripcion': descCtrl.text,
          'importe': double.tryParse(importeCtrl.text) ?? 0.0,
        };

        if (libro == null) {
          ref.read(librosProvider.notifier).agregarLibro(datos);
        } else {
          // Aquí llamarías a la función editar si la implementas en el notifier
          // ref.read(librosProvider.notifier).editarLibro(libro.id, datos);
        }
      },
    );
  }

  void _confirmarEliminacion(BuildContext context, WidgetRef ref, Libro libro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Deseas eliminar el libro "${libro.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(librosProvider.notifier).borrarLibro(libro.id);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

// --- COMPONENTES VISUALES (REUTILIZANDO TU FORMATO) ---

Widget _buildHeader(BuildContext context, WidgetRef ref, String hint, VoidCallback onNew) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    child: Row(
      children: [
        ElevatedButton.icon(
          onPressed: onNew,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text('NUEVO LIBRO', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF714B67),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 250, height: 35,
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              suffixIcon: const Icon(Icons.search, size: 20),
              filled: true, fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4), 
                borderSide: const BorderSide(color: Color(0xFFDEE2E6))
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTableContainer(Widget child) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
    ),
    child: child,
  );
}

Widget _buildActionButtons({required VoidCallback onEdit, required VoidCallback onDelete}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: onEdit),
      IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: onDelete),
    ],
  );
}

void _showStyledDialog(BuildContext context, {required String title, required List<Widget> content, required VoidCallback onSave}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: content),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF714B67)),
          onPressed: () { onSave(); Navigator.pop(context); },
          child: const Text('GUARDAR'),
        ),
      ],
    ),
  );
}

Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumeric = false, int maxLines = 1}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label, 
      border: const OutlineInputBorder(), 
      isDense: true,
      contentPadding: const EdgeInsets.all(12),
    ),
  );
}