import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/providers/configuracion_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/notificacion.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notisAsync = ref.watch(notificacionesProvider);

    return PlantillaVentanas(
      title: 'Historial de Notificaciones',
      isLoading: notisAsync.isLoading,
      onRefresh: () => ref.refresh(notificacionesProvider),
      onNuevo: () => _showEnvioForm(context, ref),
      columns: const [
        DataColumn(
            label:
                Text('ASUNTO', style: TextStyle(fontWeight: FontWeight.bold))),
         DataColumn(
            label:
                Text('MENSAJE', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('TIPO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text('FECHA', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('ACCIONES',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: notisAsync.when(
        data: (notis) => notis
            .map((n) => DataRow(cells: [
                  DataCell(Text(n.asunto)),
                  DataCell(
            Text(
              removeHtmlTags(n.mensaje), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            )
          ),
                  DataCell(Text(n.tipoNombre ?? 'General')),
                  DataCell(Text(n.fechaRegistro ?? '-')),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined,
                        color: Colors.redAccent),
                    tooltip: 'Eliminar notificación',
                    onPressed: () async {
                      final confirm = await _confirmarEliminacion(context);
                      if (confirm && context.mounted) {
                        ref
                            .read(notificacionesProvider.notifier)
                            .eliminar(n.id!);
                      }
                    },
                  )),
                ]))
            .toList(),
        error: (e, _) => [
          const DataRow(cells: [
            DataCell(Text('Error al cargar notificaciones')),
            DataCell(Text('-')),
            DataCell(Text('-')),
            DataCell(Text('-')),
          ]),
        ],
        loading: () => [],
      ),
    );
  }

  Future<bool> _confirmarEliminacion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
                '¿Estás seguro de que quieres eliminar esta notificación?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style:
                    FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showEnvioForm(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
          child: const Material(
              color: Colors.transparent, child: _NotificacionForm()),
        ),
      ),
    );
  }
}
String removeHtmlTags(String htmlText) {
  // Reemplaza etiquetas HTML por un espacio vacío
  final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  String cleanText = htmlText.replaceAll(exp, '');
  
  // Opcional: Limpiar entidades comunes como &nbsp;
  cleanText = cleanText.replaceAll('&nbsp;', ' ');
  
  return cleanText.trim();
}
// ─────────────────────────────────────────────
// FORMULARIO
// ─────────────────────────────────────────────
class _NotificacionForm extends ConsumerStatefulWidget {
  const _NotificacionForm();

  @override
  ConsumerState<_NotificacionForm> createState() => _NotificacionFormState();
}

class _NotificacionFormState extends ConsumerState<_NotificacionForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _asuntoCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  int? _selectedTipoId;
  bool _enviando = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }
    
    capitalize(_asuntoCtrl.text).trim();
    capitalize(_mensajeCtrl.text).trim();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(notificacionTiposProvider);
    final colors = Theme.of(context).colorScheme;
String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                Icon(Icons.notifications_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Text('NUEVO ENVÍO',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            // Asunto
            TextFormField(
              controller: _asuntoCtrl,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Asunto de la Notificación',
                border: UnderlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El asunto es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),

            // Tipo de Aviso
            tiposAsync.when(
              
              data: (tipos) => DropdownButtonFormField<int>(
                
                decoration: const InputDecoration(
                  labelText: 'Tipo de Aviso',
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                
                value: _selectedTipoId,
                
                items: tipos
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTipoId = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error cargando tipos'),
            ),
            const SizedBox(height: 16),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Mensaje'),
                Tab(text: 'Destinatarios'),
              ],
            ),

            // Contenido tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMensajeTab(),
                  _buildDestinatariosTab(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                icon: _enviando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.email_outlined),
                label: Text(_enviando ? 'Enviando...' : 'ENVIAR POR EMAIL'),
                onPressed: _enviando ? null : _enviar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMensajeTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: _mensajeCtrl,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'Escriba aquí el contenido de la notificación...',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        validator: (v) => (v == null || v.trim().isEmpty)
            ? 'El mensaje es obligatorio'
            : null,
      ),
    );
  }

  Widget _buildDestinatariosTab() {
    final usuariosAsync = ref.watch(usuariosConEmailProvider);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Banner Informativo (Ayuda a entender por qué aparecen estos usuarios)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: colors.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Solo se listan usuarios con la opción "Recibir correos" habilitada.',
                    style: TextStyle(
                        fontSize: 11, color: colors.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),

          // 2. Cabecera de la tabla
          _buildTableHeader(colors),

          // 3. Lista con manejo de estados
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: usuariosAsync.isEmpty
                  ? _buildEmptyState(colors)
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: usuariosAsync.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colors.outlineVariant),
                      itemBuilder: (_, i) {
                        final u = usuariosAsync[i];
                        return _buildUsuarioRow(u, colors);
                      },
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(Icons.people_alt_outlined,
                    size: 14, color: colors.outline),
                const SizedBox(width: 6),
                Text(
                  '${usuariosAsync.length} destinatarios seleccionados', // Acceso directo a .length
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// --- Widgets de soporte para limpieza de código ---

  Widget _buildTableHeader(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('NOMBRE',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11))),
          Expanded(
              flex: 4,
              child: Text('EMAIL',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11))),
          Icon(Icons.check_circle, size: 16, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildUsuarioRow(dynamic u, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colors.primary.withOpacity(0.1),
                  child: Text(
                    u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(u.nombre,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(u.email,
                style: TextStyle(fontSize: 12, color: colors.outline),
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 40, color: colors.outline),
          const SizedBox(height: 8),
          Text('No hay suscriptores activos',
              style: TextStyle(color: colors.outline, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
      ),
    );
  }
Future<void> _enviar() async {
  if (!_formKey.currentState!.validate()) return;

  String capitalize(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  // 1. Obtenemos los destinatarios que ya están en la pantalla (usuariosAsync)
  final destinatarios = ref.read(usuariosConEmailProvider);
  
  // 2. Extraemos SOLO los IDs
  final List<int> idsParaEnviar = destinatarios.map((u) => u.id).toList();

  if (idsParaEnviar.isEmpty) {
    // Error de seguridad: no hay a quién enviar
    return;
  }

  setState(() => _enviando = true);

  try {
    final nuevaNoti = Notificacion(
      asunto: capitalize(_asuntoCtrl.text),  // <--- Aplicado
      mensaje: capitalize(_mensajeCtrl.text), // <--- Aplicado
      tipoId: _selectedTipoId,
      usuarioIds: idsParaEnviar, // ¡Vital que esto no vaya vacío!
    );

    // 3. Llamamos al notifier
    final success = await ref.read(notificacionesProvider.notifier).enviar(nuevaNoti);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación enviada correctamente')),
      );
    }
  } catch (e) {
    // Manejo de errores
  } finally {
    if (mounted) setState(() => _enviando = false);
  }
}
}
