import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/domain/entities/tipo_evento.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class TipoEventoScreen extends ConsumerWidget {
  const TipoEventoScreen({super.key});

  List<List<String>> prepararDatos(List<TipoEvento> lista) {
    return lista.map((h) => [
      (h.codigo ?? 'S/N').toString(),
      h.nombre,
    ]).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Log para saber cuándo se reconstruye el widget
    debugPrint('--- Renderizando TipoEventoScreen ---');
    
    final eventosAsync = ref.watch(tiposEventoProvider);

    return PlantillaVentanas(
      title: 'Tipos de Evento',
      isLoading: eventosAsync.isLoading,
      onDownloadExcel: () async {
        final lista = eventosAsync.value ?? [];
        if (lista.isEmpty) return;
        ExcelService.descargarExcel(
          nombreArchivo: 'Tipos_Evento',
          cabeceras: ['Código', 'Nombre'],
          filas: prepararDatos(lista),
        );
      },
      onDownloadPDF: () async {
        final lista = eventosAsync.value ?? [];
        if (lista.isEmpty) return;
        Uint8List? logoBytes;
        try {
          final byteData = await rootBundle.load('assets/icono.png');
          logoBytes = byteData.buffer.asUint8List();
        } catch (e) {
          debugPrint('Aviso: No se pudo cargar el logo: $e');
        }

        await ReporteGenerator.generarPDFInformativo(
          titulo: "LISTADO DE TIPOS DE EVENTO",
          headers: ['Código', 'Nombre'],
          data: prepararDatos(lista),
          logoBytes: logoBytes,
        );
      },
      onRefresh: () => ref.refresh(tiposEventoProvider),
      onNuevo: () => _showSideForm(context, ref),
      columns: const [
        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE DEL EVENTO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: eventosAsync.when(
        data: (lista) {
          debugPrint('Datos cargados exitosamente: ${lista.length} items');
          return lista.map((e) => DataRow(cells: [
            DataCell(Text(e.codigo)),
            DataCell(Text(e.nombre)),
            DataCell(_buildActionButtons(
              context,
              onEdit: () => _showSideForm(context, ref, evento: e),
              onDelete: () => ref.read(tiposEventoProvider.notifier).eliminar(e.id!),
            )),
          ])).toList();
        },
        error: (err, stack) {
          // LOG CRÍTICO: Aquí verás por qué no funciona
          debugPrint('--- ERROR EN PROVIDER EVENTOS ---');
          debugPrint('Error: $err');
          debugPrint('Stacktrace: $stack');
          
          return [
            DataRow(cells: [
              const DataCell(Icon(Icons.error, color: Colors.red)),
              DataCell(Text('Error: $err')),
              const DataCell(Text('-')),
            ])
          ];
        },
        loading: () => [
          const DataRow(cells: [
            DataCell(SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            DataCell(Text('Cargando datos de Odoo...')),
            DataCell(Text('...')),
          ])
        ],
      ),
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref, {dynamic evento}) {
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
            width: MediaQuery.of(context).size.width * 0.4,
            height: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: Material(child: _EventoFormContent(evento: evento)),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(anim1),
            child: child);
      },
    );
  }

  Widget _buildActionButtons(BuildContext context,
      {required VoidCallback onEdit, required VoidCallback onDelete}) {
    final colors = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
          icon: Icon(Icons.edit_note, color: colors.primary),
          onPressed: onEdit),
      IconButton(
          icon:
              const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          onPressed: onDelete),
    ]);
  }
}

class _EventoFormContent extends ConsumerStatefulWidget {
  final dynamic evento;
  const _EventoFormContent({this.evento});
  @override
  ConsumerState<_EventoFormContent> createState() => _EventoFormContentState();
}

