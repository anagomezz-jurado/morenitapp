import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/domain/entities/proveedor.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/providers/proveedor_providers.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class AnunciantesScreen extends ConsumerWidget {
  const AnunciantesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filtro específico para mostrar solo los que tienen el check de anunciante
    final listaAnunciantes = ref.watch(listaSoloAnunciantes);
    final asyncState = ref.watch(proveedoresProvider);

    return PlantillaVentanas(
      title: 'Panel de Anunciantes',
      isLoading: asyncState.isLoading,
      onRefresh: () => ref.refresh(proveedoresProvider),
      // Al ser la pantalla de anunciantes, forzamos el valor true al crear
      onNuevo: () => _showSideForm(context, ref, forcedAnunciante: true),
      onSearch: (val) {
        // Aquí puedes conectar con el provider de búsqueda si lo tienes
      },
      columns: const [
        DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('TELÉFONO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: listaAnunciantes.map((p) => DataRow(cells: [
        DataCell(Text(p.codProveedor)),
        DataCell(Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(p.telefono ?? '-')),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue), 
              onPressed: () => _showSideForm(context, ref, proveedor: p)
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red), 
              onPressed: () => _confirmarEliminar(context, ref, p)
            ),
          ],
        )),
      ])).toList(),
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref, {Proveedor? proveedor, bool forcedAnunciante = false}) {
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), 
                bottomLeft: Radius.circular(30)
              ),
            ),
            child: Material(
              child: _AnuncianteFormContent(
                proveedor: proveedor, 
                isAnuncianteDefault: forcedAnunciante
              )
            ),
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

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Proveedor p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Anunciante?'),
        content: Text('Esta acción eliminará a "${p.nombre}" de la base de datos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(proveedoresProvider.notifier).eliminar(int.parse(p.id));
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _AnuncianteFormContent extends ConsumerStatefulWidget {
  final Proveedor? proveedor;
  final bool isAnuncianteDefault;

  const _AnuncianteFormContent({this.proveedor, this.isAnuncianteDefault = false});

  @override
  ConsumerState<_AnuncianteFormContent> createState() => _AnuncianteFormContentState();
}

class _AnuncianteFormContentState extends ConsumerState<_AnuncianteFormContent> {
  late TextEditingController codCtrl, nomCtrl, telCtrl;
  late bool esAnunciante;

  @override
  void initState() {
    super.initState();
    codCtrl = TextEditingController(text: widget.proveedor?.codProveedor ?? '');
    nomCtrl = TextEditingController(text: widget.proveedor?.nombre ?? '');
    telCtrl = TextEditingController(text: widget.proveedor?.telefono ?? '');
    // Si editamos, usamos el valor del objeto. Si es nuevo, usamos el default (true en esta pantalla)
    esAnunciante = widget.proveedor?.anunciante ?? widget.isAnuncianteDefault;
  }

  void _save() {
    final notifier = ref.read(proveedoresProvider.notifier);
    if (widget.proveedor != null) {
      notifier.editar(
        id: widget.proveedor!.id, 
        codigo: codCtrl.text, 
        nombre: nomCtrl.text, 
        esAnunciante: esAnunciante, 
        telefono: telCtrl.text
      );
    } else {
      notifier.crear(
        codigo: codCtrl.text, 
        nombre: nomCtrl.text, 
        esAnunciante: esAnunciante, 
        telefono: telCtrl.text
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        _buildHeader(context, colors, widget.proveedor == null),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("CÓDIGO"),
                _buildField(codCtrl, Icons.badge_outlined),
                const SizedBox(height: 20),
                _label("NOMBRE DEL ANUNCIANTE"),
                _buildField(nomCtrl, Icons.campaign_outlined),
                const SizedBox(height: 20),
                _label("TELÉFONO DE CONTACTO"),
                _buildField(telCtrl, Icons.phone_android, isNumeric: true),
                const SizedBox(height: 25),
                
                // Switch estilizado para el estado de anunciante
                Container(
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: SwitchListTile(
                    title: const Text("ESTADO ANUNCIANTE", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text("Indica si aparece en las listas de publicidad"),
                    value: esAnunciante,
                    onChanged: (val) => setState(() => esAnunciante = val),
                  ),
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(widget.proveedor == null ? "CREAR ANUNCIANTE" : "ACTUALIZAR"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors, bool isNew) => Container(
    padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
    color: colors.primary.withOpacity(0.08),
    child: Row(children: [
      Icon(isNew ? Icons.add_business : Icons.edit_note, color: colors.primary),
      const SizedBox(width: 12),
      Text(isNew ? 'Nuevo Anunciante' : 'Editar Anunciante', 
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Spacer(),
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
    ]),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8), 
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
  );

  Widget _buildField(TextEditingController c, IconData i, {bool isNumeric = false}) => TextField(
    controller: c,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      prefixIcon: Icon(i, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: Colors.grey.shade200)
      )
    ),
  );
}