import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/config/theme/app_theme.dart';
import 'package:morenitapp/features/auth/presentation/providers/register_form_provider.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // Escuchamos el estado de auth para mostrar errores
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.errorMessage), backgroundColor: Colors.red)
      );
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: const MainBackground(
        title: 'Únete a MorenitApp',
        centerTitle: true,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10),
              _LogoHeader(),
              SizedBox(height: 10),
              _RegisterFormCard(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterFormCard extends ConsumerWidget {
  const _RegisterFormCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CustomInput(
            label: 'Nombre completo',
            icon: Icons.person_outline,
            onChanged: notifier.onFullNameChange, // O nombre si lo tienes separado
            errorMessage: registerForm.isFormPosted ? registerForm.fullName.errorMessage : null,
          ),
          const SizedBox(height: 16),

          _CustomInput(
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.onEmailChange,
            errorMessage: registerForm.isFormPosted ? registerForm.email.errorMessage : null,
          ),
          const SizedBox(height: 16),

          _CustomInput(
            label: 'Contraseña',
            icon: Icons.lock_outline,
            obscureText: true,
            onChanged: notifier.onPasswordChange,
            errorMessage: registerForm.isFormPosted ? registerForm.password.errorMessage : null,
          ),
          const SizedBox(height: 16),

          // En Odoo el registro suele incluir teléfono y notificaciones
          // Si tu Provider no tiene estos campos, quítalos o añádelos al State
          
          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: primaryColor),
              onPressed: registerForm.isPosting 
                ? null 
                : notifier.onFormSubmit,
              child: registerForm.isPosting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Crear Cuenta'),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Ya tienes cuenta?'),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Ingresa aquí', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/icono.png'),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Crea tu cuenta de hermano",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

// Reutilizamos el _CustomInput de tu Login para mantener consistencia
class _CustomInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? errorMessage;
  final TextInputType? keyboardType;

  const _CustomInput({
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.onChanged,
    this.errorMessage,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorMessage,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}