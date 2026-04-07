import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/autoridad.dart';
import '../providers/secretaria_provider.dart';

class AutoridadesScreen extends ConsumerWidget {
  const AutoridadesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoridadesAsync = ref.watch(autoridadesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Gestión de Autoridades', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar autoridad...', () => _showAutoridadForm(context, ref)),
          Expanded(
            child: _buildTableContainer(
              autoridadesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (autoridades) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('COD')),
                        DataColumn(label: Text('NOMBRE')),
                        DataColumn(label: Text('CARGO')),
                        DataColumn(label: Text('EMAIL')),
                        DataColumn(label: Text('ACCIONES')),
                      ],
                      rows: autoridades.map((a) => DataRow(cells: [
                        DataCell(Text(a.codAutoridad)),
                        DataCell(Text(a.nombreAutoridad)),
                        DataCell(Text(a.cargo)),
                        DataCell(Text(a.email)),
                        DataCell(Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () => _showAutoridadForm(context, ref, autoridad: a)),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _confirmarEliminar(context, ref, a)),
                          ],
                        )),
                      ])).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAutoridadForm(BuildContext context, WidgetRef ref, {Autoridad? autoridad}) {
    final codCtrl = TextEditingController(text: autoridad?.codAutoridad ?? '');
    final nomCtrl = TextEditingController(text: autoridad?.nombreAutoridad ?? '');
    final cargoCtrl = TextEditingController(text: autoridad?.cargo ?? '');
    final emailCtrl = TextEditingController(text: autoridad?.email ?? '');
    final telCtrl = TextEditingController(text: autoridad?.telefono ?? '');

    _showStyledDialog(
      context,
      title: autoridad == null ? 'Nueva Autoridad' : 'Editar Autoridad',
      content: [
        _buildTextField(codCtrl, 'Código Autoridad'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre Completo'),
        const SizedBox(height: 15),
        _buildTextField(cargoCtrl, 'Cargo / Título'),
        const SizedBox(height: 15),
        _buildTextField(emailCtrl, 'Correo Electrónico'),
        const SizedBox(height: 15),
        _buildTextField(telCtrl, 'Teléfono', isNumeric: true),
      ],
      onSave: () {
        final data = {
          'codAutoridad': codCtrl.text,
          'nombreAutoridad': nomCtrl.text,
          'cargo': cargoCtrl.text,
          'correoElectronico': emailCtrl.text,
          'telefono': telCtrl.text,
        };
        if (autoridad != null) data['id'] = int.parse(autoridad.id) as String;
        ref.read(autoridadesProvider.notifier).guardar(data);
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Autoridad autoridad) {
    _confirmDeleteDialog(context, () {
      ref.read(autoridadesProvider.notifier).eliminar(int.parse(autoridad.id));
    }, autoridad.nombreAutoridad);
  }
}

// --- MÉTODOS AUXILIARES COMPARTIDOS ---

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

void _showStyledDialog(BuildContext context, {required String title, required List<Widget> content, required VoidCallback onSave}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: content)),
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

Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumeric = false}) {
  return TextField(
    controller: ctrl,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
  );
}

void _confirmDeleteDialog(BuildContext context, VoidCallback onDelete, String name) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Eliminar registro?'),
      content: Text('Esta acción eliminará a "$name". No se puede deshacer.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () { onDelete(); Navigator.pop(context); }, 
          child: const Text('ELIMINAR')
        ),
      ],
    ),
  );
}