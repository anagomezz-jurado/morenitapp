import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class ProvinciaScreen extends ConsumerWidget {
  const ProvinciaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado de las provincias
    final provinciasAsync = ref.watch(provinciasProvider);

    return PlantillaVentanas(
      title: 'Gestión de Provincias',
      isLoading: provinciasAsync.isLoading,
      onRefresh: () => ref.read(provinciasProvider.notifier).cargarProvincias(),
      
      // Acción para el botón NUEVO
      onNuevo: () => _showFormDialog(context, ref),
      
      columns: const [
        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE PROVINCIA', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      
      rows: provinciasAsync.maybeWhen(
        data: (provincias) => provincias.map((prov) => DataRow(cells: [
          // Se muestra el código (codProvincia) o el ID si es nulo
          DataCell(Text(prov.codProvincia ?? prov.id.toString())), 
          DataCell(Text(prov.nombreProvincia, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => _showFormDialog(context, ref, provincia: prov),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, prov),
                ),
              ],
            ),
          ),
        ])).toList(),
        orElse: () => [],
      ),
    );
  }

  // --- DIÁLOGO PARA CREAR O EDITAR ---
  void _showFormDialog(BuildContext context, WidgetRef ref, {dynamic provincia}) {
    final isEdit = provincia != null;
    
    // Controladores de texto con valores iniciales si es edición
    final codigoController = TextEditingController(text: isEdit ? provincia.codProvincia : '');
    final nombreController = TextEditingController(text: isEdit ? provincia.nombreProvincia : '');

    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a usar los botones para cerrar
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(isEdit ? 'Editar Provincia' : 'Nueva Provincia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(
                labelText: 'Código (ej: 29)', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Provincia', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCELAR')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEdit ? Colors.blue : Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final codigo = codigoController.text.trim();
              final nombre = nombreController.text.trim();

              if (codigo.isEmpty || nombre.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, completa todos los campos')),
                );
                return;
              }

              try {
                if (isEdit) {
                  // Lógica para EDITAR
                  await ref.read(provinciasProvider.notifier).editarProvincia(
                    provincia.id, 
                    nombre, 
                    codigo
                  );
                } else {
                  // Lógica para CREAR
                  await ref.read(provinciasProvider.notifier).agregarProvincia(
                    codigo, 
                    nombre
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Provincia actualizada' : 'Provincia creada exitosamente')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(isEdit ? 'GUARDAR CAMBIOS' : 'CREAR'),
          ),
        ],
      ),
    );
  }

  // --- DIÁLOGO DE CONFIRMACIÓN DE BORRADO ---
  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic prov) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: Text('¿Desea eliminar definitivamente la provincia "${prov.nombreProvincia}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCELAR')
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(provinciasProvider.notifier).borrarProvincia(prov.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _mostrarAdvertenciaUso(context, prov.nombreProvincia);
                }
              }
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  // --- ERROR AL ELIMINAR (DEPENDENCIAS ACTIVAS) ---
  void _mostrarAdvertenciaUso(BuildContext context, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
        content: Text(
          'La provincia "$nombre" tiene localidades o direcciones vinculadas y no puede ser eliminada por integridad de datos.', 
          textAlign: TextAlign.center
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('ENTENDIDO')
            )
          )
        ],
      ),
    );
  }
}