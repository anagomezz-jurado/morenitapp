import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/config/theme/main_background.dart';
import '../services/api_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainBackground(
      title: '¡Bienvenido!',
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const _LoginHeader(),
                const SizedBox(height: 40),
                const _LoginFormCard(),
                const SizedBox(height: 35),
                const _LoginFooter(),
              ],
            ),
          ),
        ),
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
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Image(
              image: AssetImage('assets/icono.png'), width: 90, height: 90),
        ),
        const SizedBox(height: 20),
        Text(
          '¡Bienvenido!',
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        const Text('Gestiona tu cuenta de forma fácil',
            style: TextStyle(color: Colors.black54, fontSize: 15)),
      ],
    );
  }
}

class _LoginFormCard extends StatefulWidget {
  const _LoginFormCard();

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, rellena todos los campos')));
      return;
    }

    setState(() => isLoading = true);

    final apiService = ApiService();
    final userResult = await apiService.login(email, password);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (userResult != null) {
      final int rol = userResult['rol_id'] ?? 0;
      // Redirección según rol
      if (rol == 1) {
        // 1 = Admin
        context.go('/');
      } else {
        // Otros roles
        context.go('/panel-usuario');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Email o contraseña incorrectos'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _CustomInput(
            label: 'Contraseña',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: passwordController,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton(
              onPressed: isLoading ? null : () => _onLogin(context),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Iniciar Sesión'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/panel-usuario'),
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
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _CustomInput({
    required this.label,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
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
        const Text("¿No eres miembro?",
            style: TextStyle(color: Colors.black54)),
        TextButton(
          onPressed: () => context.push('/registrarse'),
          child: const Text('Regístrate ahora',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
