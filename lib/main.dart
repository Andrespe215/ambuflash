import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const AmbuFlashApp());
}

// Colores de AmbuFlash
const Color ambuRed = Color(0xFFE53935);
const Color ambuDarkBg = Color(0xFF121212);
const Color ambuCardBg = Color(0xFF1E1E1E);
const Color ambuTextGray = Color(0xFFB0B0B0);

class AmbuFlashApp extends StatelessWidget {
  const AmbuFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmbuFlash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ambuDarkBg,
        colorScheme: const ColorScheme.dark(
          primary: ambuRed,
          surface: ambuCardBg,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = 'Paciente';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Estado para mostrar spinner mientras carga
  bool _cargando = false;

  // ============================================
  // FUNCIÓN DE LOGIN - Llama al backend PHP
  // ============================================
  Future<void> _hacerLogin() async {
    // Validar que los campos no estén vacíos
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _mostrarAlerta('Por favor llena todos los campos');
      return;
    }

    // Activar spinner
    setState(() => _cargando = true);

    // Llamar a la API
    final resultado = await ApiService.login(
      emailController.text.trim(),
      passwordController.text,
    );

    // Desactivar spinner
    if (mounted) {
      setState(() => _cargando = false);
    }

    // Procesar respuesta
    if (resultado['success'] == true) {
      final usuario = resultado['usuario'];
      _mostrarAlerta('¡Bienvenido/a ${usuario['nombre_completo']}!\nRol: ${usuario['rol']}');
    } else {
      _mostrarAlerta(resultado['mensaje'] ?? 'Error desconocido');
    }
  }

  // Función auxiliar para mostrar un diálogo
  void _mostrarAlerta(String mensaje) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ambuCardBg,
        title: const Text('AmbuFlash', style: TextStyle(color: Colors.white)),
        content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Logo y nombre
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: ambuRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_hospital,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('AmbuFlash',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      Text('SISTEMA DE EMERGENCIAS',
                          style: TextStyle(
                              color: ambuRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Título
              const Text('Iniciar\nSesión',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.1)),
              const SizedBox(height: 8),
              const Text('Accede con tu rol asignado',
                  style: TextStyle(color: ambuTextGray, fontSize: 14)),

              const SizedBox(height: 28),

              // Roles
              Row(
                children: [
                  _roleChip('Paciente'),
                  const SizedBox(width: 8),
                  _roleChip('Coord/Admin'),
                  const SizedBox(width: 8),
                  _roleChip('Ambulancia'),
                ],
              ),

              const SizedBox(height: 28),

              // Campo correo
              const Text('CORREO ELECTRÓNICO',
                  style: TextStyle(
                      color: ambuTextGray,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              _textField(emailController, 'ana.garcia@email.com', false),

              const SizedBox(height: 16),

              // Campo contraseña
              const Text('CONTRASEÑA',
                  style: TextStyle(
                      color: ambuTextGray,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              _textField(passwordController, '********', true),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Text('¿Olvidaste tu contraseña?',
                    style: TextStyle(color: ambuRed, fontSize: 13)),
              ),

              const SizedBox(height: 32),

              // Botón entrar con estado de carga
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _hacerLogin,
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
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('ENTRAR →',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: ambuTextGray, fontSize: 13),
                    children: [
                      TextSpan(text: '¿No tienes cuenta? '),
                      TextSpan(
                          text: 'Registrate',
                          style: TextStyle(
                              color: ambuRed, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String label) {
    final bool selected = selectedRole == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = label),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: selected ? ambuRed : ambuCardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: selected ? Colors.white : ambuTextGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint,
      bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ambuTextGray),
        filled: true,
        fillColor: ambuCardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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