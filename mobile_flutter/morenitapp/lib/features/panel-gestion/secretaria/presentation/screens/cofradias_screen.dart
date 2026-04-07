import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cofradia.dart';
import '../providers/secretaria_provider.dart';

class CofradiasScreen extends ConsumerWidget {
  const CofradiasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cofradiasAsync = ref.watch(cofradiasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Gestión de Cofradías', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar cofradía...', () => _showCofradiaForm(context, ref)),
          Expanded(
            child: _buildTableContainer(
              cofradiasAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (cofradias) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('CIF')),
                        DataColumn(label: Text('NOMBRE')),
                        DataColumn(label: Text('AÑO FUNDACIÓN')),
                        DataColumn(label: Text('EMAIL')),
                        DataColumn(label: Text('ACCIONES')),
                      ],
                      rows: cofradias.map((c) => DataRow(cells: [
                        DataCell(Text(c.cif)),
                        DataCell(Text(c.nombre)),
                        DataCell(Text(c.fundacion.toString())),
                        DataCell(Text(c.email)),
                        DataCell(Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () => _showCofradiaForm(context, ref, cofradia: c)),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _confirmarEliminar(context, ref, c)),
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

  void _showCofradiaForm(BuildContext context, WidgetRef ref, {Cofradia? cofradia}) {
    final cifCtrl = TextEditingController(text: cofradia?.cif ?? '');
    final nomCtrl = TextEditingController(text: cofradia?.nombre ?? '');
    final fundCtrl = TextEditingController(text: cofradia?.fundacion.toString() ?? '');
    final emailCtrl = TextEditingController(text: cofradia?.email ?? '');

    _showStyledDialog(
      context,
      title: cofradia == null ? 'Nueva Cofradía' : 'Editar Cofradía',
      content: [
        _buildTextField(cifCtrl, 'CIF'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre Cofradía'),
        const SizedBox(height: 15),
        _buildTextField(fundCtrl, 'Año Fundación', isNumeric: true),
        const SizedBox(height: 15),
        _buildTextField(emailCtrl, 'Email de Contacto'),
      ],
      onSave: () {
        final data = {
          'cifCofradia': cifCtrl.text,
          'nombreCofradia': nomCtrl.text,
          'antiguedadCofradia': int.tryParse(fundCtrl.text) ?? 0,
          'emailCofradia': emailCtrl.text,
        };
        if (cofradia != null) data['id'] = int.parse(cofradia.id);
        ref.read(cofradiasProvider.notifier).guardar(data);
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Cofradia cofradia) {
    _confirmDeleteDialog(context, () {
      ref.read(cofradiasProvider.notifier).eliminar(int.parse(cofradia.id));
    }, cofradia.nombre);
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