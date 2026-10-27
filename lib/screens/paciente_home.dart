import 'package:flutter/material.dart';
import 'solicitar_emergencia_screen.dart';
import 'ficha_medica_view_screen.dart';
import 'historial_paciente_screen.dart';
//import '../main.dart'; 
import '../login_paciente.dart';

class PacienteHome extends StatefulWidget {
  final String nombre;
  final int usuarioId;

  const PacienteHome({super.key, required this.nombre, required this.usuarioId});

  @override
  State<PacienteHome> createState() => _PacienteHomeState();
}

class _PacienteHomeState extends State<PacienteHome> {
  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  // ESTA ES LA CLAVE: 0 = Inicio, 1 = Solicitudes (Historial), 2 = Perfil (Ficha)
  int _currentIndex = 0; 

  @override
  Widget build(BuildContext context) {
    // Aquí decidimos qué pantalla mostrar en el cuerpo
    Widget body;
    if (_currentIndex == 0) {
      body = _buildInicio(context); // Pantalla de inicio
    } else if (_currentIndex == 1) {
      body = HistorialPacienteScreen(usuarioId: widget.usuarioId); // Historial
    } else {
      body = FichaMedicaViewScreen(usuarioId: widget.usuarioId); // Ficha Médica
    }

    return Scaffold(
      backgroundColor: ambuDarkBg,
      body: SafeArea(child: body),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration:BoxDecoration(
          color: ambuDarkBg,
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 0),
              child: _buildNavItem(Icons.location_on, 'INICIO', _currentIndex == 0),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 1),
              child: _buildNavItem(Icons.list_alt, 'SOLICITUDES', _currentIndex == 1),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 2),
              child: _buildNavItem(Icons.person, 'PERFIL', _currentIndex == 2),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PANTALLA DE INICIO
  // ==========================================
  Widget _buildInicio(BuildContext context) {
    final primerNombre = widget.nombre.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BARRA SUPERIOR ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hola, $primerNombre 👋',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPaciente()),
                        (route) => false,
                      );
                    },
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: ambuCardBg, shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none, color: Colors.white),
                      ),
                      Positioned(
                        right: 10, top: 10,
                        child: Container(width: 8, height: 8, decoration: BoxDecoration(color: ambuRed, shape: BoxShape.circle)),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('¿Necesitas ayuda?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // --- MAPA SIMULADO ---
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 40, left: 60,
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: ambuCardBg.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.local_hospital, color: Colors.green, size: 20)),
                      const SizedBox(height: 4),
                      const Text('AMB-01', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
                Positioned(
                  top: 50, right: 60,
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: ambuCardBg.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.local_hospital, color: Colors.green, size: 20)),
                      const SizedBox(height: 4),
                      const Text('AMB-02', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(width: 16, height: 16, decoration: BoxDecoration(color: ambuRed, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                ),
                const Positioned(
                  top: 15, right: 15,
                  child: Text('● 4 DISPONIBLES', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('TIPO DE SOLICITUD', style: TextStyle(color: ambuTextGray, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),

          // --- BOTÓN SOLICITAR PARA MÍ ---
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SolicitarEmergenciaScreen(usuarioId: widget.usuarioId, esParaMi: true)));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ambuRed, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Solicitar para mí', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Usa tu ubicación y ficha médica registrada', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- BOTÓN SOLICITAR PARA OTRA PERSONA ---
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SolicitarEmergenciaScreen(usuarioId: widget.usuarioId, esParaMi: false)));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Solicitar para otra persona', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Ingresa sus datos y ubicación', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- CATEGORÍAS RÁPIDAS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryIcon(Icons.favorite, 'Cardíaco'),
              _buildCategoryIcon(Icons.car_crash, 'Trauma'),
              _buildCategoryIcon(Icons.warning_amber_rounded, 'Accidente'),
              _buildCategoryIcon(Icons.bolt, 'Otro'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
          child: Icon(icon, color: ambuRed, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: ambuTextGray, fontSize: 12)),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final color = isActive ? ambuRed : ambuTextGray;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}