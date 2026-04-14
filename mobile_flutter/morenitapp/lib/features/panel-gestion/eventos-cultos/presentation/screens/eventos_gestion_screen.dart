import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';

class EventosGestionScreen extends ConsumerWidget {
  const EventosGestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Gestión de Eventos', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar evento...', () => _showEventoForm(context, ref)),
          Expanded(
            child: eventosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (eventos) => _buildTableContainer(
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                    columns: const [
                      DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('LUGAR', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: eventos.map((e) => DataRow(cells: [
                      DataCell(Text(e.codEvento)),
                      DataCell(Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text(e.lugar ?? '-')),
                      DataCell(_buildActionButtons(
                        onEdit: () => _showEventoForm(context, ref, evento: e),
                        onDelete: () => ref.read(eventosProvider.notifier).eliminar(e.id),
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

  void _showEventoForm(BuildContext context, WidgetRef ref, {Evento? evento}) {
    final codCtrl = TextEditingController(text: evento?.codEvento ?? '');
    final nomCtrl = TextEditingController(text: evento?.nombre ?? '');
    final lugarCtrl = TextEditingController(text: evento?.lugar ?? '');

    _showStyledDialog(
      context,
      title: evento == null ? 'Crear Nuevo Evento' : 'Editar Evento',
      content: [
        _buildTextField(codCtrl, 'Código del Evento'),
        const SizedBox(height: 15),
        _buildTextField(nomCtrl, 'Nombre'),
        const SizedBox(height: 15),
        _buildTextField(lugarCtrl, 'Lugar'),
      ],
      onSave: () {
        final datos = {
          'cod_evento': codCtrl.text,
          'nombre': nomCtrl.text,
          'lugar': lugarCtrl.text,
          'fecha_inicio': evento?.fechaInicio.toIso8601String() ?? DateTime.now().toIso8601String(),
          'fecha_fin': evento?.fechaFin.toIso8601String() ?? DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        };
        if (evento == null) {
          ref.read(eventosProvider.notifier).crear(datos);
        } else {
          ref.read(eventosProvider.notifier).editar(evento.id, datos);
        }
      },
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