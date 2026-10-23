import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api_service.dart';
import 'seguimiento_emergencia_screen.dart';

class SolicitarEmergenciaScreen extends StatefulWidget {
  final int usuarioId; 
  final bool esParaMi;

  const SolicitarEmergenciaScreen({super.key, required this.usuarioId, required this.esParaMi});

  @override
  State<SolicitarEmergenciaScreen> createState() => _SolicitarEmergenciaScreenState();
}

class _SolicitarEmergenciaScreenState extends State<SolicitarEmergenciaScreen> {
  // Controladores
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _tipoSangreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();

  String _relacionSeleccionada = 'Familiar';
  bool _cargando = false;

  // --- Variables para el GPS ---
  Position? _miUbicacion;
  bool _cargandoUbicacion = true;
  String _textoUbicacion = 'Obteniendo ubicación GPS...';
  // ------------------------------

  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF0F1115);
  final Color ambuCardBg = const Color(0xFF1C1C24);
  final Color ambuTextGray = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion(); // <-- Pedimos el GPS apenas abre la pantalla
  }

  Future<void> _obtenerUbicacion() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _cargandoUbicacion = false; _textoUbicacion = 'GPS desactivado'; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _miUbicacion = position;
            _cargandoUbicacion = false;
            _textoUbicacion = 'Ubicación GPS capturada con éxito';
          });
        }
      } else {
        if (mounted) setState(() { _cargandoUbicacion = false; _textoUbicacion = 'Permiso de GPS denegado'; });
      }
    } catch (e) {
      if (mounted) setState(() { _cargandoUbicacion = false; _textoUbicacion = 'Error al obtener GPS'; });
    }
  }

  Future<void> _enviarSolicitud() async {
    if (widget.esParaMi) {
      if (_descripcionController.text.isEmpty) {
        _mostrarAlerta('Por favor describe qué está ocurriendo');
        return;
      }
    } else {
      if (_nombreController.text.isEmpty || _descripcionController.text.isEmpty) {
        _mostrarAlerta('Por favor llena los datos de la persona y la descripción');
        return;
      }
    }

    if (_miUbicacion == null) {
      _mostrarAlerta('Aún no se ha capturado tu ubicación. Por favor espera o activa el GPS.');
      return;
    }

    setState(() => _cargando = true);

    // Tomamos la dirección que el usuario escribió, o si está vacía, ponemos un texto por defecto
    String direccionFinal = _direccionController.text.isEmpty 
        ? 'Ubicación GPS: ${_miUbicacion!.latitude.toStringAsFixed(4)}, ${_miUbicacion!.longitude.toStringAsFixed(4)}' 
        : _direccionController.text;

    final res = await ApiService.crearEmergencia(
      solicitanteId: widget.usuarioId,
      pacienteId: widget.esParaMi ? widget.usuarioId : 0, 
      tipoSolicitud: widget.esParaMi ? 'para_mi' : 'para_otra_persona',
      pacienteNombre: _nombreController.text,
      pacienteEdad: int.tryParse(_edadController.text) ?? 0,
      pacienteTipoSangre: _tipoSangreController.text,
      pacienteTelefono: _telefonoController.text,
      relacion: _relacionSeleccionada,
      sintomas: 'Emergencia reportada', 
      descripcion: _descripcionController.text,
      direccion: direccionFinal,
      latitud: _miUbicacion!.latitude, // <-- Enviamos latitud real
      longitud: _miUbicacion!.longitude, // <-- Enviamos longitud real
    );

    if (mounted) setState(() => _cargando = false);

    if (res['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: ambuCardBg,
          title: const Text('¡Solicitud Enviada!', style: TextStyle(color: Colors.white)),
          content: Text('Código: ${res['codigo']}', style: TextStyle(color: ambuTextGray)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => SeguimientoEmergenciaScreen(codigoEmergencia: res['codigo'])
                ));
              },
              child: Text('VER SEGUIMIENTO', style: TextStyle(color: ambuRed)),
            ),
          ],
        ),
      );
    } else {
      _mostrarAlerta(res['mensaje'] ?? 'Error al enviar');
    }
  }

  void _mostrarAlerta(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: ambuRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER PERSONALIZADO ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NUEVA SOLICITUD', style: TextStyle(color: ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text(widget.esParaMi ? 'Para mí' : 'Para otra persona', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            // --- FORMULARIO CON SCROLL ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // --- TARJETA DE GPS ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _miUbicacion != null ? Colors.green.withOpacity(0.1) : ambuCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _miUbicacion != null ? Colors.green : Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _miUbicacion != null ? Icons.my_location : Icons.location_searching, 
                            color: _miUbicacion != null ? Colors.greenAccent : ambuTextGray
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('UBICACIÓN DE LA EMERGENCIA', style: TextStyle(color: _miUbicacion != null ? Colors.greenAccent : ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                _cargandoUbicacion 
                                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent))
                                  : Text(_textoUbicacion, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                if (_miUbicacion != null)
                                  Text('Lat: ${_miUbicacion!.latitude.toStringAsFixed(5)}, Lng: ${_miUbicacion!.longitude.toStringAsFixed(5)}', style: TextStyle(color: ambuTextGray, fontSize: 10)),
                              ],
                            ),
                          ),
                          if (_miUbicacion == null && !_cargandoUbicacion)
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: () {
                                setState(() { _cargandoUbicacion = true; _textoUbicacion = 'Obteniendo ubicación...'; });
                                _obtenerUbicacion();
                              },
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. RELACIÓN (Solo si es para otra persona)
                    if (!widget.esParaMi) ...[
                      Text('RELACIÓN CON LA PERSONA', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildChipRelacion('Familiar'),
                          const SizedBox(width: 8),
                          _buildChipRelacion('Amigo/a'),
                          const SizedBox(width: 8),
                          _buildChipRelacion('Desconocido'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. DATOS DE LA PERSONA
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DATOS DE LA PERSONA', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 16),
                            
                            _buildLabel('NOMBRE COMPLETO'),
                            _buildTextField(_nombreController, 'Ej: Roberto García'),
                            
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  _buildLabel('EDAD APROX.'),
                                  _buildTextField(_edadController, 'Ej: 58', isNumber: true),
                                ])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  _buildLabel('TIPO SANGRE'),
                                  _buildTextField(_tipoSangreController, 'Ej: O+'),
                                ])),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            _buildLabel('TELÉFONO'),
                            _buildTextField(_telefonoController, 'Ej: +57 300 123 4567', isNumber: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 3. SITUACIÓN
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: ambuCardBg, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SITUACIÓN DE EMERGENCIA', style: TextStyle(color: ambuTextGray, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 16),
                          _buildLabel('¿QUÉ OCURRE?'),
                          TextField(
                            controller: _descripcionController,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ej: Cayó al suelo, no responde, respira con dificultad...',
                              hintStyle: TextStyle(color: ambuTextGray.withOpacity(0.5), fontStyle: FontStyle.italic),
                              filled: true,
                              fillColor: ambuDarkBg,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Dirección extra
                          _buildLabel('DIRECCIÓN O REFERENCIA (Opcional)'),
                          _buildTextField(_direccionController, 'Ej: Calle 10 # 5-20, Barrio Centro'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // --- BOTÓN ENVIAR ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_cargando || _cargandoUbicacion) ? null : _enviarSolicitud,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ambuRed,
                    disabledBackgroundColor: ambuRed.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _cargando 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(
                        _cargandoUbicacion ? 'OBTENIENDO GPS...' : 'ENVIAR SOLICITUD', 
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildChipRelacion(String label) {
    final isSelected = _relacionSeleccionada == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _relacionSeleccionada = label),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? ambuRed.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? ambuRed : ambuTextGray.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? ambuRed : ambuTextGray, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: ambuTextGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: ambuTextGray.withOpacity(0.5)),
        filled: true,
        fillColor: ambuDarkBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}