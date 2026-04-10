import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class CallesGestionScreen extends ConsumerStatefulWidget {
  const CallesGestionScreen({super.key});

  @override
  ConsumerState<CallesGestionScreen> createState() => _CallesGestionScreenState();
}

class _CallesGestionScreenState extends ConsumerState<CallesGestionScreen> {
  final nombreCalleCtrl = TextEditingController();
  int? idProvincia, idLocalidad, idCP;

  void _resetForm() {
    idProvincia = null; idLocalidad = null; idCP = null;
    nombreCalleCtrl.clear();
    ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = null;
    ref.read(localidadFiltroSeleccionadaProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final callesAsync = ref.watch(callesProvider);

    return PlantillaVentanas(
      title: 'Configuración de Calles',
      isLoading: callesAsync.isLoading,
      onRefresh: () => ref.read(callesProvider.notifier).cargarCalles(),
      onNuevo: () {
        _resetForm();
        _mostrarFormularioCalle(context);
      },
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('NOMBRE DE CALLE')),
        DataColumn(label: Text('ACCIONES')),
      ],
      rows: callesAsync.maybeWhen(
        data: (calles) => calles.map((calle) => DataRow(cells: [
          DataCell(Text(calle.id.toString())),
          DataCell(Text(calle.nombreCalle)),
          DataCell(Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarFormularioCalle(context, calleEdit: calle)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminacion(context, calle)),
            ],
          )),
        ])).toList(),
        orElse: () => [],
      ),
    );
  }

  void _mostrarFormularioCalle(BuildContext context, {dynamic calleEdit}) {
    if (calleEdit != null) {
      nombreCalleCtrl.text = calleEdit.nombreCalle;
      idLocalidad = calleEdit.localidadId;
      idCP = calleEdit.codPostalId;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final provincias = ref.watch(provinciasProvider);
          final localidades = ref.watch(localidadesFiltradasProvider);
          final cps = ref.watch(codigosPostalesFiltradosProvider);

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(calleEdit == null ? "Nueva Calle" : "Editar Calle", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                // PROVINCIA
                provincias.whenData((lista) => DropdownButtonFormField<int>(
                  value: idProvincia,
                  decoration: const InputDecoration(labelText: 'Provincia'),
                  items: lista.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
                  onChanged: (val) {
                    setModalState(() { idProvincia = val; idLocalidad = null; idCP = null; });
                    ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = val;
                  },
                )).value ?? const SizedBox(),
                // LOCALIDAD
                DropdownButtonFormField<int>(
                  value: idLocalidad,
                  decoration: const InputDecoration(labelText: 'Localidad'),
                  items: idProvincia == null ? [] : localidades.maybeWhen(
                    data: (lista) => lista.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
                    orElse: () => [],
                  ),
                  onChanged: (val) {
                    setModalState(() { idLocalidad = val; idCP = null; });
                    ref.read(localidadFiltroSeleccionadaProvider.notifier).state = val;
                  },
                ),
                // CP
                DropdownButtonFormField<int>(
                  value: idCP,
                  decoration: const InputDecoration(labelText: 'Código Postal'),
                  items: idLocalidad == null ? [] : cps.maybeWhen(
                    data: (lista) => lista.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    orElse: () => [],
                  ),
                  onChanged: (val) => setModalState(() => idCP = val),
                ),
                TextField(controller: nombreCalleCtrl, decoration: const InputDecoration(labelText: 'Nombre de Calle')),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  onPressed: () async {
                    if (idLocalidad == null || idCP == null || nombreCalleCtrl.text.isEmpty) return;
                    if (calleEdit == null) {
                      await ref.read(callesProvider.notifier).agregarCalle(nombreCalleCtrl.text, idLocalidad!, idCP!);
                    } else {
                      await ref.read(callesProvider.notifier).actualizarCalle(calleEdit.id, nombreCalleCtrl.text, idLocalidad!, idCP!);
                    }
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text("GUARDAR"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, dynamic calle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Borrar "${calle.nombreCalle}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          TextButton(onPressed: () async {
            await ref.read(callesProvider.notifier).borrarCalle(calle.id);
            if (mounted) Navigator.pop(context);
          }, child: const Text('SÍ', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}