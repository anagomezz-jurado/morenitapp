import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/shared/widgets/plantilla_ventanas.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;

    return PlantillaVentanas(
      title: 'Mi Perfil',
      // No enviamos columnas ni filas para que la plantilla use el customBody
      columns: null, 
      rows: null,
      customBody: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- SECCIÓN: DATOS DE CUENTA ---
            _ProfileSection(
              title: 'Datos de la Cuenta',
              children: [
                _ProfileTile(
                  icon: Icons.email_outlined,
                  label: 'Correo Electrónico',
                  value: user?.email ?? 'No disponible',
                  onTap: () => _showEditDialog(context, 'Correo', user?.email ?? ''),
                ),
                _ProfileTile(
                  icon: Icons.lock_outline,
                  label: 'Contraseña',
                  value: '********',
                  onTap: () => _showEditDialog(context, 'Contraseña', ''),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- SECCIÓN: PREFERENCIAS ---
            _ProfileSection(
              title: 'Preferencias',
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.notifications_active_outlined, color: colors.primary),
                  title: const Text('Recibir Notificaciones', style: TextStyle(fontSize: 15)),
                  activeColor: colors.primary,
                  value: true, 
                  onChanged: (val) {
                    // Implementar lógica de guardado de preferencias
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- SECCIÓN: HERMANDAD ---
            _ProfileSection(
              title: 'Hermandad',
              children: [
                _ProfileTile(
                  icon: Icons.badge_outlined,
                  label: 'Vincular ficha de hermano',
                  value: 'Verifica tus datos con la cofradía',
                  onTap: () => _showVincularHermanoSheet(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGOS Y SHEETS ---
  
  void _showEditDialog(BuildContext context, String campo, String valorActual) {
    final controller = TextEditingController(text: campo == 'Contraseña' ? '' : valorActual);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Modificar $campo'),
        content: TextField(
          controller: controller,
          obscureText: campo == 'Contraseña',
          decoration: InputDecoration(
            labelText: 'Nuevo $campo',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
          )
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar')
          ),
          ElevatedButton(
            onPressed: () {
              // Lógica de actualización aquí
              Navigator.pop(context);
            }, 
            child: const Text('Guardar')
          ),
        ],
      ),
    );
  }

  void _showVincularHermanoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
              const Text('Verificación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text(
                'Introduce tu identificación oficial para localizar tu ficha en la base de datos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'DNI / NIE', 
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                )
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Vincular')
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SUB-COMPONENTES VISUALES ---

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
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              color: Colors.blueGrey, 
              fontSize: 11, 
              letterSpacing: 1.2
            )
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
            ],
            border: Border.all(color: Colors.grey.shade200)
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
  const _ProfileTile({
    required this.icon, 
    required this.label, 
    required this.value, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: primaryColor.withOpacity(0.1),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(
        label, 
        style: const TextStyle(fontSize: 12, color: Colors.grey)
      ),
      subtitle: Text(
        value, 
        style: const TextStyle(
          fontSize: 15, 
          fontWeight: FontWeight.bold, 
          color: Colors.black87
        )
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}