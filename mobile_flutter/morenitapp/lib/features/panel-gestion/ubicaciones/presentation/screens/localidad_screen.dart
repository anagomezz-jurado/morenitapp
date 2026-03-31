import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';

class LocalidadScreen extends ConsumerStatefulWidget {
  const LocalidadScreen({super.key});

  @override
  ConsumerState<LocalidadScreen> createState() => _LocalidadScreenState();
}

class _LocalidadScreenState extends ConsumerState<LocalidadScreen> {
  
  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider que ya tiene la lógica de filtrado aplicada
    final localidadesAsync = ref.watch(localidadesFiltradasProvider);
    final provinciasAsync = ref.watch(provinciasProvider);
    
    // Obtenemos el ID de la provincia seleccionada desde el provider global
    final filtroProvinciaId = ref.watch(provinciaFiltroSeleccionadaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Localidades')),
      body: Column(
        children: [
          // --- SECCIÓN DE FILTRO ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: provinciasAsync.when(
              data: (provincias) => DropdownButtonFormField<int>(
                value: filtroProvinciaId,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por Provincia',
                  prefixIcon: Icon(Icons.filter_list),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas las Provincias')),
                  ...provincias.map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.nombreProvincia),
                  )),
                ],
                onChanged: (val) {
                  // Actualizamos el estado del filtro en el provider
                  ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = val;
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error al cargar provincias'),
            ),
          ),

          // --- LISTADO DE LOCALIDADES ---
          Expanded(
            child: localidadesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Center(child: Text('Error: $err')),
              data: (localidades) {
                if (localidades.isEmpty) {
                  return const Center(child: Text('No hay localidades para esta selección'));
                }
                return ListView.builder(
                  itemCount: localidades.length,
                  itemBuilder: (context, index) {
                    final loc = localidades[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.location_city, size: 20),
                      ),
                      title: Text(loc.nombreLocalidad, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Capital: ${loc.nombreCapital}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showForm(context, localidad: loc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, loc),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(context),
      ),
    );
  }

  // --- DIÁLOGO PARA CREAR O EDITAR ---
  void _showForm(BuildContext context, {Localidad? localidad}) {
    final isEditing = localidad != null;
    final nameCtrl = TextEditingController(text: localidad?.nombreLocalidad);
    final capitalCtrl = TextEditingController(text: localidad?.nombreCapital);
    
    // Si estamos editando, usamos el ID de la provincia de la localidad.
    // Si es nueva, usamos el filtro actual (si existe).
    int? selectedProvincia = localidad?.codProvinciaId ?? ref.read(provinciaFiltroSeleccionadaProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Localidad' : 'Nueva Localidad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre de la Localidad'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capitalCtrl,
                decoration: const InputDecoration(labelText: 'Nombre de la Capital'),
              ),
              const SizedBox(height: 12),
              
              // Selector de Provincia dentro del Formulario
              ref.watch(provinciasProvider).whenData((provincias) => DropdownButtonFormField<int>(
                value: selectedProvincia,
                decoration: const InputDecoration(labelText: 'Provincia'),
                items: provincias.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.nombreProvincia),
                )).toList(),
                onChanged: (val) => selectedProvincia = val,
              )).value ?? const SizedBox(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedProvincia == null || nameCtrl.text.isEmpty) {
                // Podrías añadir un SnackBar aquí avisando que faltan campos
                return;
              }

              if (isEditing) {
                await ref.read(localidadesProvider.notifier).editarLocalidad(
                  localidad.id,
                  nameCtrl.text,
                  selectedProvincia!,
                  capitalCtrl.text,
                );
              } else {
                await ref.read(localidadesProvider.notifier).agregarLocalidad(
                  nameCtrl.text,
                  selectedProvincia!,
                  capitalCtrl.text,
                );
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // --- DIÁLOGO DE CONFIRMACIÓN DE BORRADO ---
  void _confirmDelete(BuildContext context, Localidad loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la localidad "${loc.nombreLocalidad}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(localidadesProvider.notifier).borrarLocalidad(loc.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}