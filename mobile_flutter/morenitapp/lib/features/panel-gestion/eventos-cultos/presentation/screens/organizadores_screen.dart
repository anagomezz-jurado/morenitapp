import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/organizador.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';

class OrganizadoresScreen extends ConsumerWidget {
  const OrganizadoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizadoresAsync = ref.watch(organizadoresProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Directorio de Organizadores', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(
            context, 
            ref, 
            'Buscar organizador...', 
            () => _showOrganizadorForm(context, ref)
          ),
          
          Expanded(
            child: organizadoresAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF714B67))),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (organizadores) => _buildTableContainer(
                organizadores.isEmpty 
                ? const Center(child: Text('No hay organizadores registrados'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                      columns: const [
                        DataColumn(label: Text('CIF', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('TELÉFONO', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: organizadores.map((o) => DataRow(cells: [
                        DataCell(Text(o.cif)),
                        DataCell(Text(o.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
                        DataCell(Text(o.telefono ?? '-')),
                        DataCell(_buildActionButtons(
                          onEdit: () => _showOrganizadorForm(context, ref, organizador: o),
                          onDelete: () => _confirmDelete(context, ref, o),
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

  // --- LÓGICA DE FORMULARIO ---
  void _showOrganizadorForm(BuildContext context, WidgetRef ref, {Organizador? organizador}) {
    final cifCtrl = TextEditingController(text: organizador?.cif ?? '');
    final nomCtrl = TextEditingController(text: organizador?.nombre ?? '');
    final telCtrl = TextEditingController(text: organizador?.telefono ?? '');

    _showStyledDialog(
      context,
      title: organizador == null ? 'Nuevo Organizador' : 'Actualizar Datos',
      content: [
        _buildTextField(cifCtrl, 'CIF / Identificación'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre o Razón Social'),
        const SizedBox(height: 15),
        _buildTextField(telCtrl, 'Teléfono de Contacto', isNumeric: true),
      ],
      onSave: () {
        final datos = {
          'cif': cifCtrl.text,
          'nombre': nomCtrl.text,
          'telefono': telCtrl.text,
          'direccion': 1, 
        };
        if (organizador == null) {
          ref.read(organizadoresProvider.notifier).crear(datos);
        } else {
          ref.read(organizadoresProvider.notifier).editar(organizador.id, datos);
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Organizador o) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar organizador?'),
        content: Text('Esta acción eliminará a ${o.nombre}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(organizadoresProvider.notifier).eliminar(o.id);
              Navigator.pop(context);
            }, 
            child: const Text('ELIMINAR')
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
          label: const Text('NUEVO', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF714B67),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 200, height: 38,
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true, fillColor: const Color(0xFFF8F9FA),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    ),
    child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
  );
}

Widget _buildActionButtons({required VoidCallback onEdit, required VoidCallback onDelete}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: onEdit),
      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
    ],
  );
}

void _showStyledDialog(BuildContext context, {required String title, required List<Widget> content, required VoidCallback onSave}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: content)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
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
  return TextFormField(
    controller: ctrl,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}