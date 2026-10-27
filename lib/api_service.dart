import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //URL del backend PHP en XAMPP
  static const String baseUrl = 'http://10.0.2.2/ambuflash_api';//
  //static const String baseUrl = 'http://192.168.0.33/ambuflash_api';//
  //static const String baseUrl = 'http:/172.19.228.56/ambuflash_api';//
 //static const String baseUrl = 'http://172.16.126.107/ambuflash_api';

    // ============================================
  // LOGIN
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
      return {'success': false, 'mensaje': 'Error de conexión: $e', 'statusCode': 0};
    }
  }



  // ============================================
  // REGISTRO DE USUARIO (Paso 1)
  // ============================================
  static Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
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
          'nombre_completo': nombre,
          'email': email,
          'password': password,
          'telefono': telefono,
          'fecha_nacimiento': fechaNacimiento,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // GUARDAR FICHA MÉDICA (Paso 2)
  // ============================================
  static Future<Map<String, dynamic>> guardarFichaMedica({
    required int usuarioId,
    required String tipoSangre,
    String? alergias,
    String? enfermedades,
    String? medicamentos,
    String? cirugias,
    String? discapacidades,
    String? antecedentes,
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
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // OBTENER FICHA MÉDICA
  // ============================================
  static Future<Map<String, dynamic>> obtenerFichaMedica(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_ficha.php?usuario_id=$usuarioId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }


    // ============================================
  // CREAR EMERGENCIA
  // ============================================
  static Future<Map<String, dynamic>> crearEmergencia({
    required int solicitanteId,
    required int pacienteId,
    required String tipoSolicitud,
    required String sintomas,
    required String descripcion,
    required String direccion,
    required String pacienteNombre,
    required int pacienteEdad,
    required String pacienteTipoSangre,
    required String pacienteTelefono,
    required String relacion,
    double? latitud, // <-- NUEVO PARÁMETRO
    double? longitud, // <-- NUEVO PARÁMETRO
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crear_emergencia.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitante_id': solicitanteId,
          'paciente_id': pacienteId,
          'tipo_solicitud': tipoSolicitud,
          'sintomas': sintomas,
          'descripcion': descripcion,
          'direccion': direccion,
          'paciente_nombre': pacienteNombre,
          'paciente_edad': pacienteEdad,
          'paciente_tipo_sangre': pacienteTipoSangre,
          'paciente_telefono': pacienteTelefono,
          'relacion': relacion,
          'latitud': latitud, // <-- ENVIAMOS LA LATITUD
          'longitud': longitud, // <-- ENVIAMOS LA LONGITUD
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // OBTENER ESTADO DE EMERGENCIA EN TIEMPO REAL
  // ============================================
  static Future<Map<String, dynamic>> obtenerEstadoEmergencia(String codigo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_estado_emergencia.php?codigo=$codigo'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

  // ============================================
  // --- MÉTODOS DEL COORDINADOR ---
  // ============================================

  // 1. Obtener la lista de emergencias para el panel
  static Future<Map<String, dynamic>> obtenerEmergencias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/obtener_emergencias.php'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error: $e'};
    }
  }

  // 2. Obtener las ambulancias disponibles
  static Future<Map<String, dynamic>> obtenerAmbulanciasDisponibles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/obtener_ambulancias_disponibles.php'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error: $e'};
    }
  }

  // 3. Asignar una ambulancia a una emergencia
  static Future<Map<String, dynamic>> asignarAmbulancia(int emergenciaId, int ambulanciaId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asignar_ambulancia.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emergencia_id': emergenciaId,
          'ambulancia_id': ambulanciaId,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error: $e'};
    }
  }

    // ============================================
  // OBTENER PANEL DEL CONDUCTOR
  // ============================================
  static Future<Map<String, dynamic>> obtenerPanelConductor(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_panel_conductor.php?conductor_id=$conductorId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

    // 4. Obtener solicitud entrante para el conductor
  static Future<Map<String, dynamic>> obtenerSolicitudConductor(int conductorId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/obtener_solicitud_conductor.php?conductor_id=$conductorId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error: $e'};
    }
  }

  // 5. Aceptar o rechazar solicitud
  static Future<Map<String, dynamic>> responderSolicitud(int emergenciaId, int ambulanciaId, String accion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/responder_solicitud.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emergencia_id': emergenciaId,
          'ambulancia_id': ambulanciaId,
          'accion': accion, // 'aceptar' o 'rechazar'
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error: $e'};
    }
  }

    // 6. Actualizar estado de la emergencia desde el conductor
  static Future<Map<String, dynamic>> actualizarEstadoConductor(int emergenciaId, String nuevoEstado) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/actualizar_estado_conductor.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emergencia_id': emergenciaId,
          'nuevo_estado': nuevoEstado, // 'en_escena', 'atendida'
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error: $e'};
    }
  }

    // ============================================
  // REGISTRAR AMBULANCIA COMPLETA
  // ============================================
  static Future<Map<String, dynamic>> registrarAmbulancia(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registrar_ambulancia.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

    // ============================================
  // OBTENER HISTORIAL DE EMERGENCIAS DEL PACIENTE
  // ============================================
  static Future<Map<String, dynamic>> obtenerHistorialPaciente(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_historial_paciente.php?usuario_id=$usuarioId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

    // ============================================
  // OBTENER TODAS LAS AMBULANCIAS (Para el Coordinador)
  // ============================================
  static Future<Map<String, dynamic>> obtenerTodasAmbulancias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_todas_ambulancias.php'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

    // ============================================
  // ACTUALIZAR FICHA MÉDICA
  // ============================================
  static Future<Map<String, dynamic>> actualizarFichaMedica({
    required int usuarioId,
    required String tipoSangre,
    String? alergias,
    String? enfermedades,
    String? medicamentos,
    String? cirugias,
    String? discapacidades,
    String? antecedentes,
    required String contactoNombre,
    required String contactoParentesco,
    required String contactoTelefono,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/actualizar_ficha.php'),
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
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

    // ============================================
  // CANCELAR EMERGENCIA
  // ============================================
  static Future<Map<String, dynamic>> cancelarEmergencia(String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cancelar_emergencia.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'codigo': codigo}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

    // ============================================
  // OBTENER DETALLE DE UNA AMBULANCIA
  // ============================================
  static Future<Map<String, dynamic>> obtenerDetalleAmbulancia(int ambulanciaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_detalle_ambulancia.php?id=$ambulanciaId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }

    // ============================================
  // CAMBIAR ESTADO DE AMBULANCIA (Admin)
  // ============================================
  static Future<Map<String, dynamic>> cambiarEstadoAmbulancia(int ambulanciaId, String nuevoEstado) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cambiar_estado_ambulancia.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ambulancia_id': ambulanciaId,
          'nuevo_estado': nuevoEstado, // 'disponible' o 'fuera_servicio'
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'mensaje': 'Error de conexión: $e'};
    }
  }











}