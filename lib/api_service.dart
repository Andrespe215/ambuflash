import 'dart:convert';
import 'package:http/http.dart' as http;

// ============================================
// SERVICIO DE API - AMBUFLASH
// Conecta la app Flutter con el backend PHP
// ============================================

class ApiService {
  // ⚠️ URL del backend PHP en XAMPP
  // 10.0.2.2 es la IP especial del emulador para llegar a tu PC
  static const String baseUrl = 'http://10.0.2.2/ambuflash_api';

  // ============================================
  // LOGIN
  // ============================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Convertir la respuesta a un Map
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Agregar el código HTTP a la respuesta
      data['statusCode'] = response.statusCode;

      return data;
    } catch (e) {
      // Si hay un error de red (servidor apagado, URL mal, etc.)
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
        'statusCode': 0,
      };
    }
  }
}