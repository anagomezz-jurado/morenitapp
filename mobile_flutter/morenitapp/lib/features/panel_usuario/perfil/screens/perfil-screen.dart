import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/providers/hermanos_provider.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/presentation/providers/usuarios_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  bool _isProcessing = false;

  // --- MÉTODOS DE LÓGICA ---

  Future<void> _refreshData() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(authProvider.notifier).checkAuthStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil sincronizado')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateData(Map<String, dynamic> data) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final userId = int.tryParse(user.id) ?? 0;
    if (userId == 0) return;

    setState(() => _isProcessing = true);

    try {
      final success = await ref
          .read(usuariosListadoProvider.notifier)
          .editar(userId, data);

      if (success) {
        await Future.delayed(const Duration(milliseconds: 500));
        await ref.read(authProvider.notifier).checkAuthStatus();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('¡Datos sincronizados con éxito!'),
              backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- DIÁLOGOS ---

  void _showEditDialog(
      BuildContext context, String field, String initialValue, String label) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Editar $label'),
        content: TextField(
          controller: controller,
          obscureText: field == 'password',
          decoration: InputDecoration(
              labelText: 'Nuevo $label',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateData({field: controller.text.trim()});
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showHermanoDialog(BuildContext context) {
    final dniController = TextEditingController();
    String? numeroEncontrado;
    int? hermanoIdEncontrado;
    bool buscando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void verificar() {
              final dni = dniController.text.trim().toUpperCase();
              if (dni.isEmpty) return;

              setStateDialog(() {
                buscando = true;
                numeroEncontrado = null;
                hermanoIdEncontrado = null;
              });

              final hermanosAsync = ref.read(hermanosListadoProvider);

              hermanosAsync.whenData((lista) {
                final encontrados = lista
                    .where((h) => h.dni.toString().trim().toUpperCase() == dni);

                setStateDialog(() {
                  buscando = false;
                  if (encontrados.isNotEmpty) {
                    final h = encontrados.first;
                    numeroEncontrado =
                        h.codigoHermano ?? h.numeroHermano.toString();
                    hermanoIdEncontrado = h.id;
                  }
                });
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Vincular Hermano'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dniController,
                    decoration: InputDecoration(
                      labelText: 'Introduce tu DNI',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: verificar,
                      ),
                    ),
                    onSubmitted: (_) => verificar(),
                  ),
                  const SizedBox(height: 20),
                  if (buscando) const CircularProgressIndicator(),
                  if (!buscando && numeroEncontrado != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.blue.shade200, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Text('NÚMERO DE HERMANO',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          const SizedBox(height: 8),
                          Text(numeroEncontrado!,
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  if (!buscando &&
                      numeroEncontrado == null &&
                      dniController.text.isNotEmpty)
                    const Text('No encontrado',
                        style: TextStyle(color: Colors.red)),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: hermanoIdEncontrado == null
                      ? null
                      : () async {
                          final currentUser = ref.read(authProvider).user;
                          if (currentUser == null) return;

                          final userId = int.tryParse(currentUser.id) ?? 0;
                          if (userId == 0) return;

                          Navigator.pop(context);
                          setState(() => _isProcessing = true);

                          try {
                            final exito = await ref
                                .read(usuariosListadoProvider.notifier)
                                .editar(userId,
                                    {'hermano_id': hermanoIdEncontrado});

                            if (exito) {
                              await Future.delayed(
                                  const Duration(seconds: 1));
                              await ref
                                  .read(authProvider.notifier)
                                  .checkAuthStatus();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(exito
                                      ? 'Hermano vinculado correctamente'
                                      : 'Error al vincular'),
                                  backgroundColor:
                                      exito ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted)
                              setState(() => _isProcessing = false);
                          }
                        },
                  child: const Text('Vincular'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
         onPressed: () => context.canPop() ? context.pop() : context.go('/panel-usuario'),

        ),
        title: const Text('Mi Perfil',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            )
          else
            IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _refreshData,
                color: Colors.white),
        ],
      ),
      body: PlantillaVentanas(
        title: '',
        customBody: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _ProfileSection(
                  title: 'Datos Personales',
                  children: [
                    _ProfileTile(
                      icon: Icons.person_outline,
                      label: 'Nombre',
                      value: user.nombre.isNotEmpty
                          ? user.nombre
                          : 'No definido',
                      onTap: () => _showEditDialog(
                          context, 'nombre', user.nombre, 'Nombre'),
                    ),
                    _ProfileTile(
                      icon: Icons.badge_outlined,
                      label: 'Primer Apellido',
                      value: user.apellido1.isNotEmpty
                          ? user.apellido1
                          : 'No definido',
                      onTap: () => _showEditDialog(context, 'apellido1',
                          user.apellido1, 'Primer Apellido'),
                    ),
                    _ProfileTile(
                      icon: Icons.badge_outlined,
                      label: 'Segundo Apellido',
                      value: user.apellido2.isNotEmpty
                          ? user.apellido2
                          : 'No definido',
                      onTap: () => _showEditDialog(context, 'apellido2',
                          user.apellido2, 'Segundo Apellido'),
                    ),
                    _ProfileTile(
                      icon: Icons.phone_android_outlined,
                      label: 'Teléfono',
                      value: user.telefono.isNotEmpty
                          ? user.telefono
                          : 'No definido',
                      onTap: () => _showEditDialog(context, 'telefono',
                          user.telefono, 'Teléfono'),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _ProfileSection(
                  title: 'Datos de la Cuenta',
                  children: [
                    _ProfileTile(
                      icon: Icons.email_outlined,
                      label: 'Correo Electrónico',
                      value: user.email,
                      onTap: () => _showEditDialog(
                          context, 'email', user.email, 'Correo'),
                    ),
                    _ProfileTile(
                      icon: Icons.lock_outline,
                      label: 'Contraseña',
                      value: '********',
                      onTap: () => _showEditDialog(
                          context, 'password', '', 'Contraseña'),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _ProfileSection(
                  title: 'Preferencias',
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                          Icons.notifications_active_outlined,
                          color: colors.primary),
                      title: const Text('Notificaciones Email',
                          style: TextStyle(fontSize: 15)),
                      activeColor: colors.primary,
                      value: user.recibirNotiEmail,
                      onChanged: _isProcessing
                          ? null
                          : (val) =>
                              _updateData({'recibirNotiEmail': val}),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 25),
                // Número de hermano — fuera de sección para destacarlo
                _ProfileSection(
                  title: 'Hermandad',
                  children: [
                    _ProfileTile(
                      icon: Icons.verified_user,
                      label: 'Número de Hermano',
                      value: (user.numeroHermano == null ||
                              user.numeroHermano == 'No vinculado' ||
                              user.numeroHermano!.isEmpty)
                          ? 'Pulsa para vincular tu DNI'
                          : 'Nº ${user.numeroHermano}',
                      onTap: () => _showHermanoDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- COMPONENTES VISUALES ---

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 11,
                  letterSpacing: 1.1)),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _ProfileTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: primaryColor.withOpacity(0.1),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}