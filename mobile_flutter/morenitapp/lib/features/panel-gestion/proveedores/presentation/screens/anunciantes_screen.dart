import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/domain/entities/proveedor.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';


class AnunciantesScreen extends ConsumerWidget {
  const AnunciantesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaAnunciantes = ref.watch(listaSoloAnunciantes);
    final asyncState = ref.watch(proveedoresProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Panel de Anunciantes', style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar anunciante...', 
            () => _abrirFormulario(context, ref, forcedAnunciante: true)),
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
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: listaAnunciantes.map((p) => DataRow(cells: [
                      DataCell(Text(p.codProveedor)),
                      DataCell(Text(p.nombre)),
                      DataCell(Text(p.telefono ?? '')),
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

  // Métodos de ayuda (Shared UI)
  void _abrirFormulario(BuildContext context, WidgetRef ref, {Proveedor? proveedor, bool forcedAnunciante = false}) {
    final isEdit = proveedor != null;
    final codCtrl = TextEditingController(text: proveedor?.codProveedor ?? '');
    final nomCtrl = TextEditingController(text: proveedor?.nombre ?? '');
    final telCtrl = TextEditingController(text: proveedor?.telefono ?? '');
    bool esAnunciante = isEdit ? proveedor.anunciante : forcedAnunciante;

    _showStyledDialog(
      context,
      title: isEdit ? 'Editar Anunciante' : 'Nuevo Anunciante',
      content: [
        _buildTextField(codCtrl, 'Código'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre'),
        const SizedBox(height: 15),
        _buildTextField(telCtrl, 'Teléfono', isNumeric: true),
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
          notifier.editar(id: proveedor.id, codigo: codCtrl.text, nombre: nomCtrl.text, esAnunciante: esAnunciante, telefono: telCtrl.text);
        } else {
          notifier.crear(codigo: codCtrl.text, nombre: nomCtrl.text, esAnunciante: esAnunciante, telefono: telCtrl.text);
        }
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Proveedor p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Desea eliminar a ${p.nombre}?'),
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