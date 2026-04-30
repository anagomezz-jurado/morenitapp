import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Config & Redirection
import 'package:morenitapp/config/router/app_router_notifier.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';

// --- DOMAIN ENTITIES ---
import 'package:morenitapp/features/panel-gestion/hermanos/domain/entities/hermano.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/evento.dart';
import 'package:morenitapp/features/panel-gestion/eventos-cultos/domain/entities/organizador.dart';
import 'package:morenitapp/features/panel-gestion/proveedores/domain/entities/proveedor.dart';
import 'package:morenitapp/features/panel-gestion/secretaria/domain/entities/autoridad.dart';
import 'package:morenitapp/features/panel-gestion/secretaria/domain/entities/cargo.dart';
import 'package:morenitapp/features/panel-gestion/secretaria/domain/entities/cofradia.dart';

// --- SCREENS ---
// Auth
import 'package:morenitapp/features/auth/presentation/screens/inicio_sesion_screen.dart';
import 'package:morenitapp/features/auth/presentation/screens/registrar_screen.dart';

// Panel Gestión: Core
import 'package:morenitapp/features/panel-gestion/home_screen.dart';
import 'package:morenitapp/features/panel-gestion/usuarios/presentation/screens/usuarios_screen.dart';

// Panel Gestión: Hermanos
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/screens/import_hermanos_screens.dart';

// Panel Gestión: Eventos y Cultos
import 'package:morenitapp/features/panel-gestion/eventos-cultos/presentation/screens/import_eventos_cultos.dart';

// Panel Gestión: Secretaría (Autoridades, Cargos, Cofradías)
import 'package:morenitapp/features/panel-gestion/secretaria/presentation/screens/imports_secretaria_screens.dart';

// Panel Gestión: Proveedores y Anunciantes
import 'package:morenitapp/features/panel-gestion/proveedores/presentation/screens/imports_proveedores.dart';


// Panel Gestión: Libros, Ubicaciones y Configuración
import 'package:morenitapp/features/panel-gestion/configuracion/presentation/screens/import_configuracion.dart';
import 'package:morenitapp/features/panel-gestion/libros/presentation/screens/libros_screens.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/imports_ubicaciones_screens.dart';

// Panel Usuario
import 'package:morenitapp/features/panel_usuario/screens/panel_usuario_screen.dart';
import 'package:morenitapp/features/panel_usuario/perfil/screens/perfil-screen.dart';
import 'package:morenitapp/features/panel_usuario/perfil/screens/libro-screen.dart';
import 'package:morenitapp/features/panel_usuario/perfil/screens/notificaciones_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: goRouterNotifier,
    routes: [
      // ACCESO Y AUTENTICACIÓN
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/registrarse', builder: (_, __) => const RegisterScreen()),

      // DASHBOARD ADMINISTRACIÓN
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),

      // GESTIÓN DE HERMANOS
      GoRoute(path: '/hermanos-activos', builder: (_, __) => const HermanoActivoListadoScreen()),
      GoRoute(path: '/hermanos-no-activos', builder: (_, __) => const HermanoNoActivoListadoScreen()),
      GoRoute(
        path: '/nuevo-hermano',
        builder: (context, state) {
          final hermano = (state.extra is Hermano) ? state.extra as Hermano : null;
          return NuevoHermano(hermanoAEditar: hermano);
        }
      ),

      // SECRETARÍA: Autoridades
      GoRoute(path: '/autoridades', builder: (_, __) => const AutoridadesScreen()),
      GoRoute(path: '/secretaria/autoridades/nueva', builder: (_, __) => const AutoridadFormScreen()),
      GoRoute(
        path: '/secretaria/autoridades/editar',
        builder: (context, state) {
          final autoridad = (state.extra is Autoridad) ? state.extra as Autoridad : null;
          return AutoridadFormScreen(autoridadAEditar: autoridad);
        }
      ),

      // SECRETARÍA: Cargos
      GoRoute(path: '/cargos', builder: (_, __) => const CargosScreen()),
      GoRoute(path: '/secretaria/cargos/nuevo', builder: (_, __) => const CargoFormScreen()),
      GoRoute(
        path: '/secretaria/cargos/editar',
        builder: (context, state) {
          final cargo = (state.extra is Cargo) ? state.extra as Cargo : null;
          return CargoFormScreen(cargoAEditar: cargo);
        }
      ),

      // SECRETARÍA: Cofradías
      GoRoute(path: '/cofradias', builder: (_, __) => const CofradiasScreen()),
      GoRoute(path: '/secretaria/cofradias/nueva', builder: (_, __) => const CofradiaFormScreen()),
      GoRoute(
        path: '/secretaria/cofradias/editar',
        builder: (context, state) {
          final cofradia = (state.extra is Cofradia) ? state.extra as Cofradia : null;
          return CofradiaFormScreen(cofradiaAEditar: cofradia);
        }
      ),

      // EVENTOS Y CULTOS
      GoRoute(path: '/calendario', builder: (_, __) => const CalendarioEventosScreen()),
      GoRoute(path: '/gestion-eventos', builder: (_, __) => const EventosGestionScreen()),
      GoRoute(path: '/panel-gestion/eventos-cultos/eventos/nuevo', builder: (_, __) => const NuevoEvento()),
      GoRoute(
        path: '/panel-gestion/eventos-cultos/eventos/editar',
        builder: (context, state) {
          final evento = (state.extra is Evento) ? state.extra as Evento : null;
          return NuevoEvento(eventoAEditar: evento);
        },
      ),

      // ORGANIZADORES
      GoRoute(path: '/organizadores', builder: (_, __) => const OrganizadoresScreen()),
      GoRoute(path: '/panel-gestion/eventos-cultos/organizadores/nuevo', builder: (_, __) => const NuevoOrganizador()),
      GoRoute(
        path: '/panel-gestion/eventos-cultos/organizadores/editar',
        builder: (context, state) {
          final organizador = (state.extra is Organizador) ? state.extra as Organizador : null;
          return NuevoOrganizador(organizadorAEditar: organizador);
        }
      ),

      // PROVEEDORES Y ANUNCIANTES
      GoRoute(path: '/anunciantes', builder: (_, __) => const AnunciantesScreen()),
      GoRoute(
        path: '/proveedores',
        builder: (_, __) => const ProveedoresScreen(),
        routes: [
          GoRoute(
            path: 'nuevo',
            builder: (context, state) {
              final extras = state.extra as Map<String, dynamic>?;
              final forcedAnunciante = extras?['forcedAnunciante'] ?? false;
              return ProveedorFormScreen(forcedAnunciante: forcedAnunciante);
            },
          ),
          GoRoute(
            path: 'editar',
            builder: (context, state) {
              final proveedor = state.extra as Proveedor;
              return ProveedorFormScreen(proveedorAEditar: proveedor, forcedAnunciante: false);
            },
          ),
        ],
      ),

      // UBICACIONES
      GoRoute(path: '/provincia', builder: (_, __) => const ProvinciaScreen()),
      GoRoute(path: '/localidad', builder: (_, __) => const LocalidadScreen()),
      GoRoute(path: '/codigo-postal', builder: (_, __) => const CodigoPostalScreen()),
      GoRoute(path: '/calle', builder: (_, __) => const CallesGestionScreen()),

      // CONFIGURACIÓN Y ADMINISTRACIÓN DE SISTEMA
      GoRoute(path: '/usuarios', builder: (_, __) => const UsuariosScreen()),
      GoRoute(path: '/libros', builder: (_, __) => const LibrosScreen()),
      GoRoute(path: '/tipo-evento', builder: (_, __) => const TipoEventoScreen()),
      GoRoute(path: '/tipo-autoridades', builder: (_, __) => const TipoAutoridadScreen()),
      GoRoute(path: '/tipo-cargos', builder: (_, __) => const TipoCargoScreen()),
      GoRoute(path: '/tipo-notificacion', builder: (_, __) => TiposNotificacionScreen()),
      GoRoute(path: '/grupo-proveedor', builder: (_, __) => const GrupoProveedorScreen()),
      GoRoute(path: '/roles', builder: (_, __) => const RolesScreen()),

      // PANEL DE USUARIO FINAL
      GoRoute(path: '/panel-usuario', builder: (_, __) => const PanelUsuarioScreen()),
      GoRoute(path: '/mi-perfil', builder: (_, __) => const PerfilScreen()),
      GoRoute(path: '/listado-libros', builder: (_, __) => const LibrosListadoScreen()),
      GoRoute(path: '/notificaciones-usuario', builder: (_, __) => const NotificacionesUsuarioScreen()),
      GoRoute(path: '/notificacion', builder: (_, __) => const NotificacionesScreen()),
    ],

    // --- LÓGICA DE REDIRECCIÓN ---
    redirect: (context, state) {
      final isGoingTo = state.matchedLocation;
      final authStatus = authState.authStatus;
      final user = authState.user;
      final isGuest = user?.rolId == 3;

      // 1. NO autenticado
      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo != '/login' && isGoingTo != '/registrarse') return '/login';
        return null;
      }

      // 2. Autenticado
      if (authStatus == AuthStatus.authenticated) {
        // Bloquear Login/Registro si ya está dentro
        if (isGoingTo == '/login' || isGoingTo == '/registrarse') {
          return (user?.isAdmin == true) ? '/' : '/panel-usuario';
        }

        // Caso Invitado
        if (isGuest) {
          if (isGoingTo == '/mi-perfil') return '/registrarse';
          
          const allowedGuestRoutes = [
            '/panel-usuario', '/calendario', '/gestion-eventos', 
            '/listado-libros', '/notificaciones-usuario'
          ];
          if (!allowedGuestRoutes.contains(isGoingTo)) return '/panel-usuario';
        }

        // Caso Usuario Normal (No Admin)
        if (user?.isAdmin != true && !isGuest) {
          const allowedUserRoutes = [
            '/panel-usuario', '/mi-perfil', '/listado-libros', 
            '/gestion-eventos', '/calendario', '/notificaciones-usuario'
          ];
          if (!allowedUserRoutes.contains(isGoingTo)) return '/panel-usuario';
        }

        // Caso Admin (Acceso total)
        if (user?.isAdmin == true) return null;
      }

      return null;
    },
  );
});