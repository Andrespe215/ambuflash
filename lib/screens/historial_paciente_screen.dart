import 'package:flutter/material.dart';
import '../api_service.dart';

class HistorialPacienteScreen extends StatefulWidget {
  final int usuarioId;
  const HistorialPacienteScreen({super.key, required this.usuarioId});

  @override
  State<HistorialPacienteScreen> createState() => _HistorialPacienteScreenState();
}

class _HistorialPacienteScreenState extends State<HistorialPacienteScreen> {
  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF0F1115);
  final Color ambuCardBg = const Color(0xFF1C1C24);
  final Color ambuTextGray = const Color(0xFF8E8E93);

  List<dynamic> _historial = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final res = await ApiService.obtenerHistorialPaciente(widget.usuarioId);
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _historial = res['historial'];
        } else {
          print("Error del servidor: ${res['mensaje']}");
        }
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mi Historial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: ambuRed))
          : _historial.isEmpty
              ? Center(
                  child: Text('No tienes emergencias registradas.', style: TextStyle(color: ambuTextGray, fontSize: 16)),
                )
              : RefreshIndicator(
                  color: ambuRed,
                  backgroundColor: ambuCardBg,
                  onRefresh: _cargarHistorial,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _historial.length,
                    itemBuilder: (context, index) {
                      final e = _historial[index];
                      return _buildTarjetaHistorial(e);
                    },
                  ),
                ),
    );
  }

  Widget _buildTarjetaHistorial(dynamic e) {
    String estado = e['estado'] ?? 'desconocido';
    Color colorEstado;
    if (estado == 'atendida') {
      colorEstado = Colors.green;
    } else if (estado == 'cancelada') {
      colorEstado = Colors.grey;
    } else if (estado == 'pendiente') {
      colorEstado = Colors.amber;
    } else {
      colorEstado = Colors.cyan;
    }

    String fechaStr = e['creado_en'] ?? '';
    String fechaMostrar = fechaStr;
    if (fechaStr.length >= 10) {
      final partes = fechaStr.substring(0, 10).split('-');
      if (partes.length == 3) {
        fechaMostrar = "${partes[2]}/${partes[1]}/${partes[0]}";
      }
    }

    String pacienteInfo = (e['paciente_nombre'] != null && e['paciente_nombre'].toString().isNotEmpty)
        ? 'Paciente: ${e['paciente_nombre']}'
        : 'Solicitud para mí';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ambuCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e['codigo'] ?? 'E-000', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado.toString().toUpperCase(),
                  style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(fechaMostrar, style: TextStyle(color: ambuTextGray, fontSize: 12)),
          const Divider(color: Colors.white10, height: 24),
          
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(e['direccion'] ?? 'Sin dirección', style: const TextStyle(color: Colors.white70, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(pacienteInfo, style: const TextStyle(color: Colors.white70, fontSize: 13))),
            ],
          ),
          
          if (e['ambulancia_codigo'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ambuRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ambuRed.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_hospital, color: ambuRed, size: 16),
                  const SizedBox(width: 8),
                  Text('Atendida por: ${e['ambulancia_codigo']}', style: TextStyle(color: ambuRed, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}