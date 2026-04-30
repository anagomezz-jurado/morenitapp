import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';
import '../../domain/entities/cargo.dart';
import '../providers/secretaria_provider.dart';

class CargoFormScreen extends ConsumerStatefulWidget {
  final Cargo? cargoAEditar;
  const CargoFormScreen({super.key, this.cargoAEditar});

  @override
  ConsumerState<CargoFormScreen> createState() => _CargoFormScreenState();
}

class _CargoFormScreenState extends ConsumerState<CargoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? tipoCargoId;
  int? provinciaId, localidadId, cpId, calleSeleccionadaId;

  // controllers
  late TextEditingController codCtrl,
      nomCtrl,
      inicioCtrl,
      finCtrl,
      telCtrl,
      obsCtrl,
      motivoCtrl,
      saludoCtrl,
      calleCtrl,
      numeroCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.cargoAEditar;

    codCtrl = TextEditingController(text: c?.codCargo ?? "");
    nomCtrl = TextEditingController(text: c?.nombreCargo ?? "");
    inicioCtrl = TextEditingController(
      text: c != null ? c.fechaInicio.toString().split(" ")[0] : "",
    );
    finCtrl = TextEditingController(
      text: (c != null && c.fechaFin != null)
          ? c.fechaFin!.toString().split(" ")[0]
          : "",
    );
    telCtrl = TextEditingController(text: c?.telefono ?? "");
    obsCtrl = TextEditingController(text: c?.observaciones ?? "");
    motivoCtrl = TextEditingController(text: c?.motivo ?? "");
    saludoCtrl = TextEditingController(text: c?.textoSaludo ?? "");

    calleCtrl = TextEditingController(text: c?.calleNombre ?? "");
    numeroCtrl = TextEditingController(text: c?.numero ?? "");
    pisoCtrl = TextEditingController(text: c?.piso ?? "");
    puertaCtrl = TextEditingController(text: c?.puerta ?? "");
    bloqueCtrl = TextEditingController(text: c?.bloque ?? "");
    escaleraCtrl = TextEditingController(text: c?.escalera ?? "");
    portalCtrl = TextEditingController(text: c?.portal ?? "");

    if (c != null) {
      tipoCargoId = c.tipoCargoId;
      calleSeleccionadaId = c.calleId;
    }

    Future.microtask(() async {
      ref.watch(tipoCargoProvider);
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      await ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();

      if (c != null) _inicializarUbicacionEdicion(c);
    });
  }

  void _inicializarUbicacionEdicion(Cargo c) {
    if (c.calleId == null) return;
    final calles = ref.read(callesProvider).value ?? [];

    try {
      final calle = calles.firstWhere((x) => x.id == c.calleId);
      _autocompletarDesdeCalle(calle);
    } catch (_) {
      calleCtrl.text = c.calleNombre;
    }
  }


  void _abrirSelectorCalle() async {
    final result = await showSearch(
        context: context, delegate: CalleSearchDelegate(ref: ref));
    if (result is Calle) {
      _autocompletarDesdeCalle(result);
    }
  }

  void _autocompletarDesdeCalle(Calle calle) {
    final cps = ref.read(codigosPostalesProvider).value ?? [];
    final locs = ref.read(localidadesProvider).value ?? [];

    try {
      final loc = locs.firstWhere((l) => l.id == calle.localidadId);
      final cp = cps.firstWhere((c) => c.id == calle.codPostalId);

      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;

        provinciaId = loc.codProvinciaId;
        localidadId = loc.id;
        cpId = cp.id;
      });
    } catch (_) {
      calleSeleccionadaId = calle.id;
      calleCtrl.text = calle.nombreCalle;
    }
  }


  Future<void> _pickFecha(TextEditingController ctrl) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      ctrl.text =
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    }
  }


  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      "codCargo": codCtrl.text.trim(),
      "nombreCargo": nomCtrl.text.trim(),
      "tipocargo_id": tipoCargoId,
      "fechaInicioCargo": inicioCtrl.text.trim(),
      "fechaFinCargo": finCtrl.text.trim().isEmpty ? null : finCtrl.text.trim(),
      "telefono": telCtrl.text.trim(),
      "observaciones": obsCtrl.text.trim(),
      "motivo": motivoCtrl.text.trim(),
      "textoSaludo": saludoCtrl.text.trim(),
      "calle_id": calleSeleccionadaId,
      "numero": numeroCtrl.text.trim(),
      "piso": pisoCtrl.text.trim(),
      "puerta": puertaCtrl.text.trim(),
      "bloque": bloqueCtrl.text.trim(),
      "escalera": escaleraCtrl.text.trim(),
      "portal": portalCtrl.text.trim(),
    };

    try {
      if (widget.cargoAEditar == null) {
        await ref.read(cargosProvider.notifier).guardar(data);
      } else {
        await ref
            .read(cargosProvider.notifier)
            .actualizar(int.parse(widget.cargoAEditar!.id), data);
      }
      if (mounted) context.pop();
    } catch (e) {
      _showErrorDialog(e.toString());
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorDialog(String err) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(err),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"))
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.cargoAEditar == null ? "Nuevo Cargo" : "Editar Cargo",
      onSave: _guardar,
      child: Form(
        key: _formKey,
        child: Column(children: [
          _buildCard(title: "INFORMACIÓN PRINCIPAL", children: [
            _buildRow("Código *", _textFormField(codCtrl, required: true)),
            _buildRow("Nombre *", _textFormField(nomCtrl, required: true)),
            _buildRow("Tipo *", _dropdownTipos()),
          ]),
          _buildCard(title: "FECHAS", children: [
            _buildRow(
                "Inicio *",
                _textFormField(inicioCtrl,
                    required: true,
                    readOnly: true,
                    onTap: () => _pickFecha(inicioCtrl))),
            _buildRow(
                "Fin",
                _textFormField(finCtrl,
                    readOnly: true, onTap: () => _pickFecha(finCtrl))),
          ]),
          _buildCard(title: "DIRECCIÓN", children: [
            _buildRow("Calle *", _calleSelectorField()),
            const Divider(),
            _buildRow("Provincia", _provinciaDropdown()),
            if (provinciaId != null)
              _buildRow("Localidad", _localidadDropdown()),
            if (localidadId != null) _buildRow("CP", _cpDropdown()),
            _buildRow(
                "Nº / Pta",
                Row(children: [
                  Expanded(child: _textFormField(numeroCtrl, hint: "Número")),
                  const SizedBox(width: 8),
                  Expanded(child: _textFormField(puertaCtrl, hint: "Puerta")),
                ])),
            _buildRow(
                "Piso / Esc.",
                Row(children: [
                  Expanded(child: _textFormField(pisoCtrl, hint: "Piso")),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _textFormField(escaleraCtrl, hint: "Escalera")),
                ])),
            _buildRow(
                "Bloque / Portal",
                Row(children: [
                  Expanded(child: _textFormField(bloqueCtrl, hint: "Bloque")),
                  const SizedBox(width: 8),
                  Expanded(child: _textFormField(portalCtrl, hint: "Portal")),
                ])),
          ]),
          _buildCard(title: "CONTACTO", children: [
            _buildRow("Teléfono", _textFormField(telCtrl, isNumber: true)),
          ]),
          _buildCard(title: "INFO ADICIONAL", children: [
            _buildRow("Motivo", _textFormField(motivoCtrl)),
            _buildRow("Saludo", _textFormField(saludoCtrl)),
            _buildRow(
                "Obs",
                TextFormField(
                  controller: obsCtrl,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                      hintText: "Observaciones",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                )),
          ]),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }


  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 11)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black54))),
        Expanded(flex: 5, child: child),
      ]),
    );
  }

  Widget _textFormField(TextEditingController ctrl,
      {bool required = false,
      bool isNumber = false,
      bool isEmail = false,
      String? hint,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: isNumber
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      validator: (v) =>
          (required && (v == null || v.isEmpty)) ? "Obligatorio" : null,
    );
  }

  Widget _dropdownTipos() {
    final tipos = ref.watch(tipoCargoProvider);
    return tipos.when(
      data: (list) => DropdownButtonFormField<int>(
        value: tipoCargoId,
        items: list
            .map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre)))
            .toList(),
        onChanged: (v) => setState(() => tipoCargoId = v),
        validator: (v) => v == null ? "Seleccione un tipo" : null,
        decoration:
            const InputDecoration(isDense: true, border: OutlineInputBorder()),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text("Error"),
    );
  }

  Widget _calleSelectorField() => TextFormField(
        controller: calleCtrl,
        readOnly: true,
        onTap: _abrirSelectorCalle,
        decoration: const InputDecoration(
            suffixIcon: Icon(Icons.search),
            isDense: true,
            border: OutlineInputBorder()),
        validator: (v) =>
            (v == null || v.isEmpty) ? "Seleccione una calle" : null,
      );

  Widget _provinciaDropdown() => ref.watch(provinciasProvider).when(
        data: (list) => DropdownButtonFormField<int>(
          value: provinciaId,
          items: list
              .map((p) =>
                  DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia)))
              .toList(),
          onChanged: (v) => setState(() {
            provinciaId = v;
            localidadId = null;
            cpId = null;
          }),
          decoration: const InputDecoration(
              isDense: true, border: OutlineInputBorder()),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text("Error"),
      );

  Widget _localidadDropdown() => ref.watch(localidadesProvider).when(
        data: (list) {
          final fil =
              list.where((l) => l.codProvinciaId == provinciaId).toList();
          return DropdownButtonFormField<int>(
            value: localidadId,
            items: fil
                .map((e) => DropdownMenuItem(
                    value: e.id, child: Text(e.nombreLocalidad)))
                .toList(),
            onChanged: (v) => setState(() {
              localidadId = v;
              cpId = null;
            }),
            decoration: const InputDecoration(
                isDense: true, border: OutlineInputBorder()),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text("Error"),
      );

  Widget _cpDropdown() => ref.watch(codigosPostalesProvider).when(
        data: (list) {
          final fil = list.where((c) => c.localidadId == localidadId).toList();
          return DropdownButtonFormField<int>(
            value: cpId,
            items: fil
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => cpId = v),
            decoration: const InputDecoration(
                isDense: true, border: OutlineInputBorder()),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text("Error"),
      );

  @override
  void dispose() {
    for (var c in [
      codCtrl,
      nomCtrl,
      inicioCtrl,
      finCtrl,
      telCtrl,
      obsCtrl,
      motivoCtrl,
      saludoCtrl,
      calleCtrl,
      numeroCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
