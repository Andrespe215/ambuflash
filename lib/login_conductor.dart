import 'package:flutter/material.dart';
import 'api_service.dart';
import 'screens/conductor_home.dart';
// import 'screens/registro_ambulancia_screen.dart'; <-- Ya no lo necesitamos aquí
// import 'package:flutter/gestures.dart'; <-- Ya no lo necesitamos aquí

class LoginConductor extends StatefulWidget {
  const LoginConductor({super.key});
  @override
  State<LoginConductor> createState() => _LoginConductorState();
}

class _LoginConductorState extends State<LoginConductor> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool _cargando = false;
  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  Future<void> _login() async {
    if (email.text.trim().isEmpty || pass.text.trim().isEmpty) {
      _mostrarAlerta('Por favor llena todos los campos');
      return;
    }

    setState(() => _cargando = true);
    final res = await ApiService.login(email.text.trim(), pass.text);
    if (mounted) setState(() => _cargando = false);

    if (res['success'] == true) {
      final rol = res['usuario']['rol'];
      if (rol == 'conductor' || rol == 'paramedico') {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => ConductorHome(
            nombre: res['usuario']['nombre_completo'], 
            usuarioId: res['usuario']['id']
          )
        ));
      } else {
        _mostrarAlerta('Esta cuenta no es de una ambulancia. Usa la app correspondiente.');
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
                    child: const Icon(Icons.local_hospital, color: Colors.white, size: 32)
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children:[
                      Text('AmbuFlash', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('APP AMBULANCIA', style: TextStyle(color: ambuRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ]
                  ),
                ]
              ),
              const SizedBox(height: 50),
              
              // Título
              const Text('Iniciar\nSesión', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 8),
              Text('Accede para recibir emergencias', style: TextStyle(color: ambuTextGray, fontSize: 14)),
              const SizedBox(height: 40),

              // Campo correo
              Text('CORREO DEL CONDUCTOR', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                controller: email,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'conductor@ambuflash.com',
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
                controller: pass,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '********',
                  hintStyle: TextStyle(color: ambuTextGray),
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
                      : const Text('ENTRAR →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Las cuentas de ambulancia son asignadas por el administrador.',
                  style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}