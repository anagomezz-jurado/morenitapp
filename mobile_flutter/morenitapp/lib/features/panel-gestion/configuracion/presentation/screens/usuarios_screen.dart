import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/usuarios_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class UsuariosScreen extends ConsumerWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);

    return PlantillaVentanas(
      title: 'Gestión de Usuarios',
      isLoading: usuariosAsync.isLoading,
      onNuevo: () => _showSideForm(context, ref),
      onRefresh: () => ref.refresh(usuariosProvider),
      paginationText: usuariosAsync.when(
        data: (lista) => 'Total usuarios: ${lista.length}',
        error: (_, __) => 'Error al cargar',
        loading: () => 'Cargando...',
      ),
      columns: const [
        DataColumn(label: Text('NOMBRE COMPLETO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('CORREO ELECTRÓNICO', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ROL', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: usuariosAsync.when(
        data: (usuarios) => usuarios.map((u) => DataRow(cells: [
          DataCell(Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Text(u.email)),
          DataCell(_buildRolBadge(u.rolId)),
          DataCell(_buildActionButtons(context, ref, u)),
        ])).toList(),
        error: (err, _) => [],
        loading: () => [],
      ),
    );
  }

  Widget _buildRolBadge(int rolId) {
    final isAdmin = rolId == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.purple.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAdmin ? Colors.purple.shade200 : Colors.blue.shade200),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'USUARIO',
        style: TextStyle(
          color: isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, User u) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blue),
          onPressed: () => _showSideForm(context, ref, user: u),
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          onPressed: () => _confirmarEliminar(context, ref, u),
        ),
      ],
    );
  }

  void _showSideForm(BuildContext context, WidgetRef ref, {User? user}) {
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
            width: MediaQuery.of(context).size.width * 0.35, // Ancho lateral
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
            ),
            child: Material(child: _UserFormContent(user: user)),
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

  void _confirmarEliminar(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar al usuario ${user.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(usuariosProvider.notifier).eliminar(user.id);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _UserFormContent extends ConsumerStatefulWidget {
  final User? user;
  const _UserFormContent({this.user});

  @override
  ConsumerState<_UserFormContent> createState() => _UserFormContentState();
}

class _UserFormContentState extends ConsumerState<_UserFormContent> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nomCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passCtrl;
  late int selectedRol;

  @override
  void initState() {
    super.initState();
    nomCtrl = TextEditingController(text: widget.user?.fullName ?? '');
    emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    passCtrl = TextEditingController();
    selectedRol = widget.user?.rolId ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header del Formulario Lateral
        Container(
          padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.08),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30)),
          ),
          child: Row(
            children: [
              Icon(widget.user == null ? Icons.person_add_alt_1 : Icons.manage_accounts, color: colors.primary),
              const SizedBox(width: 12),
              Text(
                widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
        ),

        // Cuerpo del Formulario
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel("NOMBRE COMPLETO", colors),
                  _buildTextField(nomCtrl, "Ej: Juan Pérez", Icons.person_outline),
                  
                  const SizedBox(height: 25),
                  _buildFieldLabel("CORREO ELECTRÓNICO", colors),
                  _buildTextField(emailCtrl, "usuario@correo.com", Icons.email_outlined),

                  const SizedBox(height: 25),
                  _buildFieldLabel("ROL DEL SISTEMA", colors),
                  DropdownButtonFormField<int>(
                    value: selectedRol,
                    decoration: _inputDecoration(null, Icons.security),
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('Usuario Estándar')),
                      DropdownMenuItem(value: 1, child: Text('Administrador')),
                    ],
                    onChanged: (val) => setState(() => selectedRol = val!),
                  ),

                  if (widget.user == null) ...[
                    const SizedBox(height: 25),
                    _buildFieldLabel("CONTRASEÑA", colors),
                    _buildTextField(passCtrl, "********", Icons.lock_outline, isPassword: true),
                  ],

                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _save,
                      child: Text(widget.user == null ? 'CREAR USUARIO' : 'ACTUALIZAR DATOS'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    
    final notifier = ref.read(usuariosProvider.notifier);
    if (widget.user == null) {
      notifier.crear(nomCtrl.text, emailCtrl.text, passCtrl.text, rolId: selectedRol);
    } else {
      notifier.editar(widget.user!.id, nomCtrl.text, emailCtrl.text, rolId: selectedRol);
    }
    Navigator.pop(context);
  }

  Widget _buildFieldLabel(String label, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.primary, letterSpacing: 1.1)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword,
      decoration: _inputDecoration(hint, icon),
      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
    );
  }

  InputDecoration _inputDecoration(String? hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }
}