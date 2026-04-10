import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
// import 'ubicaciones_provider.dart';

class DireccionScreen extends ConsumerWidget {
  const DireccionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direccionesAsync = ref.watch(direccionesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Direcciones'), backgroundColor: const Color(0xFF714B67)),
      body: direccionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lista) => ListView.builder(
          itemCount: lista.length,
          itemBuilder: (context, i) => ListTile(
            leading: const Icon(Icons.home),
            title: Text('${lista[i].calle} ${lista[i].numero}'),
            subtitle: const Text('Ver detalles...'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final calleCtrl = TextEditingController();
    final numeroCtrl = TextEditingController();
    
    // Variables de selección
    int? selProvId;
    int? selLocId;
    int? selCPId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Para refrescar el diálogo al seleccionar
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Dirección'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: calleCtrl, decoration: const InputDecoration(labelText: 'Calle')),
                TextField(controller: numeroCtrl, decoration: const InputDecoration(labelText: 'Número')),
                const Divider(),
                
                // --- SELECTOR PROVINCIA ---
                ref.watch(provinciasProvider).whenData((list) => DropdownButtonFormField<int>(
                  hint: const Text('Provincia'),
                  value: selProvId,
                  items: list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
                  onChanged: (val) => setState(() { selProvId = val; selLocId = null; selCPId = null; }),
                )).value ?? const SizedBox(),

                // --- SELECTOR LOCALIDAD (Filtrado por Provincia) ---
                if (selProvId != null)
                  ref.watch(localidadesProvider).whenData((list) => DropdownButtonFormField<int>(
                    hint: const Text('Localidad'),
                    value: selLocId,
                    items: list.where((l) => l.codProvinciaId == selProvId)
                               .map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
                    onChanged: (val) => setState(() { selLocId = val; selCPId = null; }),
                  )).value ?? const SizedBox(),

                // --- SELECTOR CP (Filtrado por Localidad) ---
                if (selLocId != null)
                  ref.watch(codigosPostalesProvider).whenData((list) => DropdownButtonFormField<int>(
                    hint: const Text('Código Postal'),
                    value: selCPId,
                    items: list.where((cp) => cp.localidadId == selLocId)
                               .map((cp) => DropdownMenuItem(value: cp.id, child: Text(cp.name))).toList(),
                    onChanged: (val) => setState(() => selCPId = val),
                  )).value ?? const SizedBox(),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                if (calleCtrl.text.isEmpty || selCPId == null) return;
                await ref.read(direccionesProvider.notifier).agregarDireccion(
                  calleCtrl.text, numeroCtrl.text, selProvId!, selLocId!, selCPId!
                );
                Navigator.pop(context);
              },
              child: const Text('GUARDAR'),
            )
          ],
        ),
      ),
    );
  }
}