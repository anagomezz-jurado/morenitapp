import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/panel-gestion/libros/presentation/providers/libro_provider.dart';
// Asegúrate de importar tu provider de proveedores/partners aquí
// import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedores_provider.dart';
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

  // Declaración de controladores
  late TextEditingController codCtrl;
  late TextEditingController nomCtrl;
  late TextEditingController anioCtrl;
  late TextEditingController impTotalCtrl;
  late TextEditingController fechaReciboCtrl;
  late TextEditingController descCtrl;
  late TextEditingController txtReciboCtrl;
  late TextEditingController txtAnuncianteCtrl;
  
  List<Map<String, dynamic>> tempAnunciantes = [];

  @override
  void initState() {
    super.initState();
    final l = widget.libroAEditar;
    
    // INICIALIZACIÓN CRUCIAL: Previene el LateInitializationError
    codCtrl = TextEditingController(text: l?.codLibro ?? '');
    nomCtrl = TextEditingController(text: l?.nombre ?? '');
    anioCtrl = TextEditingController(text: l?.anio?.toString() ?? '2026');
    impTotalCtrl = TextEditingController(text: l?.importe?.toString() ?? '0.00');
    fechaReciboCtrl = TextEditingController(text: l?.fechaRecibo ?? '');
    descCtrl = TextEditingController(text: l?.descripcion ?? '');
    txtReciboCtrl = TextEditingController(text: l?.textoReciboEvento ?? '');
    txtAnuncianteCtrl = TextEditingController(text: l?.textoAnunciante ?? '');

    if (l?.anunciantes != null) {
      tempAnunciantes = List<Map<String, dynamic>>.from(
        (l.anunciantes as List).map((a) => {
          "id": a.id,
          "proveedor_id": a.proveedorId,
          "nombre": a.proveedorNombre,
          "importe": a.importe,
          "cobrado": a.cobrado,
          "fecha_cobro": a.fechaCobro,
        })
      );
    }
  }

  @override
  void dispose() {
    // Limpieza de controladores
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

  // Lógica para añadir un anunciante mediante un buscador
  void _mostrarSelectorProveedores() async {
    // Aquí deberías llamar a un selector de tu base de datos de Odoo
    // Por ahora, simulamos la elección de un proveedor:
    final nuevoAnunciante = {
      "id": null, // Nuevo registro
      "proveedor_id": 45, // ID real de Odoo del partner
      "nombre": "Proveedor de Prueba", 
      "importe": 0.0,
      "cobrado": false,
      "fecha_cobro": null,
    };

    setState(() {
      tempAnunciantes.add(nuevoAnunciante);
    });
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
        "importe": double.tryParse(impTotalCtrl.text.replaceAll(',', '.')) ?? 0.0,
        "fechaRecibo": fechaReciboCtrl.text,
        "textoReciboEvento": txtReciboCtrl.text,
        "textoAnunciante": txtAnuncianteCtrl.text,
        "anunciantes": tempAnunciantes, 
      };

      bool success = widget.libroAEditar == null
          ? await ref.read(librosProvider.notifier).agregarLibro(datos)
          : await ref.read(librosProvider.notifier).actualizarLibro(widget.libroAEditar.id, datos);

      if (mounted && success) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.libroAEditar != null;

    return PlantillaWrapper(
      title: esEdicion ? 'EDITAR LIBRO' : 'NUEVO LIBRO',
      isLoading: _isLoading,
      onSave: _onSave,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCard(
              title: "DATOS GENERALES",
              children: [
                _buildRow("Código", _textFormField(codCtrl, required: true)),
                _buildRow("Nombre", _textFormField(nomCtrl, required: true)),
                _buildRow("Año", _textFormField(anioCtrl, isNumber: true)),
                _buildRow("Importe Total", _textFormField(impTotalCtrl, isNumber: true)),
                _buildRow("Fecha Recibo", _textFormField(fechaReciboCtrl, hint: "YYYY-MM-DD")),
              ],
            ),
            _buildCard(
              title: "CONTENIDO Y DESCRIPCIÓN",
              children: [
                _buildRow("Txt Recibo", _textFormField(txtReciboCtrl)),
                _buildRow("Txt Anunciante", _textFormField(txtAnuncianteCtrl)),
                _buildRow("Descripción", _textFormField(descCtrl, maxLines: 3)),
              ],
            ),
            _buildCard(
              title: "ANUNCIANTES",
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Listado de anunciantes", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ElevatedButton.icon(
                      onPressed: _mostrarSelectorProveedores,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text("Añadir"),
                      style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
                const Divider(),
                _buildAnunciantesTable(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(Theme.of(context).primaryColor, esEdicion),
          ],
        ),
      ),
    );
  }

  Widget _buildAnunciantesTable() {
    if (tempAnunciantes.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay anunciantes añadidos")));

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1.5),
        2: FixedColumnWidth(40),
      },
      border: TableBorder.all(color: Colors.grey.shade100),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade50),
          children: const [
            _Th("PROVEEDOR"), _Th("IMPORTE"), Text(""),
          ],
        ),
        ...tempAnunciantes.asMap().entries.map((entry) {
          int idx = entry.key;
          var a = entry.value;
          return TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(8), child: Text(a['nombre'], style: const TextStyle(fontSize: 11))),
              _tableTextField(
                initialValue: a['importe'].toString(),
                onChanged: (v) => tempAnunciantes[idx]['importe'] = double.tryParse(v) ?? 0.0,
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20),
                onPressed: () => setState(() => tempAnunciantes.removeAt(idx)),
              ),
            ],
          );
        }),
      ],
    );
  }

  // Helpers de UI
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey)),
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
        Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))),
        Expanded(flex: 7, child: child),
      ]),
    );
  }

  Widget _textFormField(TextEditingController ctrl, {bool required = false, bool isNumber = false, int maxLines = 1, String? hint}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => (required && (val == null || val.isEmpty)) ? 'Campo obligatorio' : null,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _tableTextField({required String initialValue, required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 12),
        onChanged: onChanged,
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8), border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildSubmitButton(Color color, bool esEdicion) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: _isLoading ? null : _onSave,
        child: Text(esEdicion ? 'GUARDAR CAMBIOS' : 'REGISTRAR LIBRO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String text;
  const _Th(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)));
}