import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morenitapp/config/theme/main_background.dart';
import 'package:morenitapp/infraestructura/register_cubit.dart';
import 'package:morenitapp/services/api_service.dart';

class PanelUsuarioScreen extends StatelessWidget {
  const PanelUsuarioScreen({super.key});

   @override
  Widget build(BuildContext context) {
    return MainBackground(
      title: 'Panel de usuario',
      centerTitle: true,
      child: BlocProvider(
        create: (context) => RegisterCubit(ApiService()),
      ),
    );
  }
}
