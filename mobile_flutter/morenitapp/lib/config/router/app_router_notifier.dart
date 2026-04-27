import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morenitapp/features/auth/domain/entities/user.dart';
import 'package:morenitapp/features/auth/presentation/providers/auth_provider.dart';

final goRouterNotifierProvider = Provider((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return GoRouterNotifier(authNotifier);
});

class GoRouterNotifier extends ChangeNotifier {
  final AuthNotifier _authNotifier;
  AuthStatus _authStatus = AuthStatus.checking;
  User? _user; // Agregamos el seguimiento del usuario

  GoRouterNotifier(this._authNotifier) {
    _authNotifier.addListener((state) {
      // Si cambia el status O cambia el objeto usuario (incluyendo sus roles)
      if (_authStatus != state.authStatus || _user != state.user) {
        _authStatus = state.authStatus;
        _user = state.user;
        notifyListeners(); // Esto obliga a GoRouter a ejecutar el 'redirect'
      }
    });
  }

  AuthStatus get authStatus => _authStatus;
}