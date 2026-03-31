import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';

class PanelUsuarioScreen extends ConsumerWidget {
  const PanelUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Si el user es null, es un invitado
    final bool isGuest = authState.user == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isGuest ? 'Panel de Invitado' : 'Mi Perfil'),
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authProvider.notifier).logout(),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _UserHeader(isGuest: isGuest, fullName: authState.user?.fullName),

            const Divider(),

            // --- SECCIÓN PÚBLICA (Todos la ven) ---
            _ListTileCustom(
              title: 'Información de la Hermandad',
              subtitle: 'Historia y noticias actuales',
              icon: Icons.info_outline,
              onTap: () { /* Navegar a info */ },
            ),

            // --- SECCIÓN RESTRINGIDA (Solo usuarios reales) ---
            if (isGuest) ...[
              // Cuadro informativo para invitar al registro
              const _GuestBanner(),
            ] else ...[
              // Funciones exclusivas para Rol 2
              _ListTileCustom(
                title: 'Mis Pagos y Cuotas',
                subtitle: 'Estado de cuenta de hermano',
                icon: Icons.payments_outlined,
                onTap: () => context.push('/pagos'),
              ),
              _ListTileCustom(
                title: 'Eventos Inscritos',
                subtitle: 'Mis próximas salidas procesionales',
                icon: Icons.event_available,
                onTap: () => context.push('/mis-eventos'),
              ),
            ],

            // --- BOTÓN DE ACCIÓN FINAL ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: isGuest 
                ? FilledButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Iniciar Sesión para ver más'),
                  )
                : const Text('Eres miembro activo', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para el encabezado
class _UserHeader extends StatelessWidget {
  final bool isGuest;
  final String? fullName;

  const _UserHeader({required this.isGuest, this.fullName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey.shade200,
            child: Icon(isGuest ? Icons.person_outline : Icons.person, size: 40),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGuest ? 'Hola, Invitado' : 'Hola, $fullName',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(isGuest ? 'Acceso limitado' : 'Hermano Activo'),
            ],
          )
        ],
      ),
    );
  }
}

// Widget para el banner de invitado
class _GuestBanner extends StatelessWidget {
  const _GuestBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.amber),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              'Las funciones de pagos y eventos están reservadas para hermanos registrados.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTileCustom extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ListTileCustom({
    required this.title, 
    required this.subtitle, 
    required this.icon, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      onTap: onTap,
    );
  }
}