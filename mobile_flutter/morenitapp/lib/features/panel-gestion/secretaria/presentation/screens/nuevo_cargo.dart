import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/screens/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';

import '../providers/secretaria_provider.dart'; 
import '../../domain/entities/cargo.dart';

class CargoFormScreen extends ConsumerStatefulWidget {
  final Cargo? cargoAEditar;
  const CargoFormScreen({super.key, this.cargoAEditar});

  @override
  ConsumerState<CargoFormScreen> createState() => _CargoFormScreenState();
}

class _CargoFormScreenState extends ConsumerState<CargoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? tipocargoId;
  int? provinciaId, localidadId, direccionId;

  late TextEditingController codCtrl, nomCtrl, inicioCtrl, finCtrl, 
      telCtrl, obsCtrl, motivoCtrl, saludoCtrl, calleCtrl, puertaCtrl, pisoCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.cargoAEditar;
    
    codCtrl = TextEditingController(text: c?.codCargo ?? '');
    nomCtrl = TextEditingController(text: c?.nombreCargo ?? '');
    inicioCtrl = TextEditingController(text: c?.fechaInicio.toString().split(' ')[0] ?? '');
    finCtrl = TextEditingController(text: (c?.fechaFin != null) ? c!.fechaFin.toString().split(' ')[0] : '');
    
    calleCtrl = TextEditingController(text: c?.direccionName ?? ''); 
    puertaCtrl = TextEditingController(text: c?.puerta ?? '');
    pisoCtrl = TextEditingController(text: c?.piso ?? '');
    telCtrl = TextEditingController(text: c?.telefono ?? '');
    obsCtrl = TextEditingController(text: c?.observaciones ?? '');
    motivoCtrl = TextEditingController(text: c?.motivo ?? '');
    saludoCtrl = TextEditingController(text: c?.textoSaludo ?? '');

    // Inicialización de IDs para edición
    tipocargoId = c?.tipoCargoId;
    localidadId = c?.localidadId;
    direccionId = c?.direccionId;

    _inicializarDatos();
  }

  void _inicializarDatos() {
    Future.microtask(() async {
      ref.invalidate(tipoCargoProvider); 
      await ref.read(tipoCargoProvider.future);
      
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      
      if (localidadId != null) {
        final locs = ref.read(localidadesProvider).value;
        final loc = locs?.where((l) => l.id == localidadId).firstOrNull;
        if (loc != null) {
          setState(() {
            provinciaId = loc.codProvinciaId;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    codCtrl.dispose(); nomCtrl.dispose(); inicioCtrl.dispose(); finCtrl.dispose();
    telCtrl.dispose(); obsCtrl.dispose(); motivoCtrl.dispose(); saludoCtrl.dispose();
    calleCtrl.dispose(); puertaCtrl.dispose(); pisoCtrl.dispose();
    super.dispose();
  }

  void _abrirSelectorCalle() async {
    final resultado = await showSearch(
      context: context, 
      delegate: CalleSearchDelegate(ref: ref)
    );
    
    if (resultado is Calle) {
      final locs = ref.read(localidadesProvider).value ?? [];
      final loc = locs.where((l) => l.id == resultado.localidadId).firstOrNull;
      
      setState(() {
        calleCtrl.text = resultado.nombreCalle; 
        direccionId = resultado.id; // Guardamos el ID para Odoo
        localidadId = resultado.localidadId;
        provinciaId = loc?.codProvinciaId;
      });
    }
  }

  Future<void> _seleccionarFecha(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() => controller.text = picked.toString().split(' ')[0]);
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (tipocargoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un Tipo de Cargo')));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'codCargo': codCtrl.text.trim(),
      'nombreCargo': nomCtrl.text.trim(),
      'tipocargo_id': tipocargoId,
      'fechaInicioCargo': inicioCtrl.text,
      'fechaFinCargo': finCtrl.text.isEmpty ? null : finCtrl.text,
      'direccion': direccionId, 
      'puerta': puertaCtrl.text.trim(),
      'piso': pisoCtrl.text.trim(),
      'localidad_id': localidadId,
      'telefono': telCtrl.text.trim(),
      'observaciones': obsCtrl.text.trim(),
      'motivo': motivoCtrl.text.trim(),
      'textoSaludo': saludoCtrl.text.trim(),
    };

    if (widget.cargoAEditar != null) {
      data['id'] = int.tryParse(widget.cargoAEditar!.id);
    }

    try {
      await ref.read(cargosProvider.notifier).guardar(data);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      title: widget.cargoAEditar == null ? 'Nuevo Cargo' : 'Editar Cargo',
      isLoading: _isLoading,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(title: 'DATOS PRINCIPALES', children: [
                _buildRow('Código *', _textFormField(codCtrl, required: true)),
                _buildRow('Nombre *', _textFormField(nomCtrl, required: true)),
                _buildRow('Tipo Cargo *', _tipoCargoDropdown()),
              ]),

              _buildCard(title: 'VIGENCIA', children: [
                _buildRow('Inicio *', _textFormField(inicioCtrl, required: true, readOnly: true, 
                  suffixIcon: Icons.calendar_month, onTap: () => _seleccionarFecha(context, inicioCtrl))),
                _buildRow('Fin', _textFormField(finCtrl, readOnly: true, 
                  suffixIcon: Icons.calendar_month, onTap: () => _seleccionarFecha(context, finCtrl))),
              ]),

              _buildCard(title: 'LOCALIZACIÓN', children: [
                _buildRow('Calle *', _calleSelectorField()),
                _buildRow('Provincia', _provinciaDropdown()),
                if (provinciaId != null) _buildRow('Localidad', _localidadDropdown()),
                _buildRow('Piso/Pta', Row(children: [
                    Expanded(child: _textFormField(pisoCtrl, hint: 'Piso')),
                    const SizedBox(width: 10),
                    Expanded(child: _textFormField(puertaCtrl, hint: 'Pta.')),
                ])),
                _buildRow('Teléfono', _textFormField(telCtrl, isNumber: true)),
              ]),

              _buildCard(title: 'INFORMACIÓN ADICIONAL', children: [
                _buildRow('Motivo', _textFormField(motivoCtrl)),
                _buildRow('Saludo', _textFormField(saludoCtrl)),
                _buildRow('Obs.', _textFormField(obsCtrl, maxLines: 2)),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _tipoCargoDropdown() {
    final tiposAsync = ref.watch(tipoCargoProvider);
    return tiposAsync.when(
      data: (list) {
        final int? currentSelection = list.any((t) => (int.tryParse(t['id'].toString()) == tipocargoId)) 
            ? tipocargoId 
            : null;

        return DropdownButtonFormField<int>(
          value: currentSelection,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true, 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Seleccione tipo'
          ),
          items: list.map((t) {
            final id = int.tryParse(t['id'].toString()) ?? 0;
            final nombre = t['nombreCargo'] ?? t['nombre'] ?? t['name'] ?? 'Tipo $id';
            return DropdownMenuItem<int>(
              value: id, 
              child: Text(nombre),
            );
          }).toList(),
          onChanged: (v) => setState(() => tipocargoId = v),
          validator: (v) => v == null ? 'Seleccione tipo' : null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error al cargar tipos'),
    );
  }

  Widget _provinciaDropdown() => ref.watch(provinciasProvider).when(
    data: (list) => DropdownButtonFormField<int>(
      value: provinciaId,
      isExpanded: true,
      items: list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
      onChanged: (v) => setState(() { provinciaId = v; localidadId = null; }),
      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
    ),
    loading: () => const SizedBox(),
    error: (_, __) => const SizedBox(),
  );

  Widget _localidadDropdown() => ref.watch(localidadesProvider).when(
    data: (list) {
      final filtradas = list.where((l) => l.codProvinciaId == provinciaId).toList();
      return DropdownButtonFormField<int>(
        value: filtradas.any((l) => l.id == localidadId) ? localidadId : null,
        isExpanded: true,
        items: filtradas.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
        onChanged: (v) => setState(() => localidadId = v),
        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
        validator: (v) => v == null ? 'Requerido' : null,
      );
    },
    loading: () => const SizedBox(),
    error: (_, __) => const SizedBox(),
  );

  Widget _calleSelectorField() => TextFormField(
    controller: calleCtrl, 
    readOnly: true, 
    onTap: _abrirSelectorCalle,
    validator: (v) => (direccionId == null) ? 'Requerido' : null,
    decoration: InputDecoration(
      suffixIcon: const Icon(Icons.search, size: 20), 
      isDense: true, 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: 'Seleccionar calle...'
    ),
  );

  Widget _buildCard({required String title, required List<Widget> children}) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey)),
        const Divider(),
        ...children
      ]),
    ),
  );

  Widget _buildRow(String label, Widget child) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13))),
      Expanded(flex: 5, child: child),
    ]),
  );

  Widget _textFormField(TextEditingController ctrl, {bool required = false, bool readOnly = false, bool isNumber = false, String? hint, int maxLines = 1, IconData? suffixIcon, VoidCallback? onTap}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => (required && (v == null || v.trim().isEmpty)) ? 'Requerido' : null,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}