import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/shared/widgets/menu_usuario.dart';
import 'package:morenitapp/shared/widgets/side_menu.dart';

class PanelUsuarioScreen extends ConsumerWidget {
  const PanelUsuarioScreen({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;
    final eventosAsync = ref.watch(eventosProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuUsuario(scaffoldKey: _scaffoldKey),
      body: _MainContent(
        colors: colors,
        user: user,
        eventosAsync: eventosAsync,
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final ColorScheme colors;
  final User? user;
  final AsyncValue<List<Evento>> eventosAsync;

  const _MainContent({
    required this.colors,
    required this.user,
    required this.eventosAsync,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header con Botón Menú
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BANNER DE BIENVENIDA + Nº HERMANO
                  _WelcomeBanner(user: user, colors: colors),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Accesos Directos'),
                  
                  // GRID DE FUNCIONES (Punto 5.5)
                  _QuickActionsGrid(colors: colors),

                  const SizedBox(height: 25),
                  const _SectionTitle(title: 'Próximo Evento'),

                  eventosAsync.when(
                    data: (eventos) => eventos.isEmpty 
                        ? const _NoEventsWidget() 
                        : _EventTile(
                            title: eventos.first.nombre,
                            date: eventos.first.fechaInicio.toString().substring(0, 10),
                            icon: Icons.event_available_rounded,
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('No se pudieron cargar los eventos'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.notes_rounded, size: 30),
          onPressed: () => PanelUsuarioScreen._scaffoldKey.currentState?.openDrawer(),
        ),
      ),
    );
  }
}

// Widget del Banner mejorado con el Número de Hermano
class _WelcomeBanner extends StatelessWidget {
  final User? user;
  final ColorScheme colors;
  const _WelcomeBanner({required this.user, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.primaryContainer]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paz y Bien,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
          Text('${user?.nombre ?? "Hermano"}', 
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          // ETIQUETA Nº HERMANO (Si existe en tu entidad user)
          if (user?.id != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Número de Hermano: #${user!.id}', // Cambia 'id' por el campo real de tu DB
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

// Grid de accesos rápidos para Perfil, Libros y Eventos
class _QuickActionsGrid extends StatelessWidget {
  final ColorScheme colors;
  const _QuickActionsGrid({required this.colors});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _QuickActionItem(icon: Icons.person_outline, label: 'Mi Perfil', color: colors.primary),
        _QuickActionItem(icon: Icons.menu_book_outlined, label: 'Libros', color: Colors.blueGrey),
        _QuickActionItem(icon: Icons.calendar_today_outlined, label: 'Eventos', color: Colors.brown),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickActionItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}


// --- SUB-WIDGETS ---

class _NoEventsWidget extends StatelessWidget {
  const _NoEventsWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'No hay próximos eventos',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );
}

class _ActivityCard extends StatelessWidget {
  final String description;
  final String time;
  const _ActivityCard({required this.description, required this.time});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.grey.shade100,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      title: Text(description, style: const TextStyle(fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_right),
    ),
  );
}

class _EventTile extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  const _EventTile({required this.title, required this.date, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF051906),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}