import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/config/router/app_router_notifier.dart';

// Screens
import 'package:morenitapp/features/auth/presentation/screens/inicio_sesion_screen.dart';
import 'package:morenitapp/features/auth/presentation/screens/registrar_screen.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/screens/grupo_proveedor_screen.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/screens/roles_screen.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/screens/tipo_autoridad_screen.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/screens/tipo_cargo_screen.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/screens/tipo_evento_screen.dart';
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/screens/usuarios_screen.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/screens/calendario_eventos_screen.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/screens/eventos_gestion_screen.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/screens/organizadores_screen.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/screens/hermano_activo_listado_screen.dart';
import 'package:morenitapp/features/panel-gestion/home_screen.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/screens/nuevo_hermano.dart';
import 'package:morenitapp/features/panel-gestion/libros/presentation/screens/libros_screens.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/screens/anunciantes_screen.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/screens/proveedores_screen.dart';
import 'package:morenitapp/features/panel-gestion/secretaria/presentation/screens/autoridad_screen.dart';
import 'package:morenitapp/features/panel-gestion/secretaria/presentation/screens/cargos_screen.dart';
import 'package:morenitapp/features/panel-gestion/secretaria/presentation/screens/cofradias_screen.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/calle_screen.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/codigo_postal_screen.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/localidad_screen.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/provincia_screen.dart';
import 'package:morenitapp/features/panel_usuario/screens/panel_usuario_screen.dart';

// Providers
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
final goRouterProvider = Provider<GoRouter>((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: goRouterNotifier,
    routes: [
      
      // =============================================================
      // ACCESO Y AUTENTICACIÓN
      // =============================================================
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/registrarse',
        builder: (context, state) => const RegisterScreen(),
      ),

      // =============================================================
      // DASHBOARD (INICIO)
      // =============================================================
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // =============================================================
      // GESTIÓN DE HERMANOS
      // =============================================================
      GoRoute(
        path: '/hermanos-activos',
        builder: (context, state) => const HermanoActivoListadoScreen(),
      ),
      GoRoute(
        path: '/hermanos-no-activos',
        builder: (context, state) => const HermanoActivoListadoScreen(),
      ),
      GoRoute(
        path: '/nuevo-hermano',
        builder: (context, state) {
          final hermano = (state.extra is Hermano) ? state.extra as Hermano : null;
          return NuevoHermano(hermanoAEditar: hermano);
        },
      ),

      // =============================================================
      // SECRETARÍA
      // =============================================================
      GoRoute(
        path: '/autoridades',
        builder: (context, state) => const AutoridadesScreen(),
      ),
      GoRoute(
        path: '/cargos',
        builder: (context, state) => const CargosScreen(),
      ),
      GoRoute(
        path: '/cofradias',
        builder: (context, state) => const CofradiasScreen(),
      ),

       GoRoute(
        path: '/libros',
        builder: (context, state) => const LibrosScreen(),
      ),

      // =============================================================
      // EVENTOS Y CULTOS
      // =============================================================
      GoRoute(
        path: '/calendario',
        builder: (context, state) => const CalendarioEventosScreen(),
      ),
      GoRoute(
        path: '/gestion-eventos',
        builder: (context, state) => const EventosGestionScreen(),
      ),
      GoRoute(
        path: '/organizadores',
        builder: (context, state) => const OrganizadoresScreen(),
      ),

      // =============================================================
      // PROVEEDORES
      // =============================================================
      GoRoute(
        path: '/proveedores',
        builder: (context, state) => const ProveedoresScreen(),
      ),
      GoRoute(
        path: '/anunciantes',
        builder: (context, state) => const AnunciantesScreen(),
      ),

      // =============================================================
      // UBICACIONES
      // =============================================================
      GoRoute(
        path: '/provincia',
        builder: (context, state) => const ProvinciaScreen(),
      ),
      GoRoute(
        path: '/localidad',
        builder: (context, state) => const LocalidadScreen(),
      ),
      GoRoute(
        path: '/codigo-postal',
        builder: (context, state) => const CodigoPostalScreen(),
      ),
      GoRoute(
        path: '/calle',
        builder: (context, state) => const CallesGestionScreen(),
      ),

      // =============================================================
      // GESTIÓN DE USUARIOS / PANEL
      // =============================================================
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const UsuariosScreen(),
      ),
      GoRoute(
        path: '/panel-usuario',
        builder: (context, state) => const PanelUsuarioScreen(),
      ),

      // =============================================================
      // CONFIGURACIÓN (TIPOS Y MAESTROS)
      // =============================================================
      GoRoute(
        path: '/tipo-evento',
        builder: (context, state) => const TipoEventoScreen(),
      ),
      GoRoute(
        path: '/tipo-autoridades',
        builder: (context, state) => const TipoAutoridadScreen(),
      ),
      GoRoute(
        path: '/tipo-cargos',
        builder: (context, state) => const TipoCargoScreen(),
      ),
      GoRoute(
        path: '/grupo-proveedor',
        builder: (context, state) => const GrupoProveedorScreen(),
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RolesScreen(),
      ),
    ],

    // --- LÓGICA DE REDIRECCIÓN ---
    redirect: (context, state) {
      final isGoingTo = state.matchedLocation;
      final authStatus = goRouterNotifier.authStatus;

      if ((isGoingTo == '/login' || isGoingTo == '/registrarse') &&
          authStatus == AuthStatus.authenticated) return '/';

      if (isGoingTo == '/panel-usuario') return null;

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo != '/login' && isGoingTo != '/registrarse') return '/login';
      }

      return null;
    },
  );
});