import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_wraapper.dart';

class NuevoHermano extends ConsumerStatefulWidget {
  final Hermano? hermanoAEditar;
  const NuevoHermano({super.key, this.hermanoAEditar});

  @override
  ConsumerState<NuevoHermano> createState() => _NuevoHermanoState();
}

class _NuevoHermanoState extends ConsumerState<NuevoHermano> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Variables de estado
  String sexo = 'Hombre';
  String metodoPago = 'Metálico';
  bool esResponsable = true;
  DateTime fechaAltaDate = DateTime.now();
  DateTime? fechaNacimientoDate;

  // Lógica de Bajas
  bool esBaja = false;
  DateTime? fechaBajaDate;
  final motivoBajaCtrl = TextEditingController();

  // Ubicación IDs
  int? provinciaId, localidadId, cpId, calleSeleccionadaId;

  late TextEditingController numeroCtrl, codigoHermanoCtrl, nombreCtrl, apellido1Ctrl, apellido2Ctrl,
      dniCtrl, emailCtrl, telefonoCtrl, calleCtrl, pisoCtrl, puertaCtrl, ibanCtrl;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
    ref.read(localidadesProvider.notifier).cargarLocalidades();
    ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();
    ref.read(callesProvider.notifier).cargarCalles();
  });
    final h = widget.hermanoAEditar;

    numeroCtrl = TextEditingController(text: h?.numeroHermano.toString() ?? '');
    codigoHermanoCtrl = TextEditingController(text: h?.codigoHermano ?? '');
    nombreCtrl = TextEditingController(text: h?.nombre ?? '');
    apellido1Ctrl = TextEditingController(text: h?.apellido1 ?? '');
    apellido2Ctrl = TextEditingController(text: h?.apellido2 ?? '');
    dniCtrl = TextEditingController(text: h?.dni ?? '');
    emailCtrl = TextEditingController(text: h?.email ?? '');
    telefonoCtrl = TextEditingController(text: h?.telefono ?? '');
    calleCtrl = TextEditingController(text: h?.calleNombre ?? '');
    pisoCtrl = TextEditingController(text: h?.piso ?? '');
    puertaCtrl = TextEditingController(text: h?.puerta ?? '');
    ibanCtrl = TextEditingController(text: h?.iban ?? 'ES');

    numeroCtrl.addListener(_updateCodigoHermano);

    if (h != null) {
      sexo = h.sexo;
      metodoPago = (h.metodoPago == 'banco' || h.metodoPago == 'Domiciliado') ? 'Domiciliado' : 'Metálico';
      esResponsable = h.responsable;
      calleSeleccionadaId = h.calleId;
      esBaja = h.estado == 'baja';
      _inicializarUbicacionEdicion(h);
    } else {
      _cargarSiguienteNumero();
    }
  }

  void _inicializarUbicacionEdicion(Hermano h) {
    if (h.calleId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final calles = ref.read(callesProvider).value ?? [];
      final calle = calles.firstWhere((c) => c.id == h.calleId, 
        orElse: () => Calle(id: 0, nombreCalle: '', localidadId: 0, codPostalId: 0));
      if (calle.id != 0) _autocompletarDesdeCalle(calle);
    });
  }

  // --- LÓGICA DE UBICACIÓN ---

  void _abrirSelectorCalle() async {
    final resultado = await showSearch(
      context: context,
      delegate: CalleSearchDelegate(ref: ref),
    );

    if (resultado == null) return;

    if (resultado is Calle) {
      _autocompletarDesdeCalle(resultado);
    } else if (resultado is String) {
      _dialogoCrearCalleRapido(resultado);
    }
  }

  void _autocompletarDesdeCalle(Calle calle) {
    final listaCPs = ref.read(codigosPostalesProvider).value ?? [];
    final listaLocs = ref.read(localidadesProvider).value ?? [];

    try {
      final cp = listaCPs.firstWhere((c) => c.id == calle.codPostalId);
      final loc = listaLocs.firstWhere((l) => l.id == calle.localidadId);

      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;
        
        // AUTOCOMPLETADO AUTOMÁTICO DE DROPDOWNS
        provinciaId = loc.codProvinciaId;
        localidadId = loc.id;
        cpId = cp.id;
      });
    } catch (e) {
      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;
      });
    }
  }

  void _dialogoCrearCalleRapido(String nombreSugerido) {
    final nombreCtrlCrear = TextEditingController(text: nombreSugerido);
    // Reiniciamos selecciones temporales para el diálogo si fuera necesario
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Añadir Nueva Calle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textFormField(nombreCtrlCrear, hint: 'Nombre de la calle'),
                const SizedBox(height: 15),
                _provinciaDropdown(onChanged: (v) => setDialogState(() => provinciaId = v)),
                const SizedBox(height: 8),
                if (provinciaId != null) 
                  _localidadDropdown(onChanged: (v) => setDialogState(() => localidadId = v)),
                const SizedBox(height: 8),
                if (localidadId != null) 
                  _cpDropdown(onChanged: (v) => setDialogState(() => cpId = v)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: (provinciaId == null || localidadId == null || cpId == null) 
                ? null 
                : () async {
                  try {
                    await ref.read(callesProvider.notifier).agregarCalle(
                      nombreCtrlCrear.text.trim(), localidadId!, cpId!);
                    
                    // Obtenemos la calle recién creada para autocompletar el formulario principal
                    final nuevaCalle = ref.read(callesProvider).value?.last;
                    if (nuevaCalle != null) _autocompletarDesdeCalle(nuevaCalle);
                    
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
              },
              child: const Text('GUARDAR Y SELECCIONAR'),
            )
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE APOYO ---

  void _updateCodigoHermano() {
    final letraSexo = sexo == 'Hombre' ? 'H' : 'M';
    if (numeroCtrl.text.isNotEmpty) {
      setState(() { codigoHermanoCtrl.text = "${numeroCtrl.text}-$letraSexo"; });
    }
  }

  void _cargarSiguienteNumero() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hermanosListadoProvider).whenData((hermanos) {
        if (hermanos.isNotEmpty && widget.hermanoAEditar == null) {
          final maxNum = hermanos.map((h) => h.numeroHermano).reduce((a, b) => a > b ? a : b);
          numeroCtrl.text = (maxNum + 1).toString();
          _updateCodigoHermano();
        }
      });
    });
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final datos = {
      "numero_hermano": int.tryParse(numeroCtrl.text) ?? 0,
      "codigo_hermano": codigoHermanoCtrl.text.trim(),
      "nombre": nombreCtrl.text.trim(),
      "apellido1": apellido1Ctrl.text.trim(),
      "apellido2": apellido2Ctrl.text.trim(),
      "dni": dniCtrl.text.trim().toUpperCase(),
      "sexo": sexo,
      "fecha_alta": formatDate(fechaAltaDate),
      "fecha_nacimiento": fechaNacimientoDate != null ? formatDate(fechaNacimientoDate!) : "false",
      "metodo_pago": (metodoPago == 'Domiciliado') ? 'banco' : 'metalico',
      "responsable": esResponsable,
      "calle_id": calleSeleccionadaId,
      "piso": pisoCtrl.text.trim(),
      "puerta": puertaCtrl.text.trim(),
      "iban": (metodoPago == 'Domiciliado') ? ibanCtrl.text.trim() : "",
      "email": emailCtrl.text.trim(),
      "telefono": telefonoCtrl.text.trim(),
      "estado": esBaja ? "baja" : "activo",
      "fecha_baja": esBaja && fechaBajaDate != null ? formatDate(fechaBajaDate!) : "false",
      "motivo_baja": esBaja ? motivoBajaCtrl.text.trim() : "",
    };

    try {
      if (widget.hermanoAEditar == null) {
        await ref.read(hermanosListadoProvider.notifier).createHermano(Hermano.fromJson(datos));
      } else {
        await ref.read(hermanosListadoProvider.notifier).updateHermano(widget.hermanoAEditar!.id!, datos);
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String formatDate(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // --- WIDGETS DE UI ---

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).primaryColor;

    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.hermanoAEditar != null ? 'Ficha de Hermano' : 'Nuevo Hermano',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(title: 'DATOS DE REGISTRO', children: [
              _buildRow('Número', _textFormField(numeroCtrl, isNumber: true)),
              _buildRow('Código', _textFormField(codigoHermanoCtrl, readOnly: true)),
              _buildRow('Fecha Alta', _datePickerField(fechaAltaDate, (d) => setState(() => fechaAltaDate = d))),
              _buildRow('Responsable Calle', Switch(value: esResponsable, onChanged: (val) => setState(() => esResponsable = val))),
              _buildRow('Pago', _dropdownField(metodoPago, ['Metálico', 'Domiciliado'], (v) => setState(() => metodoPago = v!))),
              if (metodoPago == 'Domiciliado') _buildRow('IBAN', _textFormField(ibanCtrl)),
            ]),

            _buildCard(title: 'DATOS PERSONALES', children: [
              _buildRow('Nombre', _textFormField(nombreCtrl, required: true)),
              _buildRow('Apellido 1', _textFormField(apellido1Ctrl, required: true)),
              _buildRow('Apellido 2', _textFormField(apellido2Ctrl)),
              _buildRow('DNI', _textFormField(dniCtrl, required: true)),
              _buildRow('Sexo', _dropdownField(sexo, ['Hombre', 'Mujer'], (v) {
                setState(() => sexo = v!);
                _updateCodigoHermano();
              })),
              _buildRow('Teléfono', _textFormField(telefonoCtrl, required: true)),
            ]),

            _buildCard(title: 'UBICACIÓN', children: [
              _buildRow('Calle (Buscador)', _calleSelectorField(color)),
              const Divider(),
              _buildRow('Provincia', _provinciaDropdown()),
              if (provinciaId != null) _buildRow('Localidad', _localidadDropdown()),
              if (localidadId != null) _buildRow('CP', _cpDropdown()),
              _buildRow('Piso/Puerta', Row(
                children: [
                  Expanded(child: _textFormField(pisoCtrl, hint: 'Piso')),
                  const SizedBox(width: 10),
                  Expanded(child: _textFormField(puertaCtrl, hint: 'Puerta')),
                ],
              )),
            ]),
            
            const SizedBox(height: 24),
            _buildSubmitButton(color, widget.hermanoAEditar != null),
          ],
        ),
      ),
    );
  }

  // --- DROPDOWNS Y COMPONENTES ---

  Widget _provinciaDropdown({Function(int?)? onChanged}) => ref.watch(provinciasProvider).when(
    data: (list) => DropdownButtonFormField<int>(
      value: provinciaId,
      items: list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
      onChanged: (v) {
        setState(() { provinciaId = v; localidadId = null; cpId = null; calleCtrl.clear(); });
        if (onChanged != null) onChanged(v);
      },
      decoration: const InputDecoration(labelText: 'Provincia', isDense: true, border: OutlineInputBorder()),
    ),
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error'),
  );

  Widget _localidadDropdown({Function(int?)? onChanged}) => ref.watch(localidadesProvider).when(
    data: (list) => DropdownButtonFormField<int>(
      value: localidadId,
      items: list.where((l) => l.codProvinciaId == provinciaId).map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
      onChanged: (v) {
        setState(() { localidadId = v; cpId = null; calleCtrl.clear(); });
        if (onChanged != null) onChanged(v);
      },
      decoration: const InputDecoration(labelText: 'Localidad', isDense: true, border: OutlineInputBorder()),
    ),
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error'),
  );

  Widget _cpDropdown({Function(int?)? onChanged}) => ref.watch(codigosPostalesProvider).when(
    data: (list) => DropdownButtonFormField<int>(
      value: cpId,
      items: list.where((c) => c.localidadId == localidadId).map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
      onChanged: (v) {
        setState(() { cpId = v; calleCtrl.clear(); });
        if (onChanged != null) onChanged(v);
      },
      decoration: const InputDecoration(labelText: 'C.P.', isDense: true, border: OutlineInputBorder()),
    ),
    loading: () => const LinearProgressIndicator(),
    error: (_, __) => const Text('Error'),
  );

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 11)),
          const Divider(), ...children
        ]),
      ),
    );
  }

  Widget _buildRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54))),
        Expanded(flex: 5, child: child),
      ]),
    );
  }

  Widget _textFormField(TextEditingController ctrl, {bool required = false, bool isNumber = false, String? hint, bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => (required && (val == null || val.isEmpty)) ? 'Obligatorio' : null,
      decoration: InputDecoration(hintText: hint, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _dropdownField(String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged, decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _datePickerField(DateTime? date, Function(DateTime) onPicked) {
    return OutlinedButton.icon(
      onPressed: () async {
        final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
        if (d != null) onPicked(d);
      },
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(date == null ? 'Seleccionar' : "${date.day}/${date.month}/${date.year}"),
    );
  }

  Widget _calleSelectorField(Color color) {
    return TextFormField(
      controller: calleCtrl, readOnly: true, onTap: _abrirSelectorCalle,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.search), 
        hintText: 'Toca para buscar calle...', 
        isDense: true, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: color))
      ),
    );
  }

  Widget _buildSubmitButton(Color color, bool esEdicion) {
    return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: _isLoading ? null : _onSave,
      child: Text(esEdicion ? 'GUARDAR CAMBIOS' : 'REGISTRAR', style: const TextStyle(color: Colors.white)),
    ));
  }

  @override
  void dispose() {
    numeroCtrl.removeListener(_updateCodigoHermano);
    motivoBajaCtrl.dispose(); numeroCtrl.dispose(); codigoHermanoCtrl.dispose(); 
    nombreCtrl.dispose(); apellido1Ctrl.dispose(); apellido2Ctrl.dispose(); 
    dniCtrl.dispose(); emailCtrl.dispose(); telefonoCtrl.dispose(); 
    calleCtrl.dispose(); pisoCtrl.dispose(); puertaCtrl.dispose(); ibanCtrl.dispose();
    super.dispose();
  }
}