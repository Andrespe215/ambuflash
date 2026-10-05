import 'package:flutter/material.dart';
import 'api_service.dart';

const Color ambuRed = Color(0xFFE53935);
const Color ambuDarkBg = Color(0xFF121212);
const Color ambuCardBg = Color(0xFF1E1E1E);
const Color ambuTextGray = Color(0xFFB0B0B0);

class FichaMedicaScreen extends StatefulWidget {
  final int usuarioId;
  const FichaMedicaScreen({super.key, required this.usuarioId});

  @override
  State<FichaMedicaScreen> createState() => _FichaMedicaScreenState();
}

class _FichaMedicaScreenState extends State<FichaMedicaScreen> {
  final TextEditingController alergiasController = TextEditingController();
  final TextEditingController enfermedadesController = TextEditingController();
  final TextEditingController medicamentosController = TextEditingController();
  final TextEditingController cirugiasController = TextEditingController();
  final TextEditingController discapacidadesController = TextEditingController();
  final TextEditingController antecedentesController = TextEditingController();

  final TextEditingController contactoNombreController = TextEditingController();
  final TextEditingController contactoTelefonoController = TextEditingController();

  String? _tipoSangre;
  String _parentesco = 'Padre';
  bool _cargando = false;

  final List<String> _tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _parentescos = ['Padre', 'Madre', 'Hermano/a', 'Cónyuge', 'Hijo/a', 'Amigo/a', 'Otro'];

  Future<void> _guardarFicha() async {
    if (_tipoSangre == null) {
      _mostrarAlerta('Debe seleccionar su tipo de sangre');
      return;
    }
    if (contactoNombreController.text.trim().isEmpty ||
        contactoTelefonoController.text.trim().isEmpty) {
      _mostrarAlerta('Debe completar el contacto de emergencia');
      return;
    }

    setState(() => _cargando = true);

    final resultado = await ApiService.guardarFichaMedica(
      usuarioId: widget.usuarioId,
      tipoSangre: _tipoSangre!,
      alergias: alergiasController.text.trim(),
      enfermedades: enfermedadesController.text.trim(),
      medicamentos: medicamentosController.text.trim(),
      cirugias: cirugiasController.text.trim(),
      discapacidades: discapacidadesController.text.trim(),
      antecedentes: antecedentesController.text.trim(),
      contactoNombre: contactoNombreController.text.trim(),
      contactoParentesco: _parentesco,
      contactoTelefono: contactoTelefonoController.text.trim(),
    );

    if (mounted) setState(() => _cargando = false);

    if (resultado['success'] == true) {
      _mostrarAlerta(
        '¡Ficha médica guardada!\n\nYa puedes solicitar ayuda en caso de emergencia.',
        alCerrar: () {
          Navigator.pop(context);
        },
      );
    } else {
      _mostrarAlerta(resultado['mensaje'] ?? 'Error desconocido');
    }
  }

  void _mostrarAlerta(String mensaje, {VoidCallback? alCerrar}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ambuCardBg,
        title: const Text('AmbuFlash', style: TextStyle(color: Colors.white)),
        content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (alCerrar != null) alCerrar();
            },
            child: const Text('OK', style: TextStyle(color: ambuRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(
        backgroundColor: ambuDarkBg,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text('Ficha Médica',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DATOS CLÍNICOS',
                  style: TextStyle(
                      color: ambuRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 16),

              _label('TIPO DE SANGRE *'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ambuCardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tipoSangre,
                    hint: const Text('Selecciona',
                        style: TextStyle(color: ambuTextGray)),
                    dropdownColor: ambuCardBg,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: _tiposSangre.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (v) => setState(() => _tipoSangre = v),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _label('ALERGIAS'),
              _textField(alergiasController, 'Ej: Penicilina, Mariscos'),

              const SizedBox(height: 16),
              _label('ENFERMEDADES CRÓNICAS'),
              _textField(enfermedadesController, 'Ej: Hipertensión, Asma'),

              const SizedBox(height: 16),
              _label('MEDICAMENTOS ACTUALES'),
              _textField(medicamentosController, 'Ej: Losartán 50mg, Salbutamol'),

              const SizedBox(height: 16),
              _label('CIRUGÍAS PREVIAS'),
              _textField(cirugiasController, 'Ej: Apendicectomía (2019)'),

              const SizedBox(height: 16),
              _label('DISCAPACIDADES'),
              _textField(discapacidadesController, 'Ej: Ninguna'),

              const SizedBox(height: 16),
              _label('ANTECEDENTES FAMILIARES'),
              _textField(antecedentesController, 'Ej: Diabetes tipo 2 familiar'),

              const SizedBox(height: 32),

              const Text('CONTACTO DE EMERGENCIA',
                  style: TextStyle(
                      color: ambuRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 16),

              _label('NOMBRE COMPLETO *'),
              _textField(contactoNombreController, 'Ej: Roberto García'),

              const SizedBox(height: 16),
              _label('PARENTESCO *'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: ambuCardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _parentesco,
                    dropdownColor: ambuCardBg,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: _parentescos.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                    onChanged: (v) => setState(() => _parentesco = v!),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _label('TELÉFONO *'),
              _textField(contactoTelefonoController, '+57 300 1234567',
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardarFicha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ambuRed,
                    disabledBackgroundColor: ambuRed.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('GUARDAR FICHA →',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto,
          style: const TextStyle(
              color: ambuTextGray,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
    );
  }

  Widget _textField(TextEditingController controller, String hint,
      {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ambuTextGray),
        filled: true,
        fillColor: ambuCardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ambuRed, width: 1.5),
        ),
      ),
    );
  }
}