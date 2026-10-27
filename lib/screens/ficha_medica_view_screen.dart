import 'package:flutter/material.dart';
import '../api_service.dart';
import 'editar_ficha_screen.dart'; // <-- NUEVO IMPORT

class FichaMedicaViewScreen extends StatefulWidget {
  final int usuarioId;
  const FichaMedicaViewScreen({super.key, required this.usuarioId});

  @override
  State<FichaMedicaViewScreen> createState() => _FichaMedicaViewScreenState();
}

class _FichaMedicaViewScreenState extends State<FichaMedicaViewScreen> {
  Map<String, dynamic>? _ficha;
  bool _cargando = true;

  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  @override
  void initState() {
    super.initState();
    _cargarFicha();
  }

  Future<void> _cargarFicha() async {
    final res = await ApiService.obtenerFichaMedica(widget.usuarioId);
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _ficha = res['ficha'];
        }
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return Scaffold(backgroundColor: ambuDarkBg, body: Center(child: CircularProgressIndicator(color: ambuRed)));
    if (_ficha == null) return Scaffold(backgroundColor: ambuDarkBg, body: Center(child: Text('No hay ficha médica registrada', style: TextStyle(color: Colors.white))));

    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: ambuTextGray), 
            onPressed: () async {
              // Navegamos a la pantalla de edición pasando los datos actuales
              final actualizado = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => EditarFichaScreen(
                  usuarioId: widget.usuarioId, 
                  fichaActual: _ficha!,
                ))
              );
              
              // Si la pantalla de edición devuelve 'true', recargamos los datos
              if (actualizado == true) {
                _cargarFicha();
              }
            }
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PERSONAL AUTORIZADO · FICHA', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 16),

              // Header: Nombre y Tipo de Sangre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_ficha!['nombre_completo'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${_ficha!['fecha_nacimiento'] ?? ''} · ID: ${_ficha!['documento'] ?? ''}', style: TextStyle(color: ambuTextGray, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: ambuRed, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        const Text('SANGRE', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                        Text(_ficha!['tipo_sangre'] ?? '--', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Alerta de Alergias
              if (_ficha!['alergias'] != null && _ficha!['alergias'].toString().isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ambuRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ambuRed.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: ambuRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ALERGIAS CRÍTICAS', style: TextStyle(color: ambuRed, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(_ficha!['alergias'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Lista de datos clínicos
              _buildInfoRow('Enfermedades', _ficha!['enfermedades_cronicas']),
              _buildInfoRow('Medicamentos actuales', _ficha!['medicamentos_actuales']),
              _buildInfoRow('Cirugías', _ficha!['cirugias_previas']),
              _buildInfoRow('Discapacidades', _ficha!['discapacidades']),
              _buildInfoRow('Antecedentes', _ficha!['antecedentes_familiares']),

              const SizedBox(height: 24),

              // Contacto de Emergencia
              if (_ficha!['contacto_nombre'] != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONTACTO DE EMERGENCIA', style: TextStyle(color: ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${_ficha!['contacto_nombre']} (${_ficha!['contacto_parentesco']})', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_ficha!['contacto_telefono'] ?? '', style: TextStyle(color: ambuTextGray, fontSize: 14)),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                      label: const Text('LLAMAR', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: ambuCardBg, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.location_on, color: ambuRed, size: 18),
                      label: Text('VER UBICACIÓN', style: TextStyle(color: ambuRed)),
                      style: ElevatedButton.styleFrom(backgroundColor: ambuRed.withValues(alpha: 0.1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: ambuRed.withValues(alpha: 0.5)))),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ambuTextGray, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}