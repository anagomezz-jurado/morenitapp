import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';

class NuevoHermano extends ConsumerStatefulWidget {
  final Hermano? hermanoAEditar;
  const NuevoHermano({super.key, this.hermanoAEditar});

  @override
  ConsumerState<NuevoHermano> createState() => _NuevoHermanoState();
}

class _NuevoHermanoState extends ConsumerState<NuevoHermano> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String sexo = 'Hombre';
  String metodoPago = 'Metálico';
  bool bautizado = false;

  DateTime fechaAltaDate = DateTime.now();
  DateTime fechaNacimientoDate = DateTime.now();

  int? provinciaId, localidadId, cpId, calleSeleccionadaId;

  late TextEditingController numeroCtrl,
      codigoHermanoCtrl,
      nombreCtrl,
      apellido1Ctrl,
      apellido2Ctrl,
      dniCtrl,
      emailCtrl,
      telefonoCtrl,
      calleCtrl,
      numeroDireccionCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl,
      ibanCtrl,
      bancoCtrl,
      sucursalCtrl,
      numeroCuentaCtrl,
      observacionesCtrl;

  @override
  void initState() {
    super.initState();
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
    numeroDireccionCtrl = TextEditingController(text: h?.numero ?? '');
    pisoCtrl = TextEditingController(text: h?.piso ?? '');
    puertaCtrl = TextEditingController(text: h?.puerta ?? '');
    escaleraCtrl = TextEditingController(text: h?.escalera ?? '');
    bloqueCtrl = TextEditingController(text: h?.bloque ?? '');
    portalCtrl = TextEditingController(text: h?.portal ?? '');
    ibanCtrl = TextEditingController(text: h?.iban ?? 'ES');
    bancoCtrl = TextEditingController(text: h?.banco ?? '');
    sucursalCtrl = TextEditingController(text: h?.sucursal ?? '');
    numeroCuentaCtrl = TextEditingController(text: h?.numeroCuenta ?? '');
    observacionesCtrl = TextEditingController(text: h?.observaciones ?? '');

    numeroCtrl.addListener(_updateCodigoHermano);

    Future.microtask(() async {
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      await ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();

      if (!mounted) return;

      if (h != null) {
        setState(() {
          sexo = h.sexo.isEmpty ? 'Hombre' : h.sexo;
          metodoPago =
              (h.metodoPago == 'banco' || h.metodoPago == 'Domiciliado')
                  ? 'Domiciliado'
                  : 'Metálico';
          bautizado = h.bautizado;
          calleSeleccionadaId = h.calleId;

          if (h.fechaAlta.isNotEmpty) {
            fechaAltaDate = DateTime.tryParse(h.fechaAlta) ?? DateTime.now();
          }
          if (h.fechaNacimiento.isNotEmpty) {
            fechaNacimientoDate =
                DateTime.tryParse(h.fechaNacimiento) ?? DateTime.now();
          }
        });
        _inicializarUbicacionEdicion(h);
      } else {
        _cargarSiguienteNumero();
      }
    });
  }

  void _abrirSelectorCallePrincipal() async {
    final result = await showSearch(
        context: context, delegate: CalleSearchDelegate(ref: ref));
    if (result == null) return;
    if (result is Calle) {
      _autocompletarDesdeCalle(result);
    } else if (result is String && result.isNotEmpty) {
      _dialogoCrearCalleRapido(result);
    }
  }

  void _autocompletarDesdeCalle(Calle calle) {
    final listaCPs = ref.read(codigosPostalesProvider).value ?? [];
    final listaLocs = ref.read(localidadesProvider).value ?? [];
    try {
      final loc = listaLocs.firstWhere((l) => l.id == calle.localidadId);
      final cp = listaCPs.firstWhere((c) => c.id == calle.codPostalId);
      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;
        provinciaId = loc.codProvinciaId;
        localidadId = loc.id;
        cpId = cp.id;
      });
    } catch (_) {
      setState(() {
        calleSeleccionadaId = calle.id;
        calleCtrl.text = calle.nombreCalle;
      });
    }
  }

  void _inicializarUbicacionEdicion(Hermano h) {
    if (h.calleId == null) return;
    final calles = ref.read(callesProvider).value ?? [];
    try {
      final calle = calles.firstWhere((c) => c.id == h.calleId);
      _autocompletarDesdeCalle(calle);
    } catch (_) {
      setState(() {
        calleCtrl.text = h.calleNombre;
      });
    }
  }

  void _dialogoCrearCalleRapido(String nombreSugerido) {
    final nombreCtrlCrear = TextEditingController(text: nombreSugerido);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva Calle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textFormField(nombreCtrlCrear, hint: 'Nombre', required: true),
              const SizedBox(height: 10),
              _provinciaDropdown(
                  onChanged: (v) => setDialogState(() => provinciaId = v)),
              if (provinciaId != null)
                _localidadDropdown(
                    onChanged: (v) => setDialogState(() => localidadId = v)),
              if (localidadId != null)
                _cpDropdown(onChanged: (v) => setDialogState(() => cpId = v)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: (localidadId == null || cpId == null)
                  ? null
                  : () async {
                      await ref.read(callesProvider.notifier).agregarCalle(
                          nombreCtrlCrear.text.trim(), localidadId!, cpId!);
                      final nueva = ref.read(callesProvider).value?.last;
                      if (nueva != null) _autocompletarDesdeCalle(nueva);
                      if (mounted) Navigator.pop(context);
                    },
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCodigoHermano() {
    final letraSexo = sexo == 'Hombre' ? 'H' : 'M';
    if (numeroCtrl.text.isNotEmpty) {
      setState(() => codigoHermanoCtrl.text = "${numeroCtrl.text}-$letraSexo");
    }
  }

  void _cargarSiguienteNumero() {
    ref.read(hermanosListadoProvider).whenData((hermanos) {
      if (hermanos.isNotEmpty && widget.hermanoAEditar == null) {
        final maxNum = hermanos
            .map((h) => h.numeroHermano)
            .reduce((a, b) => a > b ? a : b);
        numeroCtrl.text = (maxNum + 1).toString();
        _updateCodigoHermano();
      }
    });
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> datosOdoo = {
        "numero_hermano": int.tryParse(numeroCtrl.text) ?? 0,
        "nombre": nombreCtrl.text.trim(),
        "apellido1": apellido1Ctrl.text.trim(),
        "apellido2": apellido2Ctrl.text.trim(),
        "dni": dniCtrl.text.trim().toUpperCase(),
        "sexo": sexo,
        "fecha_alta": formatDate(fechaAltaDate),
        "fecha_nacimiento": formatDate(fechaNacimientoDate),
        "metodo_pago": (metodoPago == 'Domiciliado') ? 'banco' : 'metalico',
        "bautizado": bautizado,
        "calle_id": calleSeleccionadaId,
        "numero": numeroDireccionCtrl.text.trim(),
        "piso": pisoCtrl.text.trim(),
        "puerta": puertaCtrl.text.trim(),
        "bloque": bloqueCtrl.text.trim(),
        "escalera": escaleraCtrl.text.trim(),
        "portal": portalCtrl.text.trim(),
        "observaciones": observacionesCtrl.text.trim().isEmpty
            ? false
            : observacionesCtrl.text.trim(),
        "iban": (metodoPago == 'Domiciliado')
            ? ibanCtrl.text.trim().toUpperCase()
            : "",
        "banco": (metodoPago == 'Domiciliado') ? bancoCtrl.text.trim() : "",
        "sucursal":
            (metodoPago == 'Domiciliado') ? sucursalCtrl.text.trim() : "",
        "numero_cuenta":
            (metodoPago == 'Domiciliado') ? numeroCuentaCtrl.text.trim() : "",
        "email": emailCtrl.text.trim(),
        "telefono": telefonoCtrl.text.trim(),
        "estado": widget.hermanoAEditar?.estado ?? "activo",
      };

      if (widget.hermanoAEditar == null) {
        await ref
            .read(hermanosListadoProvider.notifier)
            .createHermano(Hermano.fromJson(datosOdoo));
      } else {
        await ref
            .read(hermanosListadoProvider.notifier)
            .updateHermano(widget.hermanoAEditar!.id!, datosOdoo);
      }

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  String formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      isLoading: _isLoading,
      title:
          widget.hermanoAEditar != null ? 'Ficha de Hermano' : 'Nuevo Hermano',
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(title: 'DATOS DE REGISTRO', children: [
              _buildRow('Número',
                  _textFormField(numeroCtrl, isNumber: true, required: true)),
              _buildRow(
                  'Sexo',
                  _dropdownField(sexo, ['Hombre', 'Mujer'], (v) {
                    setState(() => sexo = v!);
                    _updateCodigoHermano();
                  })),
              _buildRow(
                  'Código', _textFormField(codigoHermanoCtrl, readOnly: true)),
              _buildRow(
                  'Fecha Alta',
                  _datePickerField(
                      fechaAltaDate, (d) => setState(() => fechaAltaDate = d))),
              _buildRow(
                  '¿Bautizado?',
                  Switch(
                      value: bautizado,
                      onChanged: (v) => setState(() => bautizado = v))),
              _buildRow(
                  'Pago',
                  _dropdownField(metodoPago, ['Metálico', 'Domiciliado'],
                      (v) => setState(() => metodoPago = v!))),
              if (metodoPago == 'Domiciliado') ...[
                const Divider(),
                _buildRow(
                    'IBAN / Banco',
                    Row(children: [
                      Expanded(
                          flex: 2,
                          child: _textFormField(ibanCtrl,
                              hint: 'IBAN', required: true)),
                      const SizedBox(width: 8),
                      Expanded(
                          flex: 3,
                          child: _textFormField(bancoCtrl,
                              hint: 'Banco', required: true)),
                    ])),
                _buildRow(
                    'Sucursal / Cuenta',
                    Row(children: [
                      Expanded(
                          flex: 2,
                          child: _textFormField(sucursalCtrl,
                              hint: 'Sucursal', required: true)),
                      const SizedBox(width: 8),
                      Expanded(
                          flex: 5,
                          child: _textFormField(numeroCuentaCtrl,
                              hint: 'Nº Cuenta', required: true)),
                    ])),
              ]
            ]),
            _buildCard(title: 'DATOS PERSONALES', children: [
              _buildRow('Nombre', _textFormField(nombreCtrl, required: true)),
              _buildRow(
                  'Apellido 1', _textFormField(apellido1Ctrl, required: true)),
              _buildRow('Apellido 2', _textFormField(apellido2Ctrl)),
              _buildRow(
                  'Fecha Nac.',
                  _datePickerField(fechaNacimientoDate,
                      (d) => setState(() => fechaNacimientoDate = d))),
              _buildRow('DNI', _textFormField(dniCtrl, required: true)),
              _buildRow('Email', _textFormField(emailCtrl, isEmail: true)),
              _buildRow(
                  'Teléfono', _textFormField(telefonoCtrl, isNumber: true)),
            ]),
            _buildCard(title: 'UBICACIÓN PRINCIPAL', children: [
              _buildRow('Calle', _calleSelectorField()),
              const Divider(),
              _buildRow('Provincia', _provinciaDropdown()),
              if (provinciaId != null)
                _buildRow('Localidad', _localidadDropdown()),
              if (localidadId != null) _buildRow('CP', _cpDropdown()),
              _buildRow(
                  'Nº / Pta',
                  Row(children: [
                    Expanded(
                        child: _textFormField(numeroDireccionCtrl,
                            hint: 'Número')),
                    const SizedBox(width: 8),
                    Expanded(child: _textFormField(puertaCtrl, hint: 'Puerta')),
                  ])),
              _buildRow(
                  'Piso / Esc.',
                  Row(children: [
                    Expanded(child: _textFormField(pisoCtrl, hint: 'Piso')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _textFormField(escaleraCtrl, hint: 'Escalera')),
                  ])),
              _buildRow(
                  'Bloque / Portal',
                  Row(children: [
                    Expanded(child: _textFormField(bloqueCtrl, hint: 'Bloque')),
                    const SizedBox(width: 8),
                    Expanded(child: _textFormField(portalCtrl, hint: 'Portal')),
                  ])),
            ]),
            _buildCard(title: 'OBSERVACIONES', children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: observacionesCtrl,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Notas adicionales...',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 11)),
          const Divider(),
          ...children
        ]),
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
      bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: isNumber
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: readOnly ? Colors.grey[100] : null,
          filled: readOnly),
      validator: (v) =>
          (required && (v == null || v.isEmpty)) ? 'Obligatorio' : null,
    );
  }

  Widget _dropdownField(
      String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _datePickerField(DateTime date, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100));
        if (d != null) onPicked(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        child: Text("${date.day}/${date.month}/${date.year}"),
      ),
    );
  }

  Widget _calleSelectorField() {
    return TextFormField(
      controller: calleCtrl,
      readOnly: true,
      onTap: _abrirSelectorCallePrincipal,
      decoration: InputDecoration(
          suffixIcon: const Icon(Icons.search),
          hintText: 'Buscar calle...',
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
    );
  }

  Widget _provinciaDropdown({Function(int?)? onChanged}) => ref
      .watch(provinciasProvider)
      .when(
        data: (list) => DropdownButtonFormField<int>(
          value: provinciaId,
          items: list
              .map((p) =>
                  DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia)))
              .toList(),
          onChanged: (v) {
            setState(() {
              provinciaId = v;
              localidadId = null;
              cpId = null;
            });
            if (onChanged != null) onChanged(v);
          },
          decoration: const InputDecoration(
              labelText: 'Provincia',
              isDense: true,
              border: OutlineInputBorder()),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  Widget _localidadDropdown({Function(int?)? onChanged}) =>
      ref.watch(localidadesProvider).when(
            data: (list) {
              final filtradas =
                  list.where((l) => l.codProvinciaId == provinciaId).toList();
              return DropdownButtonFormField<int>(
                value: filtradas.any((l) => l.id == localidadId)
                    ? localidadId
                    : null,
                items: filtradas
                    .map((l) => DropdownMenuItem(
                        value: l.id,
                        child: Text(l.nombreLocalidad,
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    localidadId = v;
                    cpId = null;
                  });
                  if (onChanged != null) onChanged(v);
                },
                decoration: const InputDecoration(
                    labelText: 'Localidad',
                    isDense: true,
                    border: OutlineInputBorder()),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error'),
          );

  Widget _cpDropdown({Function(int?)? onChanged}) => ref
      .watch(codigosPostalesProvider)
      .when(
        data: (list) {
          final filtrados =
              list.where((c) => c.localidadId == localidadId).toList();
          return DropdownButtonFormField<int>(
            value: filtrados.any((c) => c.id == cpId) ? cpId : null,
            items: filtrados
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) {
              setState(() => cpId = v);
              if (onChanged != null) onChanged(v);
            },
            decoration: const InputDecoration(
                labelText: 'CP', isDense: true, border: OutlineInputBorder()),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

  @override
  void dispose() {
    numeroCtrl.removeListener(_updateCodigoHermano);
    final ctrls = [
      numeroCtrl,
      codigoHermanoCtrl,
      nombreCtrl,
      apellido1Ctrl,
      apellido2Ctrl,
      dniCtrl,
      emailCtrl,
      telefonoCtrl,
      calleCtrl,
      numeroDireccionCtrl,
      pisoCtrl,
      puertaCtrl,
      bloqueCtrl,
      escaleraCtrl,
      portalCtrl,
      ibanCtrl,
      bancoCtrl,
      sucursalCtrl,
      numeroCuentaCtrl,
      observacionesCtrl,
    ];
    for (var c in ctrls) {
      c.dispose();
    }
    super.dispose();
  }
}
