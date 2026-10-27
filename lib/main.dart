import 'package:flutter/material.dart';
import 'login_paciente.dart';
import 'login_conductor.dart';
import 'login_admin.dart';

void main() {
  runApp(const TestingHubApp());
}

class TestingHubApp extends StatelessWidget {
  const TestingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AmbuFlash Testing',
      theme: ThemeData.dark(),
      home: const HubScreen(),
    );
  }
}

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Centro de Pruebas (Dev)'),
        backgroundColor: const Color(0xFFE53935),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona qué App quieres probar:',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPaciente())),
              icon: const Icon(Icons.person),
              label: const Text('PROBAR APP PACIENTE'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginConductor())),
              icon: const Icon(Icons.local_hospital),
              label: const Text('PROBAR APP AMBULANCIA'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginAdmin())),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('PROBAR APP ADMIN'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}