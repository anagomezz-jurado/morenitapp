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
  User? _user;

  GoRouterNotifier(this._authNotifier) {
    _authNotifier.addListener((state) {
      if (_authStatus != state.authStatus || _user != state.user) {
        _authStatus = state.authStatus;
        _user = state.user;
        notifyListeners();
      }
    });
  }

  AuthStatus get authStatus => _authStatus;
}
