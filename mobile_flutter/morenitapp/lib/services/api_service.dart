import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hermano.dart';

class ApiService {
  final String baseUrl = 'http://192.168.18.5:8069';

  // 1. OBTENER HERMANOS
  Future<List<Hermano>> getHermanos() async {
    try {
      final url = Uri.parse('$baseUrl/api/hermanos');
      // Odoo para GET en controladores tipo 'json' a veces requiere POST vacío o GET con headers
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"jsonrpc": "2.0", "method": "call", "params": {}}),
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data['result'] != null) {
        final List listado = data['result'];
        return listado.map((json) => Hermano.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener hermanos: $e');
      return [];
    }
  }

  // 2. CREAR HERMANO (Desde la pantalla de gestión)
  Future<bool> crearRegistro(Map<String, dynamic> datos) async {
    try {
      final url = Uri.parse('$baseUrl/api/hermanos/crear');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "jsonrpc": "2.0",
          "method": "call",
          "params": datos,
        }),
      );

      final responseData = jsonDecode(response.body);
      return responseData['result'] != null && responseData['result']['success'] == true;
    } catch (e) {
      print('Error en crearRegistro: $e');
      return false;
    }
  }

  // 3. REGISTRO DE USUARIO (MorenitApp Usuario)
  Future<void> crearUsuario({
    required String nombre,
    required String apellido1,
    String? apellido2,
    required String email,
    required String contrasena,
    required String telefono,
    required bool recibirNotiEmail,
    required bool recibirNotiTelefono,
    required int rol_id,
  }) async {
    final url = Uri.parse('$baseUrl/api/registrar');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call", // CRÍTICO para Odoo
        "params": {
          "nombre": nombre,
          "apellido1": apellido1,
          "apellido2": apellido2 ?? "",
          "email": email,
          "contrasena": contrasena,
          "telefono": telefono,
          "recibirNotiEmail": recibirNotiEmail,
          "recibirNotiTelefono": recibirNotiTelefono,
          "rol_id": rol_id,
        }
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);

    if (data.containsKey('error')) {
      throw Exception(data['error']['data']['message'] ?? 'Error en Odoo');
    }
    
    if (data['result'] != null && data['result']['success'] == false) {
      throw Exception(data['result']['error']);
    }
  }

  // 4. LOGIN
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "jsonrpc": "2.0",
          "method": "call",
          "params": {"email": email, "password": password}
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data['result']; 
    } catch (e) {
      print("Error de red: $e");
      return null;
    }
  }
}