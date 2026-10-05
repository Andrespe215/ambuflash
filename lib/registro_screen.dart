import 'package:flutter/material.dart';
import 'api_service.dart';
import 'ficha_medica_screen.dart';

// Colores de AmbuFlash
const Color ambuRed = Color(0xFFE53935);
const Color ambuDarkBg = Color(0xFF121212);
const Color ambuCardBg = Color(0xFF1E1E1E);
const Color ambuTextGray = Color(0xFFB0B0B0);

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  bool _aceptaPolitica = false;
  bool _cargando = false;
  DateTime? _fechaSeleccionada;

  // ============================================
  // SELECCIONAR FECHA DE NACIMIENTO
  // ============================================
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ambuRed,
              onPrimary: Colors.white,
              surface: ambuCardBg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        fechaController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // ============================================
  // CREAR CUENTA
  // ============================================
  Future<void> _crearCuenta() async {
    // Validaciones locales
    if (nombreController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty ||
        telefonoController.text.trim().isEmpty ||
        fechaController.text.trim().isEmpty) {
      _mostrarAlerta('Por favor completa todos los campos');
      return;
    }

    if (passwordController.text != confirmController.text) {
      _mostrarAlerta('Las contraseñas no coinciden');
      return;
    }

    if (passwordController.text.length < 8) {
      _mostrarAlerta('La contraseña debe tener mínimo 8 caracteres');
      return;
    }

    if (!_aceptaPolitica) {
      _mostrarAlerta('Debes aceptar la Política de Tratamiento de Datos para continuar');
      return;
    }

    // Activar spinner
    setState(() => _cargando = true);

    // Llamar a la API
    final resultado = await ApiService.registro(
      nombreCompleto: nombreController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      telefono: telefonoController.text.trim(),
      fechaNacimiento: fechaController.text.trim(),
    );

    if (resultado['success'] == true) {
  final usuario = resultado['usuario'];
  final int nuevoUsuarioId = usuario['id'];

  if (!mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: ambuCardBg,
      title: const Text('¡Cuenta creada!',
          style: TextStyle(color: Colors.white)),
      content: const Text(
        'Ahora completa tu ficha médica para poder solicitar ayuda en caso de emergencia.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FichaMedicaScreen(usuarioId: nuevoUsuarioId),
              ),
            );
          },
          child: const Text('CONTINUAR',
              style: TextStyle(color: ambuRed, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
} else {
      _mostrarAlerta(resultado['mensaje'] ?? 'Error desconocido');
    }
  }

  // ============================================
  // DIÁLOGO DE ALERTA
  // ============================================
  void _mostrarAlerta(String mensaje, {VoidCallback? alCerrar}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ambuCardBg,
        title: const Text('AmbuFlash', style: TextStyle(color: Colors.white)),
        content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (alCerrar != null) alCerrar();
            },
            child: const Text('OK', style: TextStyle(color: ambuRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(
        backgroundColor: ambuDarkBg,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text('Nuevo Paciente',
                  style: TextStyle(color: ambuTextGray, fontSize: 13, letterSpacing: 2)),
              const SizedBox(height: 4),
              const Text('Registro Médico',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Crea tu cuenta para solicitar ayuda',
                  style: TextStyle(color: ambuTextGray, fontSize: 14)),

              const SizedBox(height: 32),

              // Datos personales
              const Text('DATOS PERSONALES',
                  style: TextStyle(
                      color: ambuRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 16),

              _label('NOMBRE COMPLETO'),
              _textField(nombreController, 'Ana García López'),

              const SizedBox(height: 16),

              _label('CORREO ELECTRÓNICO'),
              _textField(emailController, 'ana.garcia@gmail.com',
                  keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 16),

              _label('CONTRASEÑA'),
              _textField(passwordController, '********', isPassword: true),

              const SizedBox(height: 16),

              _label('CONFIRMAR CONTRASEÑA'),
              _textField(confirmController, '********', isPassword: true),

              const SizedBox(height: 16),

              _label('TELÉFONO'),
              _textField(telefonoController, '300 1234567',
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 16),

              _label('FECHA DE NACIMIENTO'),
              GestureDetector(
                onTap: _seleccionarFecha,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: ambuCardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fechaController.text.isEmpty
                            ? 'Selecciona tu fecha'
                            : fechaController.text,
                        style: TextStyle(
                          color: fechaController.text.isEmpty
                              ? ambuTextGray
                              : Colors.white,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: ambuTextGray, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Política
              Row(
                children: [
                  Checkbox(
                    value: _aceptaPolitica,
                    activeColor: ambuRed,
                    onChanged: (v) => setState(() => _aceptaPolitica = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Acepto la Política de Tratamiento de Datos',
                      style: TextStyle(color: ambuTextGray, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botón crear cuenta
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _crearCuenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ambuRed,
                    disabledBackgroundColor: ambuRed.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('CREAR CUENTA →',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              // Ya tienes cuenta
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: ambuTextGray, fontSize: 13),
                      children: [
                        TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(
                                color: ambuRed, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto,
          style: const TextStyle(
              color: ambuTextGray,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
    );
  }

  Widget _textField(TextEditingController controller, String hint,
      {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ambuTextGray),
        filled: true,
        fillColor: ambuCardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ambuRed, width: 1.5),
        ),
      ),
    );
  }
}