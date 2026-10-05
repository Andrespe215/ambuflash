import 'dart:convert';
import 'package:http/http.dart' as http;

// ============================================
// SERVICIO DE API - AMBUFLASH
// Conecta la app Flutter con el backend PHP
// ============================================

class ApiService {
  // ⚠️ URL del backend PHP en XAMPP
  // 10.0.2.2 es la IP del emulador para llegar a tu PC
  static const String baseUrl = 'http://10.0.2.2/ambuflash_api';

  // ============================================
  // 1. LOGIN
  // ============================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
        'statusCode': 0,
      };
    }
  }

  // ============================================
  // 2. REGISTRO DE USUARIO
  // ============================================
  static Future<Map<String, dynamic>> registro({
    required String nombreCompleto,
    required String email,
    required String password,
    required String telefono,
    required String fechaNacimiento,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registro.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_completo': nombreCompleto,
          'email': email,
          'password': password,
          'telefono': telefono,
          'fecha_nacimiento': fechaNacimiento,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
        'statusCode': 0,
      };
    }
  }

  // ============================================
  // 3. GUARDAR FICHA MÉDICA
  // ============================================
  static Future<Map<String, dynamic>> guardarFichaMedica({
    required int usuarioId,
    required String tipoSangre,
    required String alergias,
    required String enfermedades,
    required String medicamentos,
    required String cirugias,
    required String discapacidades,
    required String antecedentes,
    required String contactoNombre,
    required String contactoParentesco,
    required String contactoTelefono,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guardar_ficha.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'tipo_sangre': tipoSangre,
          'alergias': alergias,
          'enfermedades_cronicas': enfermedades,
          'medicamentos_actuales': medicamentos,
          'cirugias_previas': cirugias,
          'discapacidades': discapacidades,
          'antecedentes_familiares': antecedentes,
          'contacto_nombre': contactoNombre,
          'contacto_parentesco': contactoParentesco,
          'contacto_telefono': contactoTelefono,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
        'statusCode': 0,
      };
    }
  }
}