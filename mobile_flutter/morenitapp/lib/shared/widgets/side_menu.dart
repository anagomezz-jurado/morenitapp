import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/shared/widgets/custom_filled_button.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});

  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final textStyles = Theme.of(context).textTheme;
    final user = ref.watch(authProvider).user;

    return NavigationDrawer(
      elevation: 1,
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (value) {
        setState(() => navDrawerIndex = value);
        widget.scaffoldKey.currentState?.closeDrawer();
      },
      children: [
        // --- CABECERA ---
        Padding(
          padding: EdgeInsets.fromLTRB(20, hasNotch ? 0 : 20, 16, 0),
          child: Text('Saludos', style: textStyles.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
          child:
              Text(user?.fullName ?? 'Usuario', style: textStyles.titleSmall),
        ),

        // --- DASHBOARD (DESTINO PRINCIPAL) ---
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Dashboard'),
        ),

        const Divider(indent: 28, endIndent: 28),

        // --- GESTIÓN DE HERMANOS ---
        CustomExpansionTile(
          icon: Icons.person_outline_outlined,
          title: 'Gestión de Hermanos',
          children: [
            _buildSubTile(
              icon: Icons.person_add_alt_sharp,
              label: 'Listado de Hermanos activos',
              onTap: () => context.push(
                  '/hermanos-activos'),
            ),
            _buildSubTile(
              icon: Icons.person_add_disabled_sharp,
              label: 'Listado de Hermanos no activos',
              onTap: () {},
            ),
          ],
        ),

        const Divider(indent: 28, endIndent: 28),

        // --- SECRETARÍA ---
        CustomExpansionTile(
          icon: Icons.document_scanner_rounded,
          title: 'Secretaría',
          children: [
            // BOTÓN DIRECTO A PANTALLA DE AUTORIDADES
            _buildSubTile(
              icon: Icons.gavel_rounded,
              label: 'Autoridades',
              onTap: () => context.push(
                  '/autoridades'), // Esta pantalla contendrá "Tipos de autoridades"
            ),

            // BOTÓN DIRECTO A PANTALLA DE CARGOS
            _buildSubTile(
              icon: Icons.badge_rounded,
              label: 'Cargos',
              onTap: () => context
                  .push('/cargos'), // Esta pantalla contendrá "Tipos de cargos"
            ),

            // BOTÓN DIRECTO A COFRADÍAS
            _buildSubTile(
              icon: Icons.account_balance_rounded,
              label: 'Cofradías',
              onTap: () => context.push('/cofradias'),
            ),
          ],
        ),

        const Divider(indent: 28, endIndent: 28),

        // --- EVENTOS ---
        CustomExpansionTile(
          icon: Icons.event_available_rounded,
          title: 'Eventos y cultos',
          children: [
            CustomExpansionTile(
              icon: Icons.edit_calendar_rounded,
              title: 'Gestión de Eventos',
              children: [
                _buildSubTile(
                  icon: Icons.calendar_month_rounded,
                  label: 'Calendario',
                  onTap: () {},
                  leftPadding: 40,
                ),
                _buildSubTile(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Crear evento',
                  onTap: () {},
                  leftPadding: 40,
                ),
              ],
            ),
            _buildSubTile(
              icon: Icons.groups_rounded,
              label: 'Gestión de Organizadores',
              onTap: () {},
            ),
          ],
        ),

        const Divider(indent: 28, endIndent: 28),

        // --- PUBLICACIONES ---
        CustomExpansionTile(
          icon: Icons.menu_book_rounded,
          title: 'Publicaciones y Libro',
          children: [
            _buildSubTile(
                icon: Icons.book_rounded, label: 'Libro', onTap: () {}),
            _buildSubTile(
                icon: Icons.newspaper_rounded,
                label: 'Publicaciones',
                onTap: () {}),
          ],
        ),

        const Divider(indent: 28, endIndent: 28),

        // --- UBICACIONES ---
        CustomExpansionTile(
          icon: Icons.map_rounded,
          title: 'Ubicaciones',
          children: [
            _buildSubTile(
                icon: Icons.location_city_rounded,
                label: 'Provincias',
                onTap: () => context.push(
                  '/provincia')),
            _buildSubTile(
                icon: Icons.rebase_edit, label: 'Localidades', onTap: () => context.push('/localidad')),
            _buildSubTile(
                icon: Icons.mark_as_unread, label: 'C. Postales', onTap: () => context.push('/codigo-postal')),
            _buildSubTile(
                icon: Icons.add_road_rounded, label: 'Calles', onTap: () => context.push('/calle')),
          ],
        ),

        const Divider(indent: 28, endIndent: 28),

        // --- PANEL USUARIOS ---
        CustomExpansionTile(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Gestión de Panel',
          children: [
            _buildSubTile(
                icon: Icons.alarm_on_rounded,
                label: 'Recordatorios',
                onTap: () {}),
            _buildSubTile(
                icon: Icons.notification_add_rounded,
                label: 'Comunicados',
                onTap: () {}),
            _buildSubTile(
                icon: Icons.folder_copy_rounded,
                label: 'Documentos',
                onTap: () {}),
            _buildSubTile(
                icon: Icons.collections_rounded,
                label: 'Galería',
                onTap: () {}),
          ],
        ),

        const Divider(indent: 28, endIndent: 28),

        // --- CONFIGURACIÓN ---
        CustomExpansionTile(
          icon: Icons.settings_suggest_rounded,
          title: 'Configuración',
          children: [
            _buildSubTile(
                icon: Icons.category_rounded,
                label: 'Tipo de evento',
                onTap: () {}),
            _buildSubTile(
                icon: Icons.handshake_rounded,
                label: 'Proveedores',
                onTap: () {}),
            _buildSubTile(
                icon: Icons.handshake_rounded,
                label: 'Tipos de autoridades',
                onTap: () {}),
            _buildSubTile(
                icon: Icons.handshake_rounded,
                label: 'Tipos de cargos',
                onTap: () {}),
          ],
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),

        // --- BOTONES FINALES ---
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 10, 16, 10),
          child: Text('Otras opciones'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomFilledButton(
            onPressed: () {
              widget.scaffoldKey.currentState?.closeDrawer();
              context.push('/panel-usuario');
            },
            text: 'Ir a panel de usuarios',
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomFilledButton(
              onPressed: () {
                widget.scaffoldKey.currentState?.closeDrawer();
                ref.read(authProvider.notifier).logout();
              },
              text: 'Cerrar sesión'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- HELPER PARA CREAR LOS HIJOS CON DISEÑO DE NAVIGATION DRAWER ---
  Widget _buildSubTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double leftPadding = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, right: 8, bottom: 2),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        leading: Icon(icon, size: 22),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        onTap: () {
          onTap();
          widget.scaffoldKey.currentState?.closeDrawer();
        },
      ),
    );
  }
}

// --- CLASE DEL EXPANSIBLE PERSONALIZADO ---
class CustomExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const CustomExpansionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, color: colors.onSurfaceVariant),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
                fontSize: 15)),
        iconColor: colors.primary,
        collapsedIconColor: colors.onSurfaceVariant,
        childrenPadding: const EdgeInsets.only(left: 16, bottom: 4),
        children: children,
      ),
    );
  }
}