class _EventoFormContentState extends ConsumerState<_EventoFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController codCtrl;
  late TextEditingController nomCtrl;
  late String _colorSeleccionado;

  static const _colores = [
    '#E74C3C',
    '#E67E22',
    '#F1C40F',
    '#2ECC71',
    '#1ABC9C',
    '#3498DB',
    '#9B59B6',
    '#E91E63',
    '#795548',
    '#607D8B',
    '#093A0C',
    '#3B673D',
  ];

  @override
  void initState() {
    super.initState();
    codCtrl = TextEditingController(text: widget.evento?.codigo ?? '');
    nomCtrl = TextEditingController(text: widget.evento?.nombre ?? '');
    _colorSeleccionado = widget.evento?.color ?? '#3498DB';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Ejemplo de seguridad si tuvieras un Dropdown de Grupos (basado en tu error 3)
    final gruposAsync = ref.watch(gruposProveedorProvider);

    return Column(children: [
      _buildHeader(context, colors, widget.evento == null),
      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                  key: formKey,
                  child: Column(children: [
                    _buildField(
                        "CÓDIGO (EJ: BAUT)", codCtrl, "Ej: BAUT", colors),
                    const SizedBox(height: 25),
                    _buildField("NOMBRE DEL EVENTO", nomCtrl,
                        "Nombre del evento", colors),

                    // --- AQUÍ UN EJEMPLO DE DROPDOWN SEGURO SI LO NECESITARAS ---
                    /*
                    gruposAsync.when(
                      data: (lista) => _buildDropdownField("GRUPO", lista, colors),
                      loading: () => const CircularProgressIndicator(),
                      error: (_,__) => const Text("Error al cargar grupos"),
                    ),
                    */

                    const SizedBox(height: 50),
                    _buildColorPicker(colors),
                    const SizedBox(height: 50),
                    _buildSaveButton(colors),
                  ]))))
    ]);
  }

  // MÉTODO PARA EVITAR EL ERROR "VALUE: 3 NOT FOUND"
  Widget _buildDropdownField(
      String label, List<dynamic> opciones, ColorScheme colors) {
    // CORRECCIÓN LÓGICA: Validamos si el ID 3 existe en la lista de opciones
    final dynamic valorInicial =
        opciones.any((opt) => opt.id == widget.evento?.grupoId)
            ? widget.evento?.grupoId
            : null; // Si no existe el 3, ponemos null para no romper la app

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: colors.primary)),
      DropdownButtonFormField(
        value: valorInicial,
        items: opciones
            .map((o) => DropdownMenuItem(value: o.id, child: Text(o.nombre)))
            .toList(),
        onChanged: (val) {/* update state */},
        decoration: InputDecoration(
            filled: true, fillColor: colors.primary.withOpacity(0.02)),
      ),
    ]);
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) {
    return Container(
        padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
        decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.08),
            borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(30))),
        child: Row(children: [
          Icon(isNew ? Icons.event : Icons.edit_note, color: colors.primary),
          const SizedBox(width: 12),
          Text(isNew ? 'Nuevo Evento' : 'Editar Evento',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary)),
          const Spacer(),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)),
        ]));
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      ColorScheme colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: colors.primary)),
      const SizedBox(height: 8),
      TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: colors.primary.withOpacity(0.02),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: (v) => v!.isEmpty ? 'Requerido' : null),
    ]);
  }

  Widget _buildSaveButton(ColorScheme colors) {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final notifier = ref.read(tiposEventoProvider.notifier);
              if (widget.evento == null) {
                notifier.crear(codCtrl.text, nomCtrl.text, _colorSeleccionado);
              } else {
                notifier.editar(widget.evento.id, codCtrl.text, nomCtrl.text,
                    _colorSeleccionado);
              }
              Navigator.pop(context);
            },
            child: Text(
                widget.evento == null ? 'GUARDAR EVENTO' : 'ACTUALIZAR EVENTO',
                style: const TextStyle(fontWeight: FontWeight.bold))));
  }

  Widget _buildColorPicker(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text('COLOR DEL TIPO',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: colors.primary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _colores.map((hex) {
            final color = _colorFromHex(hex);
            final isSelected =
                hex.toUpperCase() == _colorSeleccionado.toUpperCase();
            return GestureDetector(
              onTap: () => setState(() => _colorSeleccionado = hex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected ? colors.primary : Colors.transparent,
                      width: 3),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: color.withOpacity(0.5), blurRadius: 8)
                        ]
                      : [],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: _colorFromHex(_colorSeleccionado),
                    shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(_colorSeleccionado,
                style: TextStyle(
                    fontSize: 12,
                    color: colors.primary,
                    fontFamily: 'monospace')),
          ],
        ),
      ],
    );
  }

  Color _colorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
