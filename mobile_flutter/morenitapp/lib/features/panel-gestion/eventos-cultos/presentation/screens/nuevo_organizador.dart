import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:morenitapp/shared/widgets/calle_search_delegate.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';

import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/organizador.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';

import 'package:morenitapp/features/panel-gestion/ubicaciones/domain/entities/calle.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/providers/ubicaciones_provider.dart';


class NuevoOrganizador extends ConsumerStatefulWidget {
  final Organizador? organizadorAEditar;
  const NuevoOrganizador({super.key, this.organizadorAEditar});

  @override
  ConsumerState<NuevoOrganizador> createState() => _NuevoOrganizadorState();
}

class _NuevoOrganizadorState extends ConsumerState<NuevoOrganizador> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Ubicación IDs
  int? provinciaId, localidadId, cpId, calleSeleccionadaId;

  // Controladores
  late TextEditingController cifCtrl,
      nombreCtrl,
      telefonoCtrl,
      emailCtrl,
      calleCtrl,
      numeroCtrl,
      pisoCtrl,
      puertaCtrl,
      escaleraCtrl,
      bloqueCtrl,
      portalCtrl;

  // Imágenes Base64
  String? logoB64, firmaPresiB64, firmaSecB64, firmaTesB64;

  @override
  void initState() {
    super.initState();
    final o = widget.organizadorAEditar;

    cifCtrl = TextEditingController(text: o?.cif ?? '');
    nombreCtrl = TextEditingController(text: o?.nombre ?? '');
    telefonoCtrl = TextEditingController(text: o?.telefono ?? '');
    emailCtrl = TextEditingController(text: o?.email ?? '');

    calleCtrl = TextEditingController(text: o?.calleName ?? '');
    numeroCtrl = TextEditingController(text: o?.numero ?? '');
    pisoCtrl = TextEditingController(text: o?.piso ?? '');
    puertaCtrl = TextEditingController(text: o?.puerta ?? '');
    escaleraCtrl = TextEditingController(text: o?.escalera ?? '');
    bloqueCtrl = TextEditingController(text: o?.bloque ?? '');
    portalCtrl = TextEditingController(text: o?.portal ?? '');

    logoB64 = o?.logo;
    firmaPresiB64 = o?.firmaPresidente;
    firmaSecB64 = o?.firmaSecretario;
    firmaTesB64 = o?.firmaTesorero;

    Future.microtask(() async {
      await ref.read(provinciasProvider.notifier).cargarProvincias();
      await ref.read(localidadesProvider.notifier).cargarLocalidades();
      await ref.read(codigosPostalesProvider.notifier).cargarCodigosPostales();

      if (o != null && o.calleId != null) {
        calleSeleccionadaId = o.calleId;
        _inicializarUbicacionEdicion(o.calleId!);
      }
    });
  }

  // -----------------------
  // Imagen base64
  // -----------------------
  Future<void> _pickImage(String tipo) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (image == null) return;

    final bytes = await image.readAsBytes();
    final base64Img = base64Encode(bytes);

    setState(() {
      if (tipo == 'logo') logoB64 = base64Img;
      if (tipo == 'presi') firmaPresiB64 = base64Img;
      if (tipo == 'sec') firmaSecB64 = base64Img;
      if (tipo == 'tes') firmaTesB64 = base64Img;
    });
  }

  // -----------------------
  // Selector de calle
  // -----------------------
  void _abrirSelectorCalle() async {
    final resultado = await showSearch(context: context, delegate: CalleSearchDelegate(ref: ref));
    if (resultado is Calle) _autocompletarDesdeCalle(resultado);
  }

  void _autocompletarDesdeCalle(Calle calle) {
    final locs = ref.read(localidadesProvider).value ?? [];
    final cps = ref.read(codigosPostalesProvider).value ?? [];

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

  void _inicializarUbicacionEdicion(int id) {
    final calles = ref.read(callesProvider).value ?? [];
    final calle = calles.firstWhere(
      (c) => c.id == id,
      orElse: () => Calle(id: 0, nombreCalle: '', localidadId: 0, nombreLocalidad: '', codPostalId: 0, nombreCP: '', responsableId: null),
    );
    if (calle.id != 0) _autocompletarDesdeCalle(calle);
  }

  // -----------------------
  // Guardar
  // -----------------------
  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
 String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }
    try {
      final data = {
        "cif": cifCtrl.text.trim(),
        "nombre": capitalize(nombreCtrl.text.trim()),
        "telefono": telefonoCtrl.text.trim(),
        "email": emailCtrl.text.trim(),

        "calle_id": calleSeleccionadaId,
        "numero": numeroCtrl.text.trim(),
        "piso": pisoCtrl.text.trim(),
        "puerta": puertaCtrl.text.trim(),
        "escalera": escaleraCtrl.text.trim(),
        "bloque": bloqueCtrl.text.trim(),
        "portal": portalCtrl.text.trim(),

        "logo": logoB64,
        "firma_presidente": firmaPresiB64,
        "firma_secretario": firmaSecB64,
        "firma_tesorero": firmaTesB64,
      };

      if (widget.organizadorAEditar == null) {
        await ref.read(organizadoresProvider.notifier).crear(data);
      } else {
        await ref.read(organizadoresProvider.notifier)
            .editar(widget.organizadorAEditar!.id, data);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✔ Organizador guardado correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
        ],
      ),
    );
  }

  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      isLoading: _isLoading,
      title: widget.organizadorAEditar == null
          ? "Nuevo Organizador"
          : "Editar Organizador",
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(children: [
          _buildCard(title: "IDENTIFICACIÓN", children: [
            _buildRow("Logo", _imagePickerBox(logoB64, () => _pickImage('logo'), circle: true)),
            _buildRow("CIF *", _textFormField(cifCtrl, required: true)),
            _buildRow("Nombre *", _textFormField(nombreCtrl, required: true)),
           _buildRow(
                  'Email',
                  _textFormField(emailCtrl,
                      isEmail:
                          true, 
                      hint: 'ejemplo@correo.com')),
              _buildRow(
                  'Teléfono',
                  _textFormField(telefonoCtrl,
                      isPhone: true, 
                      hint: '600000000')),
          ]),

          _buildCard(title: "UBICACIÓN", children: [
            _buildRow("Calle *", _calleSelectorField()),

            const Divider(),

            _buildRow("Provincia", _provinciaDD()),
            if (provinciaId != null) _buildRow("Localidad", _localidadDD()),
            if (localidadId != null) _buildRow("C.P.", _cpDD()),

            _buildRow("Número", _textFormField(numeroCtrl)),
            _buildRow("Piso", _textFormField(pisoCtrl)),
            _buildRow("Puerta", _textFormField(puertaCtrl)),
            _buildRow("Escalera", _textFormField(escaleraCtrl)),
            _buildRow("Bloque", _textFormField(bloqueCtrl)),
            _buildRow("Portal", _textFormField(portalCtrl)),
          ]),

          _buildCard(title: "FIRMAS", children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _signature("Presidente", firmaPresiB64, () => _pickImage('presi')),
                _signature("Secretario", firmaSecB64, () => _pickImage('sec')),
              ],
            ),
            const Divider(),
            Center(
              child: _signature("Tesorero", firmaTesB64, () => _pickImage('tes')),
            )
          ]),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  // -----------------------
  // Widgets auxiliares
  // -----------------------

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const Divider(),
          ...children
        ]),
      ),
    );
  }
  Widget _buildRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(color: Colors.black54, fontSize: 13))),
        Expanded(flex: 5, child: child)
      ]),
    );
  }
  Widget _textFormField(TextEditingController c,
      {bool required = false,
      bool isEmail = false,
       bool isPhone = false,
      bool isNumber = false,
      String? hint}) {
    return TextFormField(
      controller: c,
      keyboardType: isNumber
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) return 'Obligatorio';
        if (v == null || v.isEmpty)
          return null; // Si no es requerido y está vacío, es válido


        // Validación de Email (usando tu RegExp de la clase Email)
        if (isEmail) {
          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegExp.hasMatch(v)) return 'Formato de correo no válido';
        }

        // Validación de Teléfono (mínimo 9 caracteres)
        if (isPhone && v.trim().length < 9) {
          return 'Mínimo 9 dígitos';
        }


        return null;
      },
    );
  }

  Widget _imagePickerBox(String? b64, VoidCallback onTap, {bool circle = false}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Hero(
            tag: b64 ?? 'logo_placeholder',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(circle ? 100 : 8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: b64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(circle ? 100 : 8),
                      child: Image.memory(base64Decode(b64), fit: BoxFit.cover),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
            ),
          ),
        ),
        if (b64 != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _showFullImage(context, b64, "Logo"),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.blue.withOpacity(0.8),
                child: const Icon(Icons.fullscreen, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _signature(String label, String? b64, VoidCallback onTap) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (b64 != null)
              IconButton(
                icon: const Icon(Icons.zoom_in, size: 18),
                onPressed: () => _showFullImage(context, b64, "Firma $label"),
              )
          ],
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Hero(
            tag: b64 ?? 'firma_$label',
            child: Container(
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: b64 == null
                  ? const Icon(Icons.border_color)
                  : Image.memory(base64Decode(b64), fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context, String b64, String title) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () {
                // Aquí podrías usar paquetes como 'image_gallery_saver' o 'path_provider'
                // Por ahora simulamos la acción:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preparando descarga de imagen..."))
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Hero(
            tag: b64,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.memory(base64Decode(b64)),
            ),
          ),
        ),
      ),
    );
  }
  Widget _calleSelectorField() {
    return TextFormField(
      controller: calleCtrl,
      readOnly: true,
      validator: (v) => (v == null || v.isEmpty) ? "Seleccione una calle" : null,
      onTap: _abrirSelectorCalle,
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.search),
        isDense: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _provinciaDD() => ref.watch(provinciasProvider).when(
        data: (list) => DropdownButtonFormField<int>(
          value: provinciaId,
          decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
          items: list.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreProvincia))).toList(),
          onChanged: (v) => setState(() {
            provinciaId = v;
            localidadId = null;
            cpId = null;
          }),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text("Error provincias"),
      );

  Widget _localidadDD() => ref.watch(localidadesProvider).when(
        data: (list) {
          final filtradas = list.where((l) => l.codProvinciaId == provinciaId).toList();

          return DropdownButtonFormField<int>(
            value: filtradas.any((l) => l.id == localidadId) ? localidadId : null,
            decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            items: filtradas.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nombreLocalidad))).toList(),
            onChanged: (v) => setState(() {
              localidadId = v;
              cpId = null;
            }),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text("Error localidades"),
      );

  Widget _cpDD() => ref.watch(codigosPostalesProvider).when(
        data: (list) {
          final filtrados = list.where((c) => c.localidadId == localidadId).toList();

          return DropdownButtonFormField<int>(
            value: filtrados.any((c) => c.id == cpId) ? cpId : null,
            decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            items: filtrados.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => cpId = v),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const Text("Error CP"),
      );
}
