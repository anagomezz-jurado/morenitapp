import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/domain/entities/proveedor.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';


class ProveedoresScreen extends ConsumerWidget {
  const ProveedoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaTodos = ref.watch(listaTodosLosProveedores); // Aquí cargamos todos
    final asyncState = ref.watch(proveedoresProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Gestión de Proveedores', style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar proveedor...', () => _abrirFormulario(context, ref)),
          Expanded(
            child: _buildTableContainer(
              asyncState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF714B67))),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (_) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                    columns: const [
                      DataColumn(label: Text('CÓDIGO')),
                      DataColumn(label: Text('NOMBRE')),
                      DataColumn(label: Text('TELÉFONO')),
                      DataColumn(label: Text('EMAIL')),
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: listaTodos.map((p) => DataRow(cells: [
                      DataCell(Text(p.codProveedor)),
                      DataCell(Text(p.nombre)),
                      DataCell(Text(p.telefono ?? '')),
                      DataCell(Text(p.email ?? '')),
                      DataCell(_buildActionButtons(
                        onEdit: () => _abrirFormulario(context, ref, proveedor: p),
                        onDelete: () => _confirmarEliminar(context, ref, p),
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

  void _abrirFormulario(BuildContext context, WidgetRef ref, {Proveedor? proveedor}) {
    final isEdit = proveedor != null;
    final codCtrl = TextEditingController(text: proveedor?.codProveedor ?? '');
    final nomCtrl = TextEditingController(text: proveedor?.nombre ?? '');
    final telCtrl = TextEditingController(text: proveedor?.telefono ?? '');
    final emaCtrl = TextEditingController(text: proveedor?.email ?? '');
    bool esAnunciante = proveedor?.anunciante ?? false;

    _showStyledDialog(
      context,
      title: isEdit ? 'Editar Proveedor' : 'Nuevo Proveedor',
      content: [
        _buildTextField(codCtrl, 'Código'),
        const SizedBox(height: 10),
        _buildTextField(nomCtrl, 'Nombre'),
        const SizedBox(height: 10),
        _buildTextField(telCtrl, 'Teléfono', isNumeric: true),
        const SizedBox(height: 10),
        _buildTextField(emaCtrl, 'Email'),
        StatefulBuilder(
          builder: (context, setState) => CheckboxListTile(
            title: const Text("¿Es Anunciante?"),
            value: esAnunciante,
            onChanged: (val) => setState(() => esAnunciante = val!),
          ),
        ),
      ],
      onSave: () {
        final notifier = ref.read(proveedoresProvider.notifier);
        if (isEdit) {
          notifier.editar(id: proveedor.id, codigo: codCtrl.text, nombre: nomCtrl.text, esAnunciante: esAnunciante, telefono: telCtrl.text, email: emaCtrl.text);
        } else {
          notifier.crear(codigo: codCtrl.text, nombre: nomCtrl.text, esAnunciante: esAnunciante, telefono: telCtrl.text, email: emaCtrl.text);
        }
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Proveedor p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar a ${p.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              ref.read(proveedoresProvider.notifier).eliminar(int.parse(p.id));
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// --- COMPONENTES UI REUTILIZABLES (Colócalos al final o en un archivo común) ---

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