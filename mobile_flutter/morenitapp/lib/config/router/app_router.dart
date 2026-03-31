import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/config/router/app_router_notifier.dart';

// Screens
import 'package:morenitapp/features/auth/presentation/screens/inicio_sesion_screen.dart';
import 'package:morenitapp/features/auth/presentation/screens/registrar_screen.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/screens/hermano_activo_listado_screen.dart';
import 'package:morenitapp/features/panel-gestion/home_screen.dart';
import 'package:morenitapp/features/panel-gestion/hermanos/presentation/screens/nuevo_hermano.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/calle_screen.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/codigo_postal_screen.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/localidad_screen.dart';
import 'package:morenitapp/features/panel-gestion/ubicaciones/presentation/screens/provincia_screen.dart';
import 'package:morenitapp/features/panel_usuario/screens/panel_usuario_screen.dart';

// Providers
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
// Asegúrate de tener este provider que maneja la lógica de redirección
// import 'package:morenitapp/config/router/go_router_notifier.dart'; 

final goRouterProvider = Provider((ref) {
  
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: goRouterNotifier,
    routes: [
     
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(), 
      ),
      GoRoute(
        path: '/registrarse',
        builder: (context, state) => const RegisterScreen(),
      ),
      //Panel de Gestión de la Cofradía
       GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
       GoRoute(
        path: '/hermanos-activos',
        builder: (context, state) => const HermanoActivoListadoScreen(),
      ),
      GoRoute(
        path: '/nuevo-hermano',
        builder: (context, state) => const NuevoHermano(),
      ),
      GoRoute(
        path: '/hermanos-no-activos',
        builder: (context, state) => const HermanoActivoListadoScreen(),
      ),
      //Gestión de Ubicaciones
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
      //Panel de usuarios
      GoRoute(
        path: '/panel-usuario',
        builder: (context, state) => const PanelUsuarioScreen(),
      ),
    ],
    
    redirect: (context, state) {
      final isGoingTo = state.matchedLocation;
      final authStatus = goRouterNotifier.authStatus;

      // 1. Si ya estoy autenticado y trato de ir a login/registro, mándame al Home
      if ((isGoingTo == '/login' || isGoingTo == '/registrarse') && 
          authStatus == AuthStatus.authenticated) return '/';
      
      // 2. EXCEPCIÓN PARA EL PANEL DE USUARIO (Modo Invitado)
      // Si el usuario va al panel, permitimos que pase aunque no esté autenticado
      if (isGoingTo == '/panel-usuario') return null;

      // 3. Protección de rutas privadas (como el Home)
      if (authStatus == AuthStatus.notAuthenticated) {
        // Si no está en login/registro, lo obligamos a ir a login
        if (isGoingTo != '/login' && isGoingTo != '/registrarse') return '/login';
      }

      // En cualquier otro caso, no redirigir
      return null;
    },
  ); 
});