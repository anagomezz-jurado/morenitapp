import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:morenitapp/config/theme/app_theme.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:morenitapp/features/auth/presentation/providers/register_form_provider.dart';
import 'package:morenitapp/shared/textos_inicio.dart';
import 'package:morenitapp/shared/widgets/widgets.dart'; // Asegúrate de tener MainBackground aquí

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(next.errorMessage),
        backgroundColor: Colors.red,
      ));

      ref.read(authProvider.notifier).clearErrorMessage();
    });

    return MainBackground(
      title: '¡Únete a MorenitApp!',
      headerIcon: Image.asset('assets/icono.png', width: 80, height: 80),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Crea tu cuenta de hermano',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 25),
            const _RegisterFormCard(),
            const SizedBox(height: 20),
            const Divider(indent: 30, endIndent: 30),
            const SizedBox(height: 10),
            const _FooterLinks(),
            const SizedBox(height: 30),
          ],
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
    final authState = ref.watch(authProvider);
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
            label: 'Nombre',
            icon: Icons.person_outline,
            onChanged: notifier.onNombreChange,
            errorMessage: registerForm.isFormPosted
                ? registerForm.nombre.errorMessage
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CustomInput(
                  label: '1er Apellido',
                  icon: Icons.badge_outlined,
                  onChanged: notifier.onApellido1Change,
                  errorMessage: registerForm.isFormPosted
                      ? registerForm.apellido1.errorMessage
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CustomInput(
                  label: '2do Apellido',
                  icon: Icons.badge_outlined,
                  onChanged: notifier.onApellido2Change,
                  errorMessage: registerForm.isFormPosted
                      ? registerForm.apellido2.errorMessage
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // --- Input de Teléfono ---
          // --- Input de Teléfono ---
          _CustomInput(
            label: 'Teléfono',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            onChanged: notifier.onTelefonoChange,
            errorMessage:
                (authState.errorMessage.toLowerCase().contains('teléfono') ||
                        authState.errorMessage.toLowerCase().contains('phone'))
                    ? 'Este teléfono ya está en uso' // Error del servidor
                    : (registerForm.isFormPosted
                        ? registerForm.telefono.errorMessage
                        : null),
          ),
          const SizedBox(height: 16),
          _CustomInput(
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.onEmailChange,
            errorMessage: (authState.errorMessage
                        .toLowerCase()
                        .contains('correo') ||
                    authState.errorMessage.toLowerCase().contains('email') ||
                    authState.errorMessage.toLowerCase().contains('existe'))
                ? 'Este correo ya está registrado' // Error del servidor
                : (registerForm.isFormPosted
                    ? registerForm.email.errorMessage
                    : null), // Error de formato
          ),
          const SizedBox(height: 16),
          _CustomInput(
            label: 'Contraseña',
            icon: Icons.lock_outline,
            obscureText: true,
            onChanged: notifier.onPasswordChange,
            errorMessage: registerForm.isFormPosted
                ? registerForm.password.errorMessage
                : null,
          ),
          const SizedBox(height: 16),
          _CustomInput(
            label: 'Confirmar Contraseña',
            icon: Icons.lock_reset_outlined,
            obscureText: true,
            onChanged: notifier.onPasswordConfirmationChange,
            errorMessage: registerForm.isFormPosted
                ? (registerForm.password.value !=
                        registerForm.passwordConfirmation.value
                    ? 'Las contraseñas no coinciden'
                    : registerForm.passwordConfirmation.errorMessage)
                : null,
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Notificaciones por Email',
                style: TextStyle(fontSize: 13)),
            value: registerForm.recibirNotiEmail,
            activeColor: primaryColor,
            onChanged: notifier.onNotiEmailChange,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          
          Row(
            children: [
              Checkbox(
                value: registerForm.aceptaTerminos,
                activeColor: primaryColor,
                onChanged: (value) =>
                    notifier.onTerminosChanged(value ?? false),
              ),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: 'Acepto los ',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'Términos y Condiciones',
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showLegalNotice(
                              context, 'Términos', AppStrings.terminosycondiciones),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 55,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              // El botón se habilita solo si acepta términos.
              // Al pulsar, se validará si el email o teléfono ya existen en el servidor.
              onPressed:
                  (registerForm.isPosting || !registerForm.aceptaTerminos)
                      ? null
                      : notifier.onFormSubmit,
              child: registerForm.isPosting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Crear Cuenta'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Ya tienes cuenta?', style: TextStyle(fontSize: 13)),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Ingresa aquí',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        _link(context, 'Política de privacidad', AppStrings.politicaPrivacidad),
        const Text('|', style: TextStyle(color: Colors.grey)),
        _link(context, 'Aviso legal', AppStrings.avisoLegal),
        const SizedBox(width: double.infinity),
        const Text('Copyright 2026 MorenitApp',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _link(BuildContext context, String title, String content) {
  return GestureDetector(
    onTap: () => _showLegalNotice(context, title, content),
    child: Text(
      title,
      style: const TextStyle(fontSize: 11, color: Colors.brown),
    ),
  );
}
}

void _showLegalNotice(BuildContext context, String title, String content) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(15),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold))),
          const Divider(),
          Expanded(
              child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [Text(content)])),
        ],
      ),
    ),
  );
}

class _CustomInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? errorMessage;
  final TextInputType? keyboardType;

  const _CustomInput(
      {required this.label,
      required this.icon,
      this.obscureText = false,
      this.onChanged,
      this.errorMessage,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorMessage,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
