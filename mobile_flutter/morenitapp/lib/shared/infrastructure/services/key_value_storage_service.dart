

import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueStorageService {

  Future<void> setKeyValue<T>(String key, T value);
  Future<T?> getValue<T>( String key );
  Future<bool> removeKey(String key );

  @override
Future<void> setKey<T>(String key, T value) async {
  final prefs = await SharedPreferences.getInstance();

  if (value is String) {
    await prefs.setString(key, value);
  } else if (value is int) {
    await prefs.setInt(key, value);
  } else if (value is bool) {
    await prefs.setBool(key, value);
  } else if (value is double) {
    await prefs.setDouble(key, value);
  } else {
    throw UnimplementedError('Tipo de dato no soportado para setKey: ${T.runtimeType}');
  }
}

}