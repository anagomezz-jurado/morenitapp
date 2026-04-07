import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/configuracion_provider.dart';

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Gestión de Roles', style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar rol...', () => _showRoleForm(context, ref)),
          Expanded(
            child: _buildTableContainer(
              rolesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF714B67))),
                error: (e, __) => Center(child: Text('Error $e')),
                data: (roles) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
                    columns: const [
                      DataColumn(label: Text('ID / CÓDIGO')),
                      DataColumn(label: Text('NOMBRE DEL ROL')),
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: roles.map((r) => DataRow(cells: [
                      DataCell(CircleAvatar(radius: 12, child: Text(r.codigo.toString(), style: const TextStyle(fontSize: 10)))),
                      DataCell(Text(r.nombre)),
                      DataCell(_buildActionButtons(
                        onEdit: () => _showRoleForm(context, ref, rol: r),
                        onDelete: () => ref.read(rolesProvider.notifier).eliminar(r.id!),
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

  void _showRoleForm(BuildContext context, WidgetRef ref, {dynamic rol}) {
    final codCtrl = TextEditingController(text: rol?.codigo.toString() ?? '');
    final nomCtrl = TextEditingController(text: rol?.nombre ?? '');

    _showStyledDialog(
      context,
      title: 'Configurar Rol',
      content: [
        _buildTextField(codCtrl, 'Código Numérico', isNumeric: true),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre del Rol'),
      ],
      onSave: () {
        final code = int.tryParse(codCtrl.text) ?? 0;
        if (rol == null) {
          ref.read(rolesProvider.notifier).crear(code, nomCtrl.text);
        } else {
          ref.read(rolesProvider.notifier).editar(rol.id, code, nomCtrl.text);
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