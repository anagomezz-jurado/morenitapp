import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/configuracion_provider.dart';

class TipoAutoridadScreen extends ConsumerWidget {
  const TipoAutoridadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoridadesAsync = ref.watch(tiposAutoridadProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Tipos de Autoridad', style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar...', () => _showForm(context, ref)),
          Expanded(
            child: _buildTableContainer(
              autoridadesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF714B67))),
                error: (e, __) => Center(child: Text('Error: $e')),
                data: (lista) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
                    columns: const [
                      DataColumn(label: Text('CÓDIGO')),
                      DataColumn(label: Text('NOMBRE')),
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: lista.map((a) => DataRow(cells: [
                      DataCell(Text(a.codigo)),
                      DataCell(Text(a.nombre)),
                      DataCell(_buildActionButtons(
                        onEdit: () => _showForm(context, ref, autoridad: a),
                        onDelete: () => ref.read(tiposAutoridadProvider.notifier).eliminar(a.id!),
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

  void _showForm(BuildContext context, WidgetRef ref, {dynamic autoridad}) {
    final codCtrl = TextEditingController(text: autoridad?.codigo ?? '');
    final nomCtrl = TextEditingController(text: autoridad?.nombre ?? '');

    _showStyledDialog(
      context,
      title: autoridad == null ? 'Nueva Autoridad' : 'Editar Autoridad',
      content: [
        _buildTextField(codCtrl, 'Código'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre'),
      ],
      onSave: () {
        if (autoridad == null) {
          ref.read(tiposAutoridadProvider.notifier).crear(codCtrl.text, nomCtrl.text);
        } else {
          ref.read(tiposAutoridadProvider.notifier).editar(autoridad.id, codCtrl.text, nomCtrl.text);
        }
      },
    );
  }
}

// 1. Cabecera con botón NUEVO y buscador
Widget _buildHeader(BuildContext context, WidgetRef ref, String hint, VoidCallback onNew) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    child: Row(
      children: [
        ElevatedButton.icon(
          onPressed: onNew,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text('NUEVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
            ),
          ),
        ),
      ],
    ),
  );
}

// 2. Contenedor de la tabla con sombra y fondo blanco
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

// 3. Botones de acción (Editar/Eliminar)
Widget _buildActionButtons({required VoidCallback onEdit, required VoidCallback onDelete}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: onEdit),
      IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: onDelete),
    ],
  );
}

// 4. Formulario en Dialog Estilizado
void _showStyledDialog(BuildContext context, {required String title, required List<Widget> content, required VoidCallback onSave}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: content),
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

// 5. TextField reutilizable para los Diálogos
Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumeric = false}) {
  return TextField(
    controller: ctrl,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
  );
}