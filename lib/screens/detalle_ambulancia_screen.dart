import 'package:flutter/material.dart';
import '../api_service.dart';

class DetalleAmbulanciaScreen extends StatefulWidget {
  final int ambulanciaId;
  const DetalleAmbulanciaScreen({super.key, required this.ambulanciaId});

  @override
  State<DetalleAmbulanciaScreen> createState() => _DetalleAmbulanciaScreenState();
}

class _DetalleAmbulanciaScreenState extends State<DetalleAmbulanciaScreen> {
  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF0F1115);
  final Color ambuCardBg = const Color(0xFF1C1C24);
  final Color ambuTextGray = const Color(0xFF8E8E93);

  Map<String, dynamic>? _detalle;
  bool _cargando = true;
  bool _procesandoAccion = false;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final res = await ApiService.obtenerDetalleAmbulancia(widget.ambulanciaId);
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _detalle = res['detalle'];
        }
        _cargando = false;
      });
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    setState(() => _procesandoAccion = true);
    
    final res = await ApiService.cambiarEstadoAmbulancia(widget.ambulanciaId, nuevoEstado);
    
    if (mounted) {
      setState(() => _procesandoAccion = false);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado'), backgroundColor: Colors.green));
        _cargarDetalle(); // Recargamos para ver el cambio
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje']), backgroundColor: ambuRed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(
        title: const Text('Auditoría de Ambulancia', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: ambuRed))
          : _detalle == null
              ? Center(child: Text('No se pudo cargar la información', style: TextStyle(color: ambuTextGray)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CABECERA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_detalle!['codigo']} · ${_detalle!['placa']}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(_detalle!['hospital'] ?? 'Sin hospital', style: TextStyle(color: ambuTextGray, fontSize: 14)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _detalle!['estado'] == 'fuera_servicio' ? Colors.grey.withOpacity(0.2) : Colors.green.withOpacity(0.15), 
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              _detalle!['estado'].toString().toUpperCase(), 
                              style: TextStyle(
                                color: _detalle!['estado'] == 'fuera_servicio' ? Colors.grey : Colors.greenAccent, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),

                      // SECCIÓN 1: PAPELES DEL VEHÍCULO
                      _buildSectionTitle('Documentación del Vehículo'),
                      _buildInfoCard([
                        _buildRow('SOAT Vence', _detalle!['soat_vencimiento'] ?? 'No registrado'),
                        const Divider(color: Colors.white10),
                        _buildRow('Revisión Técnica Vence', _detalle!['revision_vencimiento'] ?? 'No registrado'),
                      ]),
                      const SizedBox(height: 24),

                      // SECCIÓN 2: CONDUCTOR
                      _buildSectionTitle('Datos del Conductor'),
                      _buildInfoCard([
                        _buildRow('Nombre', _detalle!['conductor_nombre'] ?? 'Sin asignar'),
                        const Divider(color: Colors.white10),
                        _buildRow('Cédula', _detalle!['conductor_cedula'] ?? '---'),
                        const Divider(color: Colors.white10),
                        _buildRow('Teléfono', _detalle!['conductor_telefono'] ?? '---'),
                        const Divider(color: Colors.white10),
                        _buildRow('Licencia de Conducción', _detalle!['licencia_conduccion'] ?? '---'),
                      ]),
                      const SizedBox(height: 24),

                      // SECCIÓN 3: PARAMÉDICO
                      _buildSectionTitle('Datos del Paramédico'),
                      _buildInfoCard([
                        _buildRow('Nombre', _detalle!['paramedico_nombre'] ?? 'Sin asignar'),
                        const Divider(color: Colors.white10),
                        _buildRow('Cédula', _detalle!['paramedico_cedula'] ?? '---'),
                        const Divider(color: Colors.white10),
                        _buildRow('Teléfono', _detalle!['paramedico_telefono'] ?? '---'),
                        const Divider(color: Colors.white10),
                        _buildRow('Registro Profesional', _detalle!['registro_profesional'] ?? '---'),
                      ]),
                      const SizedBox(height: 32),

                      // SECCIÓN 4: ACCIONES ADMINISTRATIVAS
                      _buildSectionTitle('Acciones Administrativas'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                        child: Column(
                          children: [
                            const Text(
                              'Si la ambulancia presenta fallas mecánicas o incumplimiento de documentos, puedes retirarla del servicio. El algoritmo no la enviará a nuevas emergencias.',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            
                            if (_procesandoAccion)
                              const CircularProgressIndicator(color: Colors.white)
                            else if (_detalle!['estado'] == 'fuera_servicio')
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () => _cambiarEstado('disponible'),
                                  icon: const Icon(Icons.check_circle, color: Colors.white),
                                  label: const Text('HABILITAR AMBULANCIA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Mostramos un diálogo de confirmación antes de deshabilitar
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: ambuCardBg,
                                        title: const Text('¿Deshabilitar Ambulancia?', style: TextStyle(color: Colors.white)),
                                        content: Text('Esta unidad dejará de recibir emergencias. ¿Estás seguro?', style: TextStyle(color: ambuTextGray)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white))),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _cambiarEstado('fuera_servicio');
                                            }, 
                                            child: Text('Sí, deshabilitar', style: TextStyle(color: ambuRed))
                                          ),
                                        ],
                                      )
                                    );
                                  },
                                  icon: const Icon(Icons.block, color: Colors.white),
                                  label: const Text('DESHABILITAR POR INCUMPLIMIENTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  style: ElevatedButton.styleFrom(backgroundColor: ambuRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: TextStyle(color: ambuRed, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(children: children),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ambuTextGray, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}