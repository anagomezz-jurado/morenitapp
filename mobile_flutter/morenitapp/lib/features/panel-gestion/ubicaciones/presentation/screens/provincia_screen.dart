import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/provincia.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class ProvinciaScreen extends ConsumerWidget {
  const ProvinciaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinciasAsync = ref.watch(provinciasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provincias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(provinciasProvider.notifier).cargarProvincias(),
          )
        ],
      ),
      body: provinciasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (provincias) => ListView.builder(
          itemCount: provincias.length,
          itemBuilder: (context, index) {
            final provincia = provincias[index];
            return ListTile(
              title: Text(provincia.nombreProvincia),
              subtitle: Text('Código: ${provincia.codProvincia}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showForm(context, ref, provincia: provincia),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, provincia),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(context, ref),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {Provincia? provincia}) {
    final isEditing = provincia != null;
    final codeCtrl = TextEditingController(text: provincia?.codProvincia);
    final nameCtrl = TextEditingController(text: provincia?.nombreProvincia);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Provincia' : 'Nueva Provincia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Código')),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (isEditing) {
                await ref.read(provinciasProvider.notifier).editarProvincia(provincia.id, nameCtrl.text, codeCtrl.text);
              } else {
                await ref.read(provinciasProvider.notifier).agregarProvincia(codeCtrl.text, nameCtrl.text);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Provincia provincia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar ${provincia.nombreProvincia}?'),
        content: const Text('Esto podría afectar a las localidades vinculadas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () async {
              await ref.read(provinciasProvider.notifier).borrarProvincia(provincia.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Sí, eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}