import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cargo.dart';
import '../providers/secretaria_provider.dart';

class CargosScreen extends ConsumerWidget {
  const CargosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargosAsync = ref.watch(cargosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Gestión de Cargos', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar cargo...', () => _showCargoForm(context, ref)),
          Expanded(
            child: _buildTableContainer(
              cargosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (cargos) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('COD')),
                        DataColumn(label: Text('NOMBRE DEL CARGO')),
                        DataColumn(label: Text('FECHA INICIO')),
                        DataColumn(label: Text('FECHA FIN')),
                        DataColumn(label: Text('ACCIONES')),
                      ],
                      rows: cargos.map((c) => DataRow(cells: [
                        DataCell(Text(c.codCargo)),
                        DataCell(Text(c.nombreCargo)),
                        DataCell(Text(c.fechaInicio.toString().split(' ')[0])),
                        DataCell(Text(c.fechaFin?.toString().split(' ')[0] ?? '-')),
                        DataCell(Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () => _showCargoForm(context, ref, cargo: c)),
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

  void _showCargoForm(BuildContext context, WidgetRef ref, {Cargo? cargo}) {
    final codCtrl = TextEditingController(text: cargo?.codCargo ?? '');
    final nomCtrl = TextEditingController(text: cargo?.nombreCargo ?? '');
    final inicioCtrl = TextEditingController(text: cargo?.fechaInicio.toString().split(' ')[0] ?? '');
    final finCtrl = TextEditingController(text: cargo?.fechaFin?.toString().split(' ')[0] ?? '');

    _showStyledDialog(
      context,
      title: cargo == null ? 'Nuevo Cargo' : 'Editar Cargo',
      content: [
        _buildTextField(codCtrl, 'Código Cargo'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre del Cargo'),
        const SizedBox(height: 15),
        _buildTextField(inicioCtrl, 'Fecha Inicio (YYYY-MM-DD)'),
        const SizedBox(height: 15),
        _buildTextField(finCtrl, 'Fecha Fin (Opcional)'),
      ],
      onSave: () {
        final data = {
          'codCargo': codCtrl.text,
          'nombreCargo': nomCtrl.text,
          'fechaInicioCargo': inicioCtrl.text,
          'fechaFinCargo': finCtrl.text.isEmpty ? null : finCtrl.text,
        };
        if (cargo != null) data['id'] = int.parse(cargo.id) as String?;
        ref.read(cargosProvider.notifier).guardar(data);
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Cargo cargo) {
    _confirmDeleteDialog(context, () {
      ref.read(cargosProvider.notifier).eliminar(int.parse(cargo.id));
    }, cargo.nombreCargo);
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