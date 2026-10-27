import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Necesario para el reconocimiento de toques
import 'api_service.dart';
import 'screens/paciente_home.dart';
import 'screens/registro_screen.dart'; // Importamos la pantalla de registro

class LoginPaciente extends StatefulWidget {
  const LoginPaciente({super.key});
  @override
  State<LoginPaciente> createState() => _LoginPacienteState();
}

class _LoginPacienteState extends State<LoginPaciente> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _cargando = false;

  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  Future<void> _login() async {
    if (emailController.text.trim().isEmpty || passController.text.trim().isEmpty) {
      _mostrarAlerta('Por favor llena todos los campos');
      return;
    }

    setState(() => _cargando = true);
    final res = await ApiService.login(emailController.text.trim(), passController.text);
    if (mounted) setState(() => _cargando = false);

    if (res['success'] == true) {
      if (res['usuario']['rol'] == 'paciente') {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => PacienteHome(
            nombre: res['usuario']['nombre_completo'], 
            usuarioId: res['usuario']['id']
          )
        ));
      } else {
        _mostrarAlerta('Esta cuenta no es de un paciente. Usa la app correspondiente.');
      }
    } else {
      _mostrarAlerta(res['mensaje'] ?? 'Error al iniciar sesión');
    }
  }

  void _mostrarAlerta(String m) {
    showDialog(
      context: context, 
      builder: (c) => AlertDialog(
        backgroundColor: ambuCardBg, 
        title: const Text('AmbuFlash', style: TextStyle(color: Colors.white)), 
        content: Text(m, style: const TextStyle(color: Colors.white70)), 
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c), 
            child: Text('OK', style: TextStyle(color: ambuRed))
          )
        ]
      )
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
              // Logo
              Row(
                children: [
                  Container(
                    width: 56, 
                    height: 56, 
                    decoration: BoxDecoration(color: ambuRed, borderRadius: BorderRadius.circular(12)), 
                    child: const Icon(Icons.person, color: Colors.white, size: 32)
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text('AmbuFlash', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('APP PACIENTES', style: TextStyle(color: ambuRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ]
                  ),
                ]
              ),
              const SizedBox(height: 40),
              
              // Título
              const Text('Iniciar\nSesión', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 8),
              Text('Accede para pedir una ambulancia', style: TextStyle(color: ambuTextGray, fontSize: 14)),
              const SizedBox(height: 32),

              // Campo correo
              Text('CORREO ELECTRÓNICO', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  hintStyle: TextStyle(color: ambuTextGray),
                  filled: true,
                  fillColor: ambuCardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ambuRed, width: 1.5)),
                ),
              ),
              const SizedBox(height: 24),

              // Campo contraseña
              Text('CONTRASEÑA', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                controller: passController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '********',
                  hintStyle: TextStyle(color: ambuTextGray),
                  filled: true,
                  fillColor: ambuCardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ambuRed, width: 1.5)),
                ),
              ),
              
              const SizedBox(height: 40),

              // Botón entrar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ambuRed,
                    disabledBackgroundColor: ambuRed.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _cargando
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('ENTRAR →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 32),

              // --- AQUÍ ESTÁ LA OPCIÓN DE REGISTRO ---
              Center(
                child: RichText(
                  text: TextSpan(
                    style:  TextStyle(color: ambuTextGray, fontSize: 14),
                    children: [
                      const TextSpan(text: '¿No tienes cuenta? '),
                      TextSpan(
                        text: 'Regístrate aquí',
                        style:  TextStyle(color: ambuRed, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navega a la pantalla de registro de ciudadano
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroScreen()));
                          },
                      ),
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
}