import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class LocalidadScreen extends ConsumerStatefulWidget {
  const LocalidadScreen({super.key});

  @override
  ConsumerState<LocalidadScreen> createState() => _LocalidadScreenState();
}

class _LocalidadScreenState extends ConsumerState<LocalidadScreen> {
  @override
  Widget build(BuildContext context) {
    final localidadesAsync = ref.watch(localidadesFiltradasProvider);
    final provinciasAsync = ref.watch(provinciasProvider);
    final filtroProvinciaId = ref.watch(provinciaFiltroSeleccionadaProvider);

    return PlantillaVentanas(
      title: 'Gestión de Localidades',
      filtrosAdicionales: provinciasAsync.when(
        data: (provincias) => SizedBox(
          width: 250,
          child: DropdownButtonFormField<int>(
            value: filtroProvinciaId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Provincia', isDense: true),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas las Provincias')),
              ...provincias.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))),
            ],
            onChanged: (val) => ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = val,
          ),
        ),
        loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
      ),
      onDownload: () {
        final lista = localidadesAsync.value ?? [];
        ExcelService.descargarExcel(
          nombreArchivo: 'Localidades',
          cabeceras: ['ID', 'Localidad', 'Capital'],
          filas: lista.map((l) => [l.id, l.nombreLocalidad, l.nombreCapital]).toList(),
        );
      },
      isLoading: localidadesAsync.isLoading,
      onRefresh: () => ref.read(localidadesProvider.notifier).cargarLocalidades(),
      onNuevo: () => _showForm(context),
      columns: const [
        DataColumn(label: Text('NOMBRE LOCALIDAD')),
        DataColumn(label: Text('CAPITAL')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: localidadesAsync.when(
        data: (localidades) => localidades.map((loc) => DataRow(cells: [
          DataCell(Text(loc.nombreLocalidad)),
          DataCell(Text(loc.nombreCapital)),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(context, localidad: loc)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(context, loc)),
            ],
          )),
        ])).toList(),
        error: (err, _) => [],
        loading: () => [],
      ),
    );
  }

  void _showForm(BuildContext context, {Localidad? localidad}) {
    final isEditing = localidad != null;
    final nameCtrl = TextEditingController(text: localidad?.nombreLocalidad);
    final capitalCtrl = TextEditingController(text: localidad?.nombreCapital);
    int? selectedProvincia = localidad?.codProvinciaId ?? ref.read(provinciaFiltroSeleccionadaProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Localidad' : 'Nueva Localidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre Localidad')),
            TextField(controller: capitalCtrl, decoration: const InputDecoration(labelText: 'Capital')),
            const SizedBox(height: 15),
            ref.watch(provinciasProvider).whenData((provincias) => DropdownButtonFormField<int>(
              value: selectedProvincia,
              decoration: const InputDecoration(labelText: 'Provincia'),
              items: provincias.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
              onChanged: (val) => selectedProvincia = val,
            )).value ?? const SizedBox(),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              if (selectedProvincia == null || nameCtrl.text.isEmpty) return;
              if (isEditing) {
                await ref.read(localidadesProvider.notifier).editarLocalidad(localidad.id, nameCtrl.text, selectedProvincia!, capitalCtrl.text);
              } else {
                await ref.read(localidadesProvider.notifier).agregarLocalidad(nameCtrl.text, selectedProvincia!, capitalCtrl.text);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Localidad loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: Text('¿Desea eliminar la localidad "${loc.nombreLocalidad}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(
            onPressed: () async {
              await ref.read(localidadesProvider.notifier).borrarLocalidad(loc.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('SÍ, ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}