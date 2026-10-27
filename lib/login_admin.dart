import 'package:flutter/material.dart';
import 'api_service.dart';
import 'screens/coordinador_home.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
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
      final rol = res['usuario']['rol'];
      
      // Solo dejamos entrar a coordinadores o administradores
      if (rol == 'coordinador' || rol == 'admin') {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => CoordinadorHome(
            nombre: res['usuario']['nombre_completo'], 
            usuarioId: res['usuario']['id']
          )
        ));
      } else {
        _mostrarAlerta('Acceso denegado. Esta app es exclusiva para Administradores.');
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
        title: const Text('AmbuFlash Admin', style: TextStyle(color: Colors.white)), 
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
              // Logo y nombre de la App Admin
              Row(
                children: [
                  Container(
                    width: 56, 
                    height: 56, 
                    decoration: BoxDecoration(color: ambuRed, borderRadius: BorderRadius.circular(12)), 
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32)
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children:[
                      Text('AmbuFlash', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('CENTRO DE MANDO', style: TextStyle(color: ambuRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ]
                  ),
                ]
              ),
              const SizedBox(height: 50),
              
              // Título
              const Text('Panel de\nControl', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 8),
              Text('Acceso exclusivo para coordinadores', style: TextStyle(color: ambuTextGray, fontSize: 14)),
              const SizedBox(height: 40),

              // Campo correo
              Text('CORREO ADMINISTRATIVO', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'admin@ambuflash.com',
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
                  hintStyle:TextStyle(color: ambuTextGray),
                  filled: true,
                  fillColor: ambuCardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide:  BorderSide(color: ambuRed, width: 1.5)),
                ),
              ),
              const SizedBox(height: 48),

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
                      : const Text('INGRESAR AL SISTEMA →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Uso exclusivo para personal autorizado',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}