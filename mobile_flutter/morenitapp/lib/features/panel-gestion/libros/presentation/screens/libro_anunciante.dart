import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

// --- NUEVOS IMPORTS PARA PDF ---
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
    impTotalCtrl = TextEditingController(text: l?.importe?.toString() ?? '0.00');
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
        tempAnunciantes = List<Map<String, dynamic>>.from((l.anunciantes as List).map((a) => {
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

  // --- LÓGICA DE IMPRESIÓN PDF ---

  Future<void> _imprimirListadoAnunciantes() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Listado de Anunciantes: ${nomCtrl.text} (${anioCtrl.text})"),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Anunciante', 'Importe', 'Cobrado'],
            data: tempAnunciantes.map((a) => [
              a['nombre'],
              "${a['importe'].toStringAsFixed(2)} €",
              (a['cobrado'] == true) ? "SI" : "NO"
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "TOTAL: ${tempAnunciantes.fold<double>(0.0, (sum, item) => sum + (item['importe'] ?? 0.0)).toStringAsFixed(2)} €",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Listado_Anunciantes_${nomCtrl.text}.pdf',
    );
  }

  // --- LÓGICA DE ARCHIVOS ---

  Future<void> _descargarArchivo(Map<String, dynamic> doc) async {
    if (doc['base64'] == null || doc['base64'].toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Archivo sin contenido")));
      return;
    }
    try {
      final bytes = base64Decode(doc['base64']);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${doc['nombre']}');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'png'],
          withData: true,
          allowMultiple: true);

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.bytes != null) {
              listaDocumentos.add({
                'nombre': file.name,
                'base64': base64Encode(file.bytes!),
                'esNuevo': true
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _eliminarArchivo(int index) {
    setState(() {
      final doc = listaDocumentos[index];
      if (doc['esNuevo'] == false && doc['id'] != null) {
        archivosEliminadosIds.add(doc['id']);
      }
      listaDocumentos.removeAt(index);
    });
  }

  // --- ACCIÓN DE GUARDADO ---

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final archivosNuevos = listaDocumentos
          .where((d) => d['esNuevo'] == true)
          .map((d) => {"nombre": d['nombre'], "base64": d['base64']})
          .toList();

      final datos = {
        "cod_libro": codCtrl.text,
        "nombre": nomCtrl.text,
        "anio": int.tryParse(anioCtrl.text) ?? 2026,
        "descripcion": descCtrl.text,
        "importe": double.tryParse(impTotalCtrl.text) ?? 0.0,
        "fecha_recibo": fechaReciboCtrl.text.isEmpty ? null : fechaReciboCtrl.text,
        "texto_recibo_evento": txtReciboCtrl.text,
        "texto_anunciante": txtAnuncianteCtrl.text,
        "tipoevento_id": selectedTipoEventoId,
        "anunciantes": tempAnunciantes,
        "subir_archivos": archivosNuevos,
        "eliminar_archivos": archivosEliminadosIds,
      };

      bool success = false;
      if (widget.libroAEditar == null) {
        success = await ref.read(librosProvider.notifier).agregarLibro(datos);
      } else {
        success = await ref.read(librosProvider.notifier).actualizarLibro(widget.libroAEditar.id, datos);
      }

      if (mounted) {
        if (success) {
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al guardar")));
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI SECTIONS ---

  @override
  Widget build(BuildContext context) {
    return PlantillaWrapper(
      title: widget.libroAEditar != null ? 'EDITAR LIBRO' : 'NUEVO LIBRO',
      isLoading: _isLoading,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(title: "DATOS GENERALES", children: [
              _buildRow("Código", _textFormField(codCtrl, required: true)),
              _buildRow("Nombre", _textFormField(nomCtrl, required: true)),
              _buildRow("Año", _textFormField(anioCtrl, isNumber: true)),
              _buildRow("Tipo Evento", _buildTipoEventoDropdown()),
              _buildRow("Importe Total", _textFormField(impTotalCtrl, isNumber: true)),
              _buildRow("Fecha Recibo", _buildDatePicker()),
            ]),
            _buildCard(title: "TEXTOS", children: [
              _buildRow("Texto Recibo", _textFormField(txtReciboCtrl, maxLines: 2)),
              _buildRow("Texto Anunciante", _textFormField(txtAnuncianteCtrl, maxLines: 2)),
              _buildRow("Descripción", _textFormField(descCtrl, maxLines: 2)),
            ]),
            _buildSeccionDocumentacion(),
            _buildCard(
              title: "ANUNCIANTES",
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Anunciantes Seleccionados",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        // BOTÓN IMPRIMIR PDF
                        TextButton.icon(
                          onPressed: tempAnunciantes.isEmpty ? null : _imprimirListadoAnunciantes,
                          icon: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                          label: const Text("PDF", style: TextStyle(fontSize: 11, color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        // BOTÓN AÑADIR
                        ElevatedButton.icon(
                          onPressed: _abrirSelectorAnunciantes,
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text("Añadir"),
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
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        DateTime? p = await showDatePicker(
            context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
        if (p != null) {
          setState(() => fechaReciboCtrl.text = DateFormat('yyyy-MM-dd').format(p));
        }
      },
      child: IgnorePointer(child: _textFormField(fechaReciboCtrl)),
    );
  }

  Widget _buildSeccionDocumentacion() {
    return _buildCard(
      title: "DOCUMENTACIÓN (ADJUNTOS)",
      children: [
        ...listaDocumentos.asMap().entries.map((entry) {
          int idx = entry.key;
          var doc = entry.value;
          bool esNuevo = doc['esNuevo'] ?? false;

          return ListTile(
            dense: true,
            leading: Icon(esNuevo ? Icons.cloud_upload_outlined : Icons.file_present,
                color: esNuevo ? Colors.green : Colors.blueGrey),
            title: Text(doc['nombre'], style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!esNuevo)
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.blue, size: 22),
                    onPressed: () => _descargarArchivo(doc),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                  onPressed: () => _eliminarArchivo(idx),
                ),
              ],
            ),
          );
        }).toList(),
        if (listaDocumentos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text("Sin documentos adjuntos", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
                onPressed: _seleccionarArchivo, icon: const Icon(Icons.upload_file), label: const Text("Subir Archivo/s"))),
      ],
    );
  }

  Widget _buildAnunciantesTable() {
    if (tempAnunciantes.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        columns: const [
          DataColumn(label: Text("ANUNCIANTE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          DataColumn(label: Text("IMP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          DataColumn(label: Text("COB", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          DataColumn(label: Text("", style: TextStyle(fontSize: 10))),
        ],
        rows: tempAnunciantes.asMap().entries.map((entry) {
          int idx = entry.key;
          var a = entry.value;
          return DataRow(cells: [
            DataCell(Text(a['nombre'], style: const TextStyle(fontSize: 10))),
            DataCell(SizedBox(
                width: 50,
                child: TextFormField(
                    initialValue: a['importe'].toString(),
                    style: const TextStyle(fontSize: 10),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => tempAnunciantes[idx]['importe'] = double.tryParse(v) ?? 0.0))),
            DataCell(Checkbox(
                value: a['cobrado'], onChanged: (v) => setState(() => tempAnunciantes[idx]['cobrado'] = v))),
            DataCell(IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 16),
                onPressed: () => setState(() => tempAnunciantes.removeAt(idx)))),
          ]);
        }).toList(),
      ),
    );
  }

  void _abrirSelectorAnunciantes() {
    final anunciantesDisponibles = ref.read(listaSoloAnunciantes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Añadir Anunciante"),
        content: SizedBox(
          width: double.maxFinite,
          child: anunciantesDisponibles.isEmpty
              ? const Text("No hay anunciantes.")
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: anunciantesDisponibles.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final prov = anunciantesDisponibles[i];
                    return ListTile(
                      title: Text(prov.nombre),
                      onTap: () {
                        setState(() {
                          tempAnunciantes.add({
                            "id": null,
                            "proveedor_id": int.parse(prov.id),
                            "nombre": prov.nombre,
                            "importe": 0.0,
                            "cobrado": false,
                          });
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildTipoEventoDropdown() {
    final asyncTipos = ref.watch(tiposEventoProvider);
    return asyncTipos.when(
      data: (lista) => DropdownButtonFormField<int>(
        value: selectedTipoEventoId,
        items: lista
            .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre, style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: (v) => setState(() => selectedTipoEventoId = v),
        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text("Error"),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(),
              ...children
            ])));
  }

  Widget _buildRow(String label, Widget child) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(flex: 4, child: Text(label, style: const TextStyle(fontSize: 11))),
          Expanded(flex: 6, child: child)
        ]));
  }

  Widget _textFormField(TextEditingController ctrl, {bool required = false, bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => (required && (v == null || v.isEmpty)) ? 'Campo obligatorio' : null,
      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
    );
  }
}