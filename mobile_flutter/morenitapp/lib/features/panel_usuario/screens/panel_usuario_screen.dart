import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/providers/evento_culto_provider.dart';
import 'package:morenitapp/shared/widgets/menu_usuario.dart';

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
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Ajusta al contenido mínimo
                children: [
                  _WelcomeBanner(user: user, colors: colors),

                  const SizedBox(height: 20), // Espacio reducido
                  const _SectionTitle(title: 'Recordatorios Importantes'),
                  const _RemindersSection(),

                  const SizedBox(height: 20), // Espacio reducido
                  const _SectionTitle(title: 'Accesos Directos'),
                  
                  // Quitamos el SizedBox grande y dejamos que el Grid se ajuste
                  _QuickActionsGrid(colors: colors),

                  // Reducimos este espacio que es el que mencionas entre Grid y Próximo Evento
                  const SizedBox(height: 10), 
                  
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
                  const SizedBox(height: 20),
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

// --- NUEVO WIDGET: SECCIÓN DE RECORDATORIOS ---
class _RemindersSection extends StatelessWidget {
  const _RemindersSection();

  @override
  Widget build(BuildContext context) {
    // Estos datos podrían venir de un provider en el futuro
    final notifications = [
      {
        'title': 'Cuota Pendiente',
        'desc': 'Recuerda regularizar tu cuota anual antes del viernes.',
        'icon': Icons.priority_high_rounded,
        'color': Colors.orange.shade800,
        'bg': Colors.orange.shade50,
      },
      {
        'title': 'Reparto de Túnicas',
        'desc': 'Ya puedes solicitar tu cita para el tallaje.',
        'icon': Icons.info_outline_rounded,
        'color': Colors.blue.shade800,
        'bg': Colors.blue.shade50,
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item['bg'] as Color,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: (item['color'] as Color).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (item['color'] as Color).withOpacity(0.2),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item['color'] as Color,
                            fontSize: 14),
                      ),
                      Text(
                        item['desc'] as String,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- SUB-WIDGETS ---

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
          if (user?.numeroHermano != null && user!.numeroHermano != 'No vinculado' && user!.numeroHermano!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text('Hermano Nº ${user!.numeroHermano}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () => context.push('/mi-perfil'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white38),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_rounded, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text('Vincular número de hermano', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class _QuickActionsGrid extends StatelessWidget {
  final ColorScheme colors;
  const _QuickActionsGrid({required this.colors});

  @override
  Widget build(BuildContext context) {
    // Usamos una Row en lugar de GridView para eliminar el espacio vertical fantasma
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuickActionItem(
            icon: Icons.person_outline, 
            label: 'Mi Perfil', 
            color: colors.primary, 
            onTap: () => context.push('/mi-perfil')
          ),
          _QuickActionItem(
            icon: Icons.menu_book_outlined, 
            label: 'Libros', 
            color: colors.primary, 
            onTap: () => context.push('/listado-libros')
          ),
          _QuickActionItem(
            icon: Icons.calendar_today_outlined, 
            label: 'Eventos', 
            color: colors.primary, 
            onTap: () => context.push('/calendario')
          ),
        ],
      ),
    );
  }
}

// --- AJUSTE EN EL ITEM (PARA QUE NO OCUPE TANTO ALTO) ---
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionItem({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ocupa solo lo necesario
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4), // Reducido de 8 a 4
          Text(label, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
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
        color: const Color(0xFF051906), // Color oscuro para resaltar
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
        child: Text('No hay próximos eventos', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      ),
    );
  }
}