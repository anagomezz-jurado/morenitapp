import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:morenitapp/config/theme/main_background.dart';
import 'package:morenitapp/infraestructura/register_cubit.dart';
import 'package:morenitapp/infraestructura/register_state.dart';
import '../services/api_service.dart';

class RegistrarScreen extends StatelessWidget {
  const RegistrarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainBackground(
      title: 'Únete a MorenitApp',
      centerTitle: true,
      child: BlocProvider(
        // Asegúrate de que el Cubit retorne Future<bool> en onSubmit si es posible,
        // si no, el listener hará el trabajo.
        create: (context) => RegisterCubit(ApiService()),
        child: const _RegisterView(),
      ),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        // --- NAVEGACIÓN POR ESTADO (OPCIÓN 1) ---
        if (state.status == FormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro completado! Redirigiendo...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          context.go('/login');
        }

        if (state.status == FormStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error al registrar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 10),
          const _LogoHeader(),
          const SizedBox(height: 20),

          // Indicador de carga superior
          BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) {
              if (state.status == FormStatus.posting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  child: LinearProgressIndicator(),
                );
              }
              return const SizedBox(height: 24);
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: const _RegisterForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... (imports iguales)

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    // Usamos select para escuchar solo el status y evitar rebuilds innecesarios
    final status = context.select((RegisterCubit cubit) => cubit.state.status);
    final registerCubit = context.read<RegisterCubit>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Column(
        children: [
          _InputField(
              label: 'Nombre',
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              onChanged: registerCubit.nombreChanged),
          const SizedBox(height: 16),
          _InputField(
              label: 'Apellido 1',
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              onChanged: registerCubit.apellido1Changed),
          const SizedBox(height: 16),
          _InputField(
              label: 'Apellido 2',
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              onChanged: registerCubit.apellido2Changed),
          const SizedBox(height: 16),
          _InputField(
              label: 'Teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: registerCubit.telefonoChanged),
          const SizedBox(height: 16),
          _InputField(
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: registerCubit.emailChanged),
          const SizedBox(height: 16),
          // Dentro de tu _RegisterForm
          _InputField(
            label: 'Contraseña',
            icon: Icons.lock_outline,
            obscureText: true,
            onChanged: (value) => registerCubit.passwordChanged(
                value), // En el cubit: emit(state.copyWith(contrasena: value))
          ),
          BlocBuilder<RegisterCubit, RegisterState>(
            buildWhen: (p, c) => p.recibirNotiEmail != c.recibirNotiEmail,
            builder: (context, state) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notificaciones Email',
                    style: TextStyle(fontSize: 13)),
                value: state.recibirNotiEmail,
                onChanged: registerCubit.notiEmail,
              );
            },
          ),
          // Debajo del BlocBuilder de recibirNotiEmail
          BlocBuilder<RegisterCubit, RegisterState>(
            buildWhen: (p, c) => p.recibirNotiTelefono != c.recibirNotiTelefono,
            builder: (context, state) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notificaciones por SMS',
                    style: TextStyle(fontSize: 13)),
                value: state.recibirNotiTelefono,
                onChanged: (value) =>
                    context.read<RegisterCubit>().notiTelefono(value),
              );
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: status == FormStatus.posting
                  ? null
                  : () async {
                      final success = await registerCubit.onSubmit();
                      if (success && context.mounted) {
                        // No necesitas hacer nada aquí, el BlocListener de arriba se encarga
                      }
                    },
              child: status == FormStatus.posting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Finalizar Registro'),
            ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/icono.png'),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Crea tu cuenta",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _InputField({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
