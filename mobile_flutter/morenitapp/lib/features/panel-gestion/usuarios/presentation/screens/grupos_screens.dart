
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/domain/entities/grupo_user.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/presentation/providers/usuarios_provider.dart';

class GruposScreen extends ConsumerWidget {
  const GruposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gruposAsync = ref.watch(gruposProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grupos y Permisos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGrupoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: gruposAsync.when(
        data: (grupos) => ListView.builder(
          itemCount: grupos.length,
          itemBuilder: (_, i) {
            final g = grupos[i];
            return ListTile(
              title: Text(g.nombre),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showGrupoDialog(context, ref, grupo: g),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => ref.read(gruposProvider.notifier).eliminar(g.id),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error cargando grupos')),
      ),
    );
  }
}

void _showGrupoDialog(BuildContext context, WidgetRef ref, {Grupo? grupo}) {
  final ctrl = TextEditingController(text: grupo?.nombre ?? '');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(grupo == null ? 'Nuevo Grupo' : 'Editar Grupo'),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(labelText: 'Nombre'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (ctrl.text.trim().isEmpty) return;

            if (grupo == null) {
              ref.read(gruposProvider.notifier).crear(ctrl.text.trim());
            } else {
              ref.read(gruposProvider.notifier).editar(grupo.id, ctrl.text.trim());
            }

            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        )
      ],
    ),
  );
}