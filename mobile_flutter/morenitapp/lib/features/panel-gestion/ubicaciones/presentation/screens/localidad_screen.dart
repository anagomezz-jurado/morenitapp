import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/localidad.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
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
      isLoading: localidadesAsync.isLoading,
      onRefresh: () => ref.read(localidadesProvider.notifier).cargarLocalidades(),
      onNuevo: () => _showSideForm(context),
      filtrosAdicionales: provinciasAsync.when(
        data: (provincias) => SizedBox(
          width: 250,
          child: DropdownButtonFormField<int>(
            value: filtroProvinciaId,
            decoration: const InputDecoration(labelText: 'Filtrar por Provincia', isDense: true),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas las Provincias')),
              ...provincias.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))),
            ],
            onChanged: (val) => ref.read(provinciaFiltroSeleccionadaProvider.notifier).state = val,
          ),
        ),
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
      ),
      columns: const [
        DataColumn(label: Text('LOCALIDAD', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('PROVINCIA', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('CAPITAL', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: localidadesAsync.when(
        data: (lista) => lista.map((loc) => DataRow(cells: [
          DataCell(Text(loc.nombreLocalidad, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Text(loc.codProvinciaId != null ? provinciasAsync.value!.firstWhere((p) => p.id == loc.codProvinciaId!).nombreProvincia : '-', style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Text(loc.nombreCapital ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Row(
            children: [
              IconButton(icon: const Icon(Icons.edit_note, color: Colors.blue), onPressed: () => _showSideForm(context, localidad: loc)),
              IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red), onPressed: () => _confirmDelete(context, loc)),
            ],
          )),
        ])).toList(),
        error: (_, __) => [],
        loading: () => [],
      ),
    );
  }

  void _showSideForm(BuildContext context, {Localidad? localidad}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.35,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
            ),
            child: Material(child: _LocalidadFormContent(localidad: localidad)),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim1),
          child: child,
        );
      },
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(localidadesProvider.notifier).borrarLocalidad(loc.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _LocalidadFormContent extends ConsumerStatefulWidget {
  final Localidad? localidad;
  const _LocalidadFormContent({this.localidad});

  @override
  ConsumerState<_LocalidadFormContent> createState() => _LocalidadFormContentState();
}

class _LocalidadFormContentState extends ConsumerState<_LocalidadFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController capitalCtrl;
  int? selectedProvincia;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.localidad?.nombreLocalidad ?? '');
    capitalCtrl = TextEditingController(text: widget.localidad?.nombreCapital ?? '');
    selectedProvincia = widget.localidad?.codProvinciaId;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provincias = ref.watch(provinciasProvider);

    return Column(
      children: [
        _buildHeader(context, colors, widget.localidad == null),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("PROVINCIA"),
                  provincias.when(
                    data: (lista) => DropdownButtonFormField<int>(
                      value: selectedProvincia,
                      decoration: _inputDecoration(Icons.map_outlined),
                      items: lista.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
                      onChanged: (val) => setState(() => selectedProvincia = val),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text("Error al cargar"),
                  ),
                  const SizedBox(height: 25),
                  _label("NOMBRE DE LOCALIDAD"),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: _inputDecoration(Icons.location_city),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 25),
                  _label("CAPITAL"),
                  TextFormField(
                    controller: capitalCtrl,
                    decoration: _inputDecoration(Icons.star_outline),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: _save,
                      child: Text(widget.localidad == null ? "GUARDAR" : "ACTUALIZAR"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _save() async {
    if (!formKey.currentState!.validate() || selectedProvincia == null) return;
    if (widget.localidad == null) {
      await ref.read(localidadesProvider.notifier).agregarLocalidad(nameCtrl.text, selectedProvincia!, capitalCtrl.text);
    } else {
      await ref.read(localidadesProvider.notifier).editarLocalidad(widget.localidad!.id, nameCtrl.text, selectedProvincia!, capitalCtrl.text);
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
      color: colors.primary.withOpacity(0.08),
      child: Row(
        children: [
          Icon(isNew ? Icons.add_location : Icons.edit_location, color: colors.primary),
          const SizedBox(width: 12),
          Text(isNew ? 'Nueva Localidad' : 'Editar Localidad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)));
  InputDecoration _inputDecoration(IconData icon) => InputDecoration(prefixIcon: Icon(icon, size: 20), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)));
}