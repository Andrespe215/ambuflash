import 'dart:async';
import 'package:flutter/material.dart';
import '../api_service.dart';
//import '../main.dart';
import '../login_conductor.dart';

class ConductorHome extends StatefulWidget {
  final String nombre;
  final int usuarioId;
  const ConductorHome({super.key, required this.nombre, required this.usuarioId});

  @override
  State<ConductorHome> createState() => _ConductorHomeState();
}

class _ConductorHomeState extends State<ConductorHome> {
  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF0F1115);
  final Color ambuCardBg = const Color(0xFF1C1C24);
  final Color ambuTextGray = const Color(0xFF8E8E93);
  final Color ambuGreen = const Color(0xFF2E7D32);
  final Color ambuPurple = const Color(0xFF673AB7);

  Map<String, dynamic>? _panelData;
  Map<String, dynamic>? _solicitudData; 
  bool _cargando = true;
  Timer? _timer;

  // Estados para el checklist (Pantalla 4)
  bool _evalInicial = false;
  bool _signosVitales = false;
  bool _oxigeno = false;

  @override
  void initState() {
    super.initState();
    _cargarPanel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _revisarSolicitudes());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarPanel() async {
    final res = await ApiService.obtenerPanelConductor(widget.usuarioId);
    if (mounted) {
      setState(() {
        if (res['success'] == true) _panelData = res['panel'];
        _cargando = false;
      });
    }
  }

  Future<void> _revisarSolicitudes() async {
    if (_solicitudData != null && _solicitudData!['estado'] != 'asignada') return; 
    final res = await ApiService.obtenerSolicitudConductor(widget.usuarioId);
    if (mounted && res['success'] == true) {
      setState(() {
        _solicitudData = res['solicitud'];
      });
    }
  }

  // Aceptar o Rechazar
  Future<void> _responder(String accion) async {
    if (_solicitudData == null) return;
    setState(() {}); // Muestra cargando si quisieras
    
    await ApiService.responderSolicitud(_solicitudData!['id'], _solicitudData!['ambulancia_id'], accion);
    
    if (accion == 'rechazar') {
      setState(() => _solicitudData = null);
    } else {
      // Si acepta, actualizamos el estado local para mostrar la pantalla de navegación
      setState(() {
        _solicitudData!['estado'] = 'en_camino';
      });
    }
    _cargarPanel();
  }

  // Cambiar estado a En Escena o Atendida
  Future<void> _actualizarEstado(String nuevoEstado) async {
    await ApiService.actualizarEstadoConductor(_solicitudData!['id'], nuevoEstado);
    if (nuevoEstado == 'atendida') {
      setState(() {
        _solicitudData = null; // Volver al panel
        _evalInicial = false; _signosVitales = false; _oxigeno = false; // Resetear checklist
      });
    } else {
      setState(() {
        _solicitudData!['estado'] = nuevoEstado;
      });
    }
    _cargarPanel();
  }

  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginConductor()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return Scaffold(backgroundColor: ambuDarkBg, body: Center(child: CircularProgressIndicator(color: ambuRed)));
    
    // Enrutador visual según el estado de la emergencia
    if (_solicitudData != null) {
      if (_solicitudData!['estado'] == 'asignada') return _buildSolicitudEntrante();
      if (_solicitudData!['estado'] == 'en_camino') return _buildNavegando();
      if (_solicitudData!['estado'] == 'en_escena') return _buildAtendiendo();
    }

    return _buildPanelNormal();
  }

  // ==========================================
  // PANTALLA 2: SOLICITUD ENTRANTE (ROJA)
  // ==========================================
  Widget _buildSolicitudEntrante() {
    String pacienteNombre = _solicitudData!['paciente_nombre'] ?? 'Desconocido';
    String sangre = _solicitudData!['tipo_sangre'] ?? '?';
    String alergias = _solicitudData!['alergias'] ?? 'Ninguna';

    return Scaffold(
      backgroundColor: ambuRed,
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('NUEVA SOLICITUD', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)), const Text('Distancia\n1.4 km', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))])),
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 48),
            const Text('¡Emergencia\nEntrante!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
            Expanded(child: Container(margin: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('Mini-mapa', style: TextStyle(color: Colors.white54))))),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFF2A1012), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ASIGNACIÓN AUTOMÁTICA', style: TextStyle(color: ambuRed.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Emergencia ${_solicitudData!['codigo']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: ambuRed, borderRadius: BorderRadius.circular(8)), child: Text(sangre, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pacienteNombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text('Alergias: $alergias', style: TextStyle(color: ambuTextGray, fontSize: 12))])
                  ]),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: ElevatedButton(onPressed: () => _responder('rechazar'), style: ElevatedButton.styleFrom(backgroundColor: ambuCardBg, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Rechazar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: () => _responder('aceptar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('ACEPTAR SERVICIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                  ])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PANTALLA 3: NAVEGANDO AL PACIENTE
  // ==========================================
  Widget _buildNavegando() {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('EN CAMINO · ${_solicitudData!['codigo']}', style: TextStyle(color: Colors.white54, fontSize: 12)), Text('Tiempo: 04:41', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))])),
            const Text('Navegando al paciente', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Aviso de tráfico
            Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('Ruta recalculada · Tráfico en 5ta Sur', style: TextStyle(color: Colors.orange, fontSize: 12))])),
            
            // Mapa simulado con ruta
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF141424), borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.my_location, color: Colors.blue, size: 30)),
                    Center(child: Container(width: 150, height: 4, color: Colors.green)), // Ruta falsa
                    const Positioned(bottom: 50, right: 50, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                    const Positioned(top: 50, left: 50, child: Text('4 min\n420 m', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(children: [
                Text('Paciente: ${_solicitudData!['paciente_nombre'] ?? 'Desconocido'}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${_solicitudData!['direccion'] ?? 'Dirección'}', style: TextStyle(color: ambuTextGray, fontSize: 14)),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => _actualizarEstado('en_escena'), style: ElevatedButton.styleFrom(backgroundColor: ambuGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('HE LLEGADO AL DESTINO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ]),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PANTALLA 4: ATENDIENDO (CHECKLIST)
  // ==========================================
  Widget _buildAtendiendo() {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header morado
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ambuPurple, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('● ATENDIENDO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), Text('Tiempo en escena\n08:24', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 12))]),
                  const SizedBox(height: 20),
                  const Text('En Escena', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATOS DEL PACIENTE', style: TextStyle(color: ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: ambuRed, borderRadius: BorderRadius.circular(8)), child: Text(_solicitudData!['tipo_sangre'] ?? '?', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_solicitudData!['paciente_nombre'] ?? 'Desconocido', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('Alergias: ${_solicitudData!['alergias'] ?? 'Ninguna'}', style: TextStyle(color: ambuTextGray, fontSize: 12))])
                      ]),
                    ),
                    const SizedBox(height: 24),

                    Text('ACCIONES EN ESCENA', style: TextStyle(color: ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildCheckItem('Evaluación inicial realizada', _evalInicial, (v) => setState(() => _evalInicial = v!)),
                    _buildCheckItem('Signos vitales registrados', _signosVitales, (v) => setState(() => _signosVitales = v!)),
                    _buildCheckItem('Oxígeno administrado', _oxigeno, (v) => setState(() => _oxigeno = v!)),
                  ],
                ),
              ),
            ),

            // Botón Finalizar
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _evalInicial ? () => _actualizarEstado('atendida') : null, 
                  style: ElevatedButton.styleFrom(backgroundColor: _evalInicial ? ambuPurple : ambuCardBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('FINALIZAR ATENCIÓN', style: TextStyle(color: _evalInicial ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: ambuPurple,
        checkColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  // ==========================================
  // PANTALLA 1: PANEL NORMAL
  // ==========================================
  Widget _buildPanelNormal() {
    if (_panelData == null) return Center(child: Text('No tienes ambulancia asignada', style: TextStyle(color: Colors.white)));
    return Scaffold(
      backgroundColor: ambuDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('OPERADOR · ${_panelData!['codigo']}', style: TextStyle(color: ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)), IconButton(icon: const Icon(Icons.logout, color: Colors.white70, size: 20), onPressed: _cerrarSesion)]),
              Row(children: [
                const CircleAvatar(backgroundColor: Colors.amber, radius: 24, child: Icon(Icons.person, color: Colors.black)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_panelData!['conductor_nombre'] ?? 'Conductor', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ambuGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: ambuGreen)), child: const Text('Disponible', style: TextStyle(color: Colors.greenAccent, fontSize: 11)))])
              ]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.local_hospital, color: ambuRed), const SizedBox(width: 8), Text('${_panelData!['codigo']} · ${_panelData!['placa']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]), const Icon(Icons.local_shipping, color: Colors.white54)]),
                  const SizedBox(height: 12),
                  const Row(children: [Icon(Icons.circle, color: Colors.green, size: 10), SizedBox(width: 6), Text('DISPONIBLE', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold))])
                ]),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStatCard('${_panelData!['servicios_hoy'] ?? 0}', 'Servicios hoy', Colors.white), _buildStatCard('${_panelData!['km_recorridos'] ?? 0}', 'Km recorridos', Colors.white), _buildStatCard('${_panelData!['rating'] ?? 5.0}', 'Rating', Colors.amber)]),
              const SizedBox(height: 24),
              Text('PERSONAL A BORDO', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: Column(children: [_buildPersonalRow(_panelData!['conductor_nombre'] ?? '', 'Conductor'), const Divider(color: Colors.white10), _buildPersonalRow(_panelData!['paramedico_nombre'] ?? 'Sin asignar', 'Paramédico')]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: Column(children: [Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(label, style: TextStyle(color: ambuTextGray, fontSize: 10))])));
  }

  Widget _buildPersonalRow(String nombre, String rol) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [CircleAvatar(backgroundColor: Colors.white10, radius: 16, child: Icon(Icons.person, color: ambuTextGray, size: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text(rol, style: TextStyle(color: ambuTextGray, fontSize: 11))])]));
  }
}