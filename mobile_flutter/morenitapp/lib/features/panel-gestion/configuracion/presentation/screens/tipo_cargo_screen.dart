import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/configuracion_provider.dart';

class TipoCargoScreen extends ConsumerWidget {
  const TipoCargoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargosAsync = ref.watch(tiposCargoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Tipos de Cargo', style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // CABECERA: BOTÓN NUEVO Y BUSCADOR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showCargoForm(context, ref),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('NUEVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF714B67),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  height: 35,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar cargo...',
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      suffixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TABLA DE DATOS
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: cargosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF714B67))),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (lista) => SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
                      columns: const [
                        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('OBSERVACIONES', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: lista.map((cargo) => DataRow(cells: [
                        DataCell(Text(cargo.codigo)),
                        DataCell(Text(cargo.nombre)),
                        DataCell(Text(cargo.observaciones ?? '-')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () => _showCargoForm(context, ref, cargo: cargo),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _confirmarEliminar(context, ref, cargo),
                              ),
                            ],
                          ),
                        ),
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

  // MODAL DE FORMULARIO (ESTILO LIMPIO)
  void _showCargoForm(BuildContext context, WidgetRef ref, {dynamic cargo}) {
    final codCtrl = TextEditingController(text: cargo?.codigo ?? '');
    final nomCtrl = TextEditingController(text: cargo?.nombre ?? '');
    final obsCtrl = TextEditingController(text: cargo?.observaciones ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(cargo == null ? 'Nuevo Cargo' : 'Editar Cargo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codCtrl, decoration: const InputDecoration(labelText: 'Código', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: obsCtrl, decoration: const InputDecoration(labelText: 'Observaciones', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF714B67)),
            onPressed: () {
              final notifier = ref.read(tiposCargoProvider.notifier);
              if (cargo == null) {
                notifier.crear(codCtrl.text, nomCtrl.text, obsCtrl.text);
              } else {
                notifier.editar(cargo.id, codCtrl.text, nomCtrl.text, obsCtrl.text);
              }
              Navigator.pop(context);
            },
            child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, dynamic cargo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('Se eliminará el cargo: ${cargo.nombre}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(
            onPressed: () {
              ref.read(tiposCargoProvider.notifier).eliminar(cargo.id!);
              Navigator.pop(context);
            }, 
            child: const Text('SÍ, ELIMINAR', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}