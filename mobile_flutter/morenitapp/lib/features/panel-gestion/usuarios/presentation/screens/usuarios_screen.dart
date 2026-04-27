import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/presentation/providers/usuarios_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';
import 'package:morenitapp/shared/excel/excel_Service.dart';
import 'package:morenitapp/shared/widgets/disenio_informes.dart';

// --- TEMPLATE DEL CONTENEDOR DE FILTROS ---
class FiltroContenedorTemplate extends StatelessWidget {
  final Widget child;
  final String label;
  const FiltroContenedorTemplate({super.key, required this.child, this.label = "Filtros"});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: primaryColor),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.filter_alt_outlined, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 12), child: child),
        ],
      ),
    );
  }
}

class UsuariosScreen extends ConsumerWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosFiltradosProvider);
    final currentUser = ref.watch(authProvider).user;
    final primaryColor = Theme.of(context).primaryColor;

    List<List<String>> prepararDatosExport(List<User> lista) {
      return lista.map((u) => [
            u.fullName,
            u.email,
            u.rolId == 1 ? 'Administrador' : 'Estándar',
          ]).toList();
    }

    return PlantillaVentanas(
      title: 'Gestión de Usuarios del Sistema',
      isLoading: usuariosAsync.isLoading,
      onRefresh: () => ref.refresh(usuariosListadoProvider),
      onDownloadExcel: () {
        usuariosAsync.whenData((lista) {
          if (lista.isEmpty) return;
          ExcelService.descargarExcel(
            nombreArchivo: 'Usuarios_Sistema',
            cabeceras: ['NOMBRE', 'EMAIL', 'ROL'],
            filas: prepararDatosExport(lista),
          );
        });
      },
      onDownloadPDF: () async {
        usuariosAsync.whenData((lista) async {
          if (lista.isEmpty) return;
          Uint8List? logoBytes;
          try {
            final byteData = await rootBundle.load('assets/icono.png');
            logoBytes = byteData.buffer.asUint8List();
          } catch (_) {}

          await ReporteGenerator.generarPDFInformativo(
            titulo: "LISTADO DE USUARIOS\nACCESO AL SISTEMA",
            headers: ['NOMBRE', 'EMAIL', 'ROL'],
            data: prepararDatosExport(lista),
            logoBytes: logoBytes,
          );
        });
      },
      
      onNuevo: (currentUser?.isAdmin ?? false) ? () => _showUserForm(context) : null,
      columns: [
        DataColumn(label: Text('NOMBRE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('EMAIL', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ROL', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
      ],
      rows: usuariosAsync.when(
        data: (usuarios) => usuarios.map((u) {
          final isMe = currentUser?.id == u.id;
          return DataRow(cells: [
            DataCell(Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w500))),
            DataCell(Text(u.email)),
            DataCell(_buildRolBadge(u.rolId)),
            DataCell(_buildActions(context, ref, u, currentUser, isMe)),
          ]);
        }).toList(),
        error: (e, _) => [],
        loading: () => [],
      ),
    );
  }

  Widget _buildRolBadge(int? rolId) {
    final isAdmin = rolId == 1;
    final color = isAdmin ? Colors.purple : Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(isAdmin ? 'Administrador' : 'Estándar',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, User user, User? currentUser, bool isMe) {
    if (currentUser?.isAdmin != true) return const Icon(Icons.lock_outline, color: Colors.grey, size: 18);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
          onPressed: () => _showUserForm(context, user: user),
        ),
        if (!isMe)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _confirmDelete(context, ref, user),
          ),
      ],
    );
  }

  void _showUserForm(BuildContext context, {User? user}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: _UserForm(user: user),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text('¿Deseas eliminar permanentemente a ${user.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final id = int.tryParse(user.id);
              if (id != null) ref.read(usuariosListadoProvider.notifier).eliminar(id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _UserForm extends ConsumerStatefulWidget {
  final User? user;
  const _UserForm({this.user});

  @override
  ConsumerState<_UserForm> createState() => _UserFormState();
}

class _UserFormState extends ConsumerState<_UserForm> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nombre;
  late TextEditingController email;
  late TextEditingController pass;
  int rol = 2;

  @override
  void initState() {
    super.initState();
    nombre = TextEditingController(text: widget.user?.fullName ?? '');
    email = TextEditingController(text: widget.user?.email ?? '');
    pass = TextEditingController();
    rol = widget.user?.rolId ?? 2;
  }

  @override
  void dispose() {
    nombre.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!formKey.currentState!.validate()) return;
    final data = {
      'nombre': nombre.text,
      'email': email.text,
      'rol_id': rol,
      if (pass.text.isNotEmpty) 'password': pass.text,
    };

    final notifier = ref.read(usuariosListadoProvider.notifier);

    if (widget.user == null) {
      notifier.crear(data);
    } else {
      notifier.editar(int.parse(widget.user!.id), data);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            TextFormField(
              controller: nombre,
              decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: rol,
              decoration: const InputDecoration(labelText: 'Permisos del Sistema', border: OutlineInputBorder(), prefixIcon: Icon(Icons.security)),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Administrador')),
                DropdownMenuItem(value: 2, child: Text('Usuario Estándar')),
              ],
              onChanged: (v) => setState(() => rol = v!),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: pass,
              obscureText: true,
              decoration: InputDecoration(
                labelText: widget.user == null ? 'Contraseña' : 'Cambiar Contraseña (opcional)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                helperText: widget.user == null ? 'Mínimo 6 caracteres' : 'Dejar en blanco para no cambiar',
              ),
              validator: (v) => (widget.user == null && (v == null || v.isEmpty)) ? 'Requerido' : null,
            ),
            const SizedBox(height: 25),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(widget.user == null ? 'Crear Usuario' : 'Guardar Cambios'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
          ],
        ),
      ),
    );
  }
}