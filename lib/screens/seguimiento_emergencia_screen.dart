import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';       
import '../api_service.dart';
import 'package:geolocator/geolocator.dart';

class SeguimientoEmergenciaScreen extends StatefulWidget {
  final String codigoEmergencia;
  const SeguimientoEmergenciaScreen({super.key, required this.codigoEmergencia});

  @override
  State<SeguimientoEmergenciaScreen> createState() => _SeguimientoEmergenciaScreenState();
}

class _SeguimientoEmergenciaScreenState extends State<SeguimientoEmergenciaScreen> {
  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);
  final Color ambuGreen = const Color(0xFF2E7D32);

  Map<String, dynamic>? _emergencia;
  Timer? _timer;
  String _estadoActual = 'pendiente';
  
  // Variables para la ubicación
  LatLng? _miUbicacionReal;
  bool _cargandoMapa = true;

  // Ubicación de la ambulancia simulada (cerca de Neiva por si acaso)
  final LatLng _ubicacionAmbulanciaDefault = const LatLng(2.9350, -75.2750); 

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionReal(); // <-- Obtenemos el GPS
    _cargarEstado();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _cargarEstado());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _obtenerUbicacionReal() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el GPS está encendido
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si el GPS está apagado, usamos Neiva por defecto para no romper el mapa
      if (mounted) {
        setState(() {
          _miUbicacionReal = const LatLng(2.9273, -75.2819);
          _cargandoMapa = false;
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _miUbicacionReal = const LatLng(2.9273, -75.2819);
            _cargandoMapa = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _miUbicacionReal = const LatLng(2.9273, -75.2819);
          _cargandoMapa = false;
        });
      }
      return;
    }

    // Obtener la posición
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _miUbicacionReal = LatLng(position.latitude, position.longitude);
        _cargandoMapa = false;
      });
    }
  }

  Future<void> _cargarEstado() async {
    final res = await ApiService.obtenerEstadoEmergencia(widget.codigoEmergencia);
    if (mounted && res['success'] == true) {
      setState(() {
        _emergencia = res['emergencia'];
        _estadoActual = _emergencia!['estado'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_emergencia == null || _cargandoMapa) {
      return Scaffold(
        backgroundColor: ambuDarkBg, 
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: ambuRed),
              const SizedBox(height: 16),
              Text('Obteniendo ubicación GPS...', style: TextStyle(color: ambuTextGray)),
            ],
          )
        )
      );
    }

    // Lógica para la barra de progreso
    bool asignada = _estadoActual != 'pendiente';
    bool enCamino = _estadoActual == 'en_camino' || _estadoActual == 'en_escena' || _estadoActual == 'atendida';
    bool llego = _estadoActual == 'en_escena' || _estadoActual == 'atendida';

    return Scaffold(
      backgroundColor: ambuDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- MAPA REAL (OpenStreetMap) ---
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      // Centramos en la ubicación real del paciente
                      initialCenter: _miUbicacionReal!,
                      initialZoom: 15.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ambuflash',
                      ),
                      MarkerLayer(
                        markers: [
                          // Marcador del Paciente (Tu ubicación real)
                          Marker(
                            point: _miUbicacionReal!,
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                          ),
                          // Marcador de la Ambulancia (Simulada cerca)
                          if (asignada)
                            Marker(
                              point: _ubicacionAmbulanciaDefault,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: ambuGreen, width: 3)),
                                child: const Icon(Icons.local_hospital, color: Colors.green, size: 24),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  // Botón de regresar flotante
                  Positioned(
                    top: 20, left: 20,
                    child: CircleAvatar(
                      backgroundColor: ambuCardBg,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- TARJETAS DINÁMICAS ---
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Tarjeta Verde
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: asignada ? ambuGreen.withOpacity(0.15) : ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: asignada ? ambuGreen : Colors.white12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(asignada ? Icons.check : Icons.access_time, color: asignada ? Colors.greenAccent : ambuTextGray, size: 16),
                                  const SizedBox(width: 4),
                                  Text(asignada ? 'AMBULANCIA ASIGNADA' : 'BUSCANDO AMBULANCIA', style: TextStyle(color: asignada ? Colors.greenAccent : ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                asignada ? '${_emergencia!['ambulancia_codigo'] ?? 'AMB'} en camino' : 'Espere un momento...', 
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tarjeta Conductor
                    if (asignada)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                        child: Row(
                          children: [
                            const CircleAvatar(backgroundColor: Color(0xFF2C2C2C), child: Icon(Icons.person, color: Colors.amber)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_emergencia!['conductor_nombre'] ?? 'Conductor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Placa: ${_emergencia!['placa'] ?? '---'}', style: TextStyle(color: ambuTextGray, fontSize: 11)),
                                  Text('Tel: ${_emergencia!['conductor_telefono'] ?? '---'}', style: TextStyle(color: ambuTextGray, fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withOpacity(0.3))),
                              child: IconButton(icon: const Icon(Icons.phone, color: Colors.green, size: 20), onPressed: () {}),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // --- BARRA DE PROGRESO Y BOTÓN CANCELAR ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ambuCardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildProgressStep('Asignada', asignada, asignada),
                      _buildProgressLine(asignada),
                      _buildProgressStep('En Camino', enCamino, enCamino),
                      _buildProgressLine(enCamino),
                      _buildProgressStep('Llegó', llego, llego),
                      _buildProgressLine(false),
                      _buildProgressStep('Atendiendo', false, false),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Botón Cancelar con confirmación
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool? confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: ambuCardBg,
                            title: const Text('¿Cancelar solicitud?', style: TextStyle(color: Colors.white)),
                            content: Text('¿Estás seguro de que deseas cancelar la ambulancia?', style: TextStyle(color: ambuTextGray)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No', style: TextStyle(color: Colors.white))),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sí, cancelar', style: TextStyle(color: ambuRed))),
                            ],
                          ),
                        );

                        if (confirmar == true && mounted) {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          final res = await ApiService.cancelarEmergencia(widget.codigoEmergencia);
                          
                          if (res['success'] == true) {
                            messenger.showSnackBar(const SnackBar(content: Text('Solicitud cancelada'), backgroundColor: Colors.red));
                            navigator.pop();
                          } else {
                            messenger.showSnackBar(SnackBar(content: Text(res['mensaje']), backgroundColor: ambuRed));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: ambuCardBg, side: const BorderSide(color: Colors.white12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Cancelar solicitud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: isCompleted ? Colors.green : Colors.white24, shape: BoxShape.circle),
            child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isCompleted ? Colors.white : ambuTextGray, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(width: 30, height: 2, color: isActive ? Colors.green : Colors.white24);
  }
}