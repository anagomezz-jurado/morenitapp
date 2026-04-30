import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

// IMPORTS PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/features/panel-gestion/libros/presentation/providers/libro_provider.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';
import 'package:morenitapp/shared/widgets/plantilla_formularios.dart';

class LibroFormScreen extends ConsumerStatefulWidget {
  final dynamic libroAEditar;
  const LibroFormScreen({super.key, this.libroAEditar});

  @override
  ConsumerState<LibroFormScreen> createState() => _LibroFormScreenState();
}

class _LibroFormScreenState extends ConsumerState<LibroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController codCtrl,
      nomCtrl,
      anioCtrl,
      impTotalCtrl,
      fechaReciboCtrl,
      descCtrl,
      txtReciboCtrl,
      txtAnuncianteCtrl;
  int? selectedTipoEventoId;

  List<Map<String, dynamic>> listaDocumentos = [];
  List<int> archivosEliminadosIds = [];
  List<Map<String, dynamic>> tempAnunciantes = [];

  @override
  void initState() {
    super.initState();
    final l = widget.libroAEditar;

    codCtrl = TextEditingController(text: l?.codLibro ?? '');
    nomCtrl = TextEditingController(text: l?.nombre ?? '');
    anioCtrl = TextEditingController(text: l?.anio?.toString() ?? '2026');
    impTotalCtrl =
        TextEditingController(text: l?.importe?.toString() ?? '0.00');
    fechaReciboCtrl = TextEditingController(text: l?.fechaRecibo ?? '');
    descCtrl = TextEditingController(text: l?.descripcion ?? '');
    txtReciboCtrl = TextEditingController(text: l?.textoReciboEvento ?? '');
    txtAnuncianteCtrl = TextEditingController(text: l?.textoAnunciante ?? '');

    if (l != null) {
      selectedTipoEventoId = l.tipoeventoId;
      if (l.archivos != null) {
        for (var archivo in l.archivos) {
          listaDocumentos.add({
            'id': archivo.id,
            'nombre': archivo.nombre,
            'base64': archivo.base64,
            'esNuevo': false,
          });
        }
      }
      if (l.anunciantes != null) {
        tempAnunciantes =
            List<Map<String, dynamic>>.from((l.anunciantes as List).map((a) => {
                  "id": a.id,
                  "proveedor_id": a.proveedorId,
                  "nombre": a.proveedorNombre,
                  "importe": a.importe,
                  "cobrado": a.cobrado,
                  "fecha_cobro": a.fechaCobro,
                }));
      }
    }
  }

  @override
  void dispose() {
    codCtrl.dispose();
    nomCtrl.dispose();
    anioCtrl.dispose();
    impTotalCtrl.dispose();
    fechaReciboCtrl.dispose();
    descCtrl.dispose();
    txtReciboCtrl.dispose();
    txtAnuncianteCtrl.dispose();
    super.dispose();
  }

  Future<void> _imprimirListadoAnunciantes() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Header(
            level: 0,
            child: pw.Text("Listado de Anunciantes: ${nomCtrl.text}")),
        pw.TableHelper.fromTextArray(
          headers: ['Anunciante', 'Importe', 'Cobrado'],
          data: tempAnunciantes
              .map((a) => [
                    a['nombre'],
                    "${a['importe']} €",
                    a['cobrado'] ? "SI" : "NO"
                  ])
              .toList(),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final datos = {
        "cod_libro": codCtrl.text.trim(),
        "nombre": nomCtrl.text.trim(),
        "anio": int.tryParse(anioCtrl.text) ?? 2026,
        "descripcion": descCtrl.text.trim(),
        "importe": double.tryParse(impTotalCtrl.text) ?? 0.0,
        "fecha_recibo":
            fechaReciboCtrl.text.isEmpty ? null : fechaReciboCtrl.text,
        "texto_recibo_evento": txtReciboCtrl.text.trim(),
        "texto_anunciante": txtAnuncianteCtrl.text.trim(),
        "tipoevento_id": selectedTipoEventoId,
        "anunciantes": tempAnunciantes,
        "subir_archivos":
            listaDocumentos.where((d) => d['esNuevo'] == true).toList(),
        "eliminar_archivos": archivosEliminadosIds,
      };

      bool success = false;
      if (widget.libroAEditar == null) {
        success = await ref.read(librosProvider.notifier).agregarLibro(datos);
      } else {
        success = await ref
            .read(librosProvider.notifier)
            .actualizarLibro(widget.libroAEditar.id, datos);
      }

      if (mounted && success) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      title: widget.libroAEditar != null ? 'Ficha de Libro' : 'Nuevo Libro',
      isLoading: _isLoading,
      onSave: _onSave,
      child: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard(title: 'DATOS GENERALES', children: [
                _buildRow('Código', _textFormField(codCtrl, required: true)),
                _buildRow('Nombre', _textFormField(nomCtrl, required: true)),
                _buildRow('Año', _textFormField(anioCtrl, isNumber: true)),
                _buildRow('Tipo Evento', _buildTipoEventoDropdown()),
                _buildRow('Importe Total',
                    _textFormField(impTotalCtrl, isNumber: true)),
                _buildRow('Fecha Recibo', _buildDatePicker()),
              ]),
              _buildCard(title: 'TEXTOS CONFIGURACIÓN', children: [
                _buildRow(
                    'Texto Recibo', _textFormField(txtReciboCtrl, maxLines: 2)),
                _buildRow('Texto Anunciante',
                    _textFormField(txtAnuncianteCtrl, maxLines: 2)),
                _buildRow('Descripción', _textFormField(descCtrl, maxLines: 2)),
              ]),
              _buildSeccionDocumentacion(),
              _buildCard(
                title: 'ANUNCIANTES',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Anunciantes Vinculados",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                              onPressed: tempAnunciantes.isEmpty
                                  ? null
                                  : _imprimirListadoAnunciantes,
                              icon: const Icon(Icons.picture_as_pdf,
                                  color: Colors.red, size: 20)),
                          ElevatedButton.icon(
                            onPressed: _abrirSelectorAnunciantes,
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text("Añadir",
                                style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildAnunciantesTable(),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0, 
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey)),
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
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text(label, style: const TextStyle(fontSize: 11))),
          Expanded(flex: 6, child: child),
        ],
      ),
    );
  }

  Widget _textFormField(TextEditingController ctrl,
      {bool required = false,
      bool isNumber = false,
      int maxLines = 1,
      String? hint}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) =>
          (required && (v == null || v.isEmpty)) ? 'Requerido' : null,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
  }

  Widget _buildTipoEventoDropdown() {
    final asyncTipos = ref.watch(tiposEventoProvider);
    return asyncTipos.when(
      data: (lista) => DropdownButtonFormField<int>(
        value: selectedTipoEventoId,
        items: lista
            .map((e) => DropdownMenuItem(
                value: e.id,
                child: Text(e.nombre, style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: (v) => setState(() => selectedTipoEventoId = v),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text("Error al cargar"),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        DateTime? p = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101));
        if (p != null)
          setState(
              () => fechaReciboCtrl.text = DateFormat('yyyy-MM-dd').format(p));
      },
      child: IgnorePointer(
        child: _textFormField(fechaReciboCtrl, hint: 'AAAA-MM-DD'),
      ),
    );
  }

  Widget _buildAnunciantesTable() {
    if (tempAnunciantes.isEmpty)
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Sin anunciantes",
            style: TextStyle(fontSize: 10, color: Colors.grey)),
      );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowHeight: 35,
        dataRowMinHeight: 35,
        columns: const [
          DataColumn(
              label: Text("ANUNCIANTE",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("IMP",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("COB",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
          DataColumn(label: Text("")),
        ],
        rows: tempAnunciantes.asMap().entries.map((entry) {
          int idx = entry.key;
          var a = entry.value;
          return DataRow(cells: [
            DataCell(Text(a['nombre'], style: const TextStyle(fontSize: 10))),
            DataCell(SizedBox(
                width: 45,
                child: TextFormField(
                  initialValue: a['importe'].toString(),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 10),
                  onChanged: (v) => tempAnunciantes[idx]['importe'] =
                      double.tryParse(v) ?? 0.0,
                ))),
            DataCell(Checkbox(
                value: a['cobrado'],
                onChanged: (v) =>
                    setState(() => tempAnunciantes[idx]['cobrado'] = v))),
            DataCell(IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 16),
                onPressed: () =>
                    setState(() => tempAnunciantes.removeAt(idx)))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildSeccionDocumentacion() {
    return _buildCard(
      title: "DOCUMENTACIÓN ADJUNTA",
      children: [
        ...listaDocumentos.asMap().entries.map((e) => ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const Icon(Icons.file_present,
                  size: 18, color: Colors.blueGrey),
              title:
                  Text(e.value['nombre'], style: const TextStyle(fontSize: 11)),
              trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  onPressed: () =>
                      setState(() => listaDocumentos.removeAt(e.key))),
            )),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: _seleccionarArchivo,
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text("Añadir Archivo",
                    style: TextStyle(fontSize: 11))))
      ],
    );
  }

  void _abrirSelectorAnunciantes() {
    final anunciantes = ref.read(listaSoloAnunciantes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Añadir Anunciante",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: anunciantes.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) => ListTile(
              title: Text(anunciantes[i].nombre,
                  style: const TextStyle(fontSize: 12)),
              onTap: () {
                setState(() => tempAnunciantes.add({
                      "id": null,
                      "proveedor_id": int.parse(anunciantes[i].id),
                      "nombre": anunciantes[i].nombre,
                      "importe": 0.0,
                      "cobrado": false,
                    }));
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result =
        await FilePicker.pickFiles(withData: true, allowMultiple: true);

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          listaDocumentos.add({
            'nombre': file.name,
            'base64': base64Encode(file.bytes!),
            'esNuevo': true
          });
        }
      });
    }
  }
}
