import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/config/theme/app_theme.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/auth/presentation/providers/login_form_provider.dart';
// Asegúrate de importar MainBackground si es un widget personalizado
// import 'package:morenitapp/shared/widgets/main_background.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- LÓGICA DE REDIRECCIÓN POR ROLES ---
    ref.listen(authProvider, (previous, next) {
  if (next.errorMessage.isNotEmpty) {
    showSnackbar(context, next.errorMessage);
  }

      // 2. Si el estado cambia a autenticado, verificamos el rol
      if (next.authStatus == AuthStatus.authenticated && next.user != null) {
        final rolId =
            next.user!.rolId; // Asumiendo que tu entidad User tiene rolId

        if (rolId == 1) {
          // Admin o Rol 1 -> Dashboard Principal
          context.go('/');
        } else if (rolId == 2) {
          // Usuario o Rol 2 -> Panel de Usuario
          context.go('/panel-usuario');
        } else {
          // Opcional: Manejo de otros roles o error
          context.go('/panel-usuario');
        }
      }
    });
    return MainBackground(
      title: '¡Bienvenido a MorenitApp!',
      headerIcon: Image.asset('assets/icono.png', width: 80, height: 80),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Gestiona tu cuenta de forma fácil',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 30),
          const _LoginFormCard(),
          const SizedBox(height: 20),
          const _LoginFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: const Image(
            image: AssetImage('assets/icono.png'),
            width: 80,
            height: 80,
            errorBuilder: null, // Evita que explote si no existe la imagen aún
          ),
        ),
        const SizedBox(height: 15),
        const Text('Gestiona tu cuenta de forma fácil',
            style: TextStyle(color: Colors.black54, fontSize: 15)),
      ],
    );
  }
}

class _LoginFormCard extends ConsumerWidget {
  const _LoginFormCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        children: [
          _CustomInput(
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: ref.read(loginFormProvider.notifier).onEmailChange,
            errorMessage:
                loginForm.isFormPosted ? loginForm.email.errorMessage : null,
          ),
          const SizedBox(height: 16),
          _CustomInput(
            label: 'Contraseña',
            icon: Icons.lock_outline,
            obscureText: true,
            onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
            onFieldSubmitted: (_) =>
                ref.read(loginFormProvider.notifier).onFormSubmit(),
            errorMessage:
                loginForm.isFormPosted ? loginForm.password.errorMessage : null,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: primaryColor),
              onPressed: loginForm.isPosting
                  ? null
                  : ref.read(loginFormProvider.notifier).onFormSubmit,
              child: loginForm.isPosting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Iniciar Sesión',
                      style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).loginAsGuest();
                
              },
              icon: const Icon(Icons.person_search_outlined),
              label: const Text('Continuar como invitado'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? errorMessage;

  const _CustomInput({
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onFieldSubmitted,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorMessage,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("¿No eres miembro?"),
        TextButton(
          onPressed: () => context.push('/registrarse'),
          child: const Text('Regístrate ahora',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
