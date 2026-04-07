import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/usuarios_provider.dart';

class UsuariosScreen extends ConsumerWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, 'Buscar usuario...', () => _showUserForm(context, ref)),
          Expanded(
            child: _buildTableContainer(
              usuariosAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (usuarios) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('NOMBRE')),
                      DataColumn(label: Text('EMAIL')),
                      DataColumn(label: Text('ROL')),
                      DataColumn(label: Text('ACCIONES')),
                    ],
                    rows: usuarios.map((u) => DataRow(cells: [
                      DataCell(Text(u.fullName)),
                      DataCell(Text(u.email)),
                      DataCell(Text(u.rolId == 1 ? 'Admin' : 'Usuario')),
                      DataCell(Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), 
                            onPressed: () => _showUserForm(context, ref, user: u)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), 
                            onPressed: () => _confirmarEliminar(context, ref, u)),
                        ],
                      )),
                    ])).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dentro de UsuariosScreen, actualiza el método _showUserForm:

void _showUserForm(BuildContext context, WidgetRef ref, {User? user}) {
  final nomCtrl = TextEditingController(text: user?.fullName ?? '');
  final emailCtrl = TextEditingController(text: user?.email ?? '');
  final passCtrl = TextEditingController();
  
  // Variable local para el rol (1: Admin, 2: Usuario)
  int selectedRol = user?.rolId ?? 2; 

  _showStyledDialog(
    context,
    title: user == null ? 'Nuevo Usuario' : 'Editar Usuario',
    content: [
      _buildTextField(nomCtrl, 'Nombre Completo'),
      const SizedBox(height: 15),
      _buildTextField(emailCtrl, 'Correo Electrónico'),
      const SizedBox(height: 15),
      
      // --- NUEVO: Selector de Rol ---
      DropdownButtonFormField<int>(
        value: selectedRol,
        decoration: const InputDecoration(
          labelText: 'Rol del Sistema',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 2, child: Text('Usuario Estándar')),
          DropdownMenuItem(value: 1, child: Text('Administrador')),
        ],
        onChanged: (value) {
          if (value != null) selectedRol = value;
        },
      ),
      
      if (user == null) ...[
        const SizedBox(height: 15),
        _buildTextField(passCtrl, 'Contraseña'), 
      ]
    ],
    onSave: () {
      if (user == null) {
        // Enviamos el selectedRol al crear
        ref.read(usuariosProvider.notifier).crear(
          nomCtrl.text, 
          emailCtrl.text, 
          passCtrl.text,
          rolId: selectedRol // Pasamos el rol
        );
      } else {
        // Enviamos el selectedRol al editar
        ref.read(usuariosProvider.notifier).editar(
          user.id, 
          nomCtrl.text, 
          emailCtrl.text,
          rolId: selectedRol // Pasamos el rol
        );
      }
    }
  );
}

  void _confirmarEliminar(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: Text('Esta acción eliminará a ${user.fullName}. No se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(usuariosProvider.notifier).eliminar(user.id);
              Navigator.pop(context);
            }, 
            child: const Text('ELIMINAR')
          ),
        ],
      ),
    );
  }
}

Widget _buildHeader(BuildContext context, WidgetRef ref, String hint, VoidCallback onNew) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    child: Row(
      children: [
        ElevatedButton.icon(
          onPressed: onNew,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text('NUEVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF714B67),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 250, height: 35,
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              suffixIcon: const Icon(Icons.search, size: 20),
              filled: true, fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDEE2E6))),
            ),
          ),
        ),
      ],
    ),
  );
}

// 2. Contenedor de la tabla con sombra y fondo blanco
Widget _buildTableContainer(Widget child) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
    ),
    child: child,
  );
}

// 3. Botones de acción (Editar/Eliminar)
Widget _buildActionButtons({required VoidCallback onEdit, required VoidCallback onDelete}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: onEdit),
      IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: onDelete),
    ],
  );
}

// 4. Formulario en Dialog Estilizado
void _showStyledDialog(BuildContext context, {required String title, required List<Widget> content, required VoidCallback onSave}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF714B67)),
          onPressed: () { onSave(); Navigator.pop(context); },
          child: const Text('GUARDAR'),
        ),
      ],
    ),
  );
}

// 5. TextField reutilizable para los Diálogos
Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumeric = false}) {
  return TextField(
    controller: ctrl,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
  );
}