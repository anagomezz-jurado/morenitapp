import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';

class HermanoActivoListadoScreen extends ConsumerWidget {
  const HermanoActivoListadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hermanosAsync = ref.watch(hermanosFiltradosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Hermanos',
            style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF714B67)),
            onPressed: () => ref.refresh(hermanosListadoProvider),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/nuevo-hermano'),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('NUEVO',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF714B67),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.file_download_outlined,
                    color: Colors.grey, size: 22),
                const Spacer(),
                SizedBox(
                  width: 300,
                  height: 35,
                  child: TextField(
                    onChanged: (val) => ref
                        .read(hermanosFiltersProvider.notifier)
                        .setQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
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

          // BARRA DE HERRAMIENTAS
          Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFDEE2E6)))),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: Row(
              children: [
                _ToolButton(icon: Icons.filter_alt, label: 'Filtros'),
                _ToolButton(icon: Icons.layers, label: 'Agrupar por'),
                const Spacer(),
                hermanosAsync.when(
                  data: (h) => Text('1-${h.length} / ${h.length}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  error: (_, __) => const Text('0'),
                  loading: () => const Text('...'),
                ),
                const Icon(Icons.chevron_left, color: Colors.grey),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: hermanosAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF714B67))),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (hermanos) => SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(const Color(0xFFF8F9FA)),
                        columns: const [
                          DataColumn(label: Text('NOMBRE COMPLETO')),
                          DataColumn(label: Text('DNI')),
                          DataColumn(label: Text('TELÉFONO')),
                          DataColumn(label: Text('EMAIL')),
                          DataColumn(label: Text('FECHA ALTA')),
                        ],
                        rows: hermanos
                            .map((h) => DataRow(cells: [
                                  DataCell(Text('${h.nombre} ${h.apellido1}')),
                                  DataCell(Text(h.dni)),
                                  DataCell(Text(h.telefono)),
                                  DataCell(Text(h.email)),
                                  DataCell(Text(h.fechaAlta)),
                                ]))
                            .toList(),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ToolButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: Colors.black54),
      label: Text(label,
          style: const TextStyle(color: Colors.black54, fontSize: 13)),
    );
  }
}
