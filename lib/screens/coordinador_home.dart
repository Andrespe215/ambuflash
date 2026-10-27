import 'dart:async';
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../login_admin.dart';
import 'detalle_ambulancia_screen.dart';
import 'registro_ambulancia_screen.dart'; // <-- NUEVO IMPORT

class CoordinadorHome extends StatefulWidget {
  final String nombre;
  final int usuarioId;
  const CoordinadorHome({super.key, required this.nombre, required this.usuarioId});

  @override
  State<CoordinadorHome> createState() => _CoordinadorHomeState();
}

class _CoordinadorHomeState extends State<CoordinadorHome> {
  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF0F1115);
  final Color ambuCardBg = const Color(0xFF1C1C24);
  final Color ambuTextGray = const Color(0xFF8E8E93);

  int _currentIndex = 0;
  Timer? _timer;
  
  List<dynamic> _emergencias = [];
  List<dynamic> _ambulancias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _cargarDatos());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final resEm = await ApiService.obtenerEmergencias();
    if (resEm['success'] == true) {
      _emergencias = resEm['emergencias'];
    }
    
    final resAmb = await ApiService.obtenerTodasAmbulancias();
    if (resAmb['success'] == true) {
      _ambulancias = resAmb['ambulancias'];
    }

    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _asignarEmergencia(int emergenciaId) async {
    final disponibles = _ambulancias.where((a) => a['estado'] == 'disponible').toList();
    
    if (disponibles.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay ambulancias disponibles'), backgroundColor: Colors.red));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ambuCardBg,
        title: const Text('Asignar Ambulancia', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: disponibles.map<Widget>((amb) {
            return ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.green),
              title: Text('${amb['codigo']} - ${amb['placa']}', style: const TextStyle(color: Colors.white)),
              subtitle: Text('${amb['hospital']}', style: TextStyle(color: ambuTextGray, fontSize: 12)),
              onTap: () async {
                Navigator.pop(context);
                final resAsig = await ApiService.asignarAmbulancia(emergenciaId, amb['id']);
                if (resAsig['success'] == true) {
                  _cargarDatos();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _cerrarSesion() {
    // Volvemos al login de admin
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginAdmin()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_currentIndex == 0) {
      body = _buildPanel();
    } else if (_currentIndex == 1) {
      body = _buildListaEmergencias();
    } else if (_currentIndex == 2) {
      body = _buildListaAmbulancias(); 
    } else {
      body = Center(child: Text('Configuración en construcción', style: TextStyle(color: ambuTextGray)));
    }

    return Scaffold(
      backgroundColor: ambuDarkBg,
      body: SafeArea(child: body),
      // --- BOTÓN FLOTANTE (Solo aparece en la pestaña de Flota) ---
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton.extended(
              backgroundColor: ambuRed,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nueva Ambulancia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                // Navegamos al formulario de registro de ambulancia
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroAmbulanciaScreen()));
                // Al volver, recargamos la lista para ver la nueva ambulancia
                _cargarDatos();
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: ambuCardBg,
        selectedItemColor: ambuRed,
        unselectedItemColor: ambuTextGray,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'PANEL'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'EMERGENCIAS'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'FLOTA'), 
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'CONFIG'),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA 1: EL PANEL (DASHBOARD)
  // ==========================================
  Widget _buildPanel() {
    int pendientes = _emergencias.where((e) => e['estado'] == 'pendiente').length;
    int enCamino = _emergencias.where((e) => e['estado'] == 'en_camino').length;
    int disponibles = _ambulancias.where((a) => a['estado'] == 'disponible').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel Coordinador', style: TextStyle(color: ambuTextGray, fontSize: 12)),
                  const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white70), onPressed: _cerrarSesion),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildContador('$pendientes', 'Pendientes', Colors.amber),
              _buildContador('$disponibles', 'Disponibles', Colors.green),
              _buildContador('$enCamino', 'En Camino', Colors.cyan),
              _buildContador('0', 'Atendidas', Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
            child: const Center(child: Text('Mapa en vivo', style: TextStyle(color: Colors.white54))),
          ),
          const SizedBox(height: 24),

          const Text('Recientes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (_cargando) 
            const Center(child: CircularProgressIndicator(color: Colors.red))
          else if (_emergencias.isEmpty)
            Text('No hay emergencias', style: TextStyle(color: ambuTextGray))
          else
            ..._emergencias.take(3).map((e) => _buildTarjetaEmergencia(e, mostrarBoton: false)).toList(),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA 2: LISTA COMPLETA DE EMERGENCIAS
  // ==========================================
  Widget _buildListaEmergencias() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Emergencias', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${_emergencias.length} registros · ${_emergencias.where((e) => e['estado'] == 'pendiente').length} sin asignar', style: TextStyle(color: ambuTextGray, fontSize: 13)),
                ],
              ),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white70), onPressed: _cerrarSesion),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : ListView.builder(
                    itemCount: _emergencias.length,
                    itemBuilder: (context, index) {
                      final e = _emergencias[index];
                      return _buildTarjetaEmergencia(e, mostrarBoton: e['estado'] == 'pendiente');
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA 3: LISTA DE AMBULANCIAS
  // ==========================================
  Widget _buildListaAmbulancias() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mi Flota', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${_ambulancias.length} unidades registradas', style: TextStyle(color: ambuTextGray, fontSize: 13)),
                ],
              ),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white70), onPressed: _cerrarSesion),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : _ambulancias.isEmpty
                    ? Center(child: Text('No hay ambulancias registradas', style: TextStyle(color: ambuTextGray)))
                    : ListView.builder(
                        itemCount: _ambulancias.length,
                        itemBuilder: (context, index) {
                          final a = _ambulancias[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => DetalleAmbulanciaScreen(ambulanciaId: int.parse(a['id'].toString()))
                              ));
                            },
                            child: _buildTarjetaAmbulancia(a),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildTarjetaAmbulancia(dynamic a) {
    String estado = a['estado'] ?? 'desconocido';
    Color colorEstado;
    if (estado == 'disponible') {
      colorEstado = Colors.green;
    } else if (estado == 'mantenimiento' || estado == 'fuera_servicio') {
      colorEstado = Colors.grey;
    } else {
      colorEstado = Colors.cyan; 
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${a['codigo']} · ${a['placa']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: colorEstado.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(estado.toString().toUpperCase(), style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(a['hospital'] ?? 'Hospital no asignado', style: TextStyle(color: ambuTextGray, fontSize: 13)),
          const Divider(color: Colors.white10, height: 24),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('Conductor: ${a['conductor_nombre'] ?? 'Sin asignar'}', style: const TextStyle(color: Colors.white70, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.medical_services, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('Paramédico: ${a['paramedico_nombre'] ?? 'Sin asignar'}', style: const TextStyle(color: Colors.white70, fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaEmergencia(dynamic e, {required bool mostrarBoton}) {
    bool isCritica = e['prioridad'] == 'critica';
    Color colorPrioridad = isCritica ? ambuRed : (e['prioridad'] == 'alta' ? Colors.orange : Colors.amber);
    String estado = e['estado'];
    Color colorEstado = estado == 'pendiente' ? Colors.amber : (estado == 'en_camino' ? Colors.cyan : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: colorPrioridad, size: 12),
              const SizedBox(width: 8),
              Text(e['codigo'] ?? 'E-000', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: colorPrioridad.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(e['prioridad'].toString().toUpperCase(), style: TextStyle(color: colorPrioridad, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text(e['creado_en'].toString().substring(11, 16), style: TextStyle(color: ambuTextGray, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(e['direccion'] ?? 'Sin dirección', style: TextStyle(color: ambuTextGray, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: colorEstado.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(estado.toString().toUpperCase(), style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              if (mostrarBoton)
                ElevatedButton(
                  onPressed: () => _asignarEmergencia(e['id']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, side: BorderSide(color: ambuRed), elevation: 0),
                  child: Text('ASIGNAR', style: TextStyle(color: ambuRed, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              else if (e['ambulancia_id'] != null)
                Text('AMB-0${e['ambulancia_id']}', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildContador(String numero, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
        child: Column(
          children: [
            Text(numero, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: ambuTextGray, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}