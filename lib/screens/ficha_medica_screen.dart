import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- IMPORTANTE PARA LOS FORMATTERS
import '../api_service.dart';
import '../login_paciente.dart'; // Para volver al login correcto

class FichaMedicaScreen extends StatefulWidget {
  final int usuarioId;
  const FichaMedicaScreen({super.key, required this.usuarioId});

  @override
  State<FichaMedicaScreen> createState() => _FichaMedicaScreenState();
}

class _FichaMedicaScreenState extends State<FichaMedicaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _tipoSangre;
  final _alergiasController = TextEditingController();
  final _enfermedadesController = TextEditingController();
  final _medicamentosController = TextEditingController();
  final _cirugiasController = TextEditingController();
  final _discapacidadesController = TextEditingController();
  final _antecedentesController = TextEditingController();
  
  final _contactoNombreController = TextEditingController();
  final _contactoParentescoController = TextEditingController();
  final _contactoTelefonoController = TextEditingController();

  bool _cargando = false;

  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  final List<String> _tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _guardarFicha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final resultado = await ApiService.guardarFichaMedica(
      usuarioId: widget.usuarioId,
      tipoSangre: _tipoSangre!,
      alergias: _alergiasController.text.trim(),
      enfermedades: _enfermedadesController.text.trim(),
      medicamentos: _medicamentosController.text.trim(),
      cirugias: _cirugiasController.text.trim(),
      discapacidades: _discapacidadesController.text.trim(),
      antecedentes: _antecedentesController.text.trim(),
      contactoNombre: _contactoNombreController.text.trim(),
      contactoParentesco: _contactoParentescoController.text.trim(),
      contactoTelefono: _contactoTelefonoController.text.trim(),
    );

    if (mounted) setState(() => _cargando = false);

    if (resultado['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: ambuCardBg,
          title: const Text('¡Registro completado!', style: TextStyle(color: Colors.white)),
          content: Text('Tu ficha médica ha sido guardada exitosamente. Ahora puedes iniciar sesión.', style: TextStyle(color: ambuTextGray)),
          actions: [
            TextButton(
              onPressed: () {
                // Volvemos al Login del Paciente
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPaciente()),
                  (route) => false,
                );
              },
              child: Text('OK', style: TextStyle(color: ambuRed)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado['mensaje'] ?? 'Error'), backgroundColor: ambuRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(title: const Text('Ficha Médica'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Paso 2: Información Clínica', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Esta información es vital para las emergencias.', style: TextStyle(color: ambuTextGray, fontSize: 14)),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _tipoSangre,
                  dropdownColor: ambuCardBg,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Tipo de Sangre *'),
                  items: _tiposSangre.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                  onChanged: (val) => setState(() => _tipoSangre = val),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(_alergiasController, 'Alergias (opcional)'),
                const SizedBox(height: 16),
                _buildTextField(_enfermedadesController, 'Enfermedades crónicas (opcional)'),
                const SizedBox(height: 16),
                _buildTextField(_medicamentosController, 'Medicamentos actuales (opcional)'),
                const SizedBox(height: 16),
                _buildTextField(_cirugiasController, 'Cirugías previas (opcional)'),
                const SizedBox(height: 16),
                _buildTextField(_discapacidadesController, 'Discapacidades (opcional)'),
                const SizedBox(height: 16),
                _buildTextField(_antecedentesController, 'Antecedentes familiares (opcional)'),

                const SizedBox(height: 32),
                const Text('Contacto de Emergencia (Obligatorio)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // --- VALIDACIÓN ESTRICTA AQUÍ ---
                _buildTextField(
                  _contactoNombreController, 
                  'Nombre del contacto *', 
                  isName: true, // Solo letras
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    return null;
                  }
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _contactoParentescoController, 
                  'Parentesco *', 
                  isName: true, // Solo letras
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    return null;
                  }
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _contactoTelefonoController, 
                  'Teléfono de emergencia *', 
                  isNumber: true, // Solo números
                  maxLength: 10,  // Exactamente 10
                  validator: (v) {
                    if (v == null || v.length != 10) return 'Debe tener exactamente 10 dígitos';
                    return null;
                  }
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _guardarFicha,
                    style: ElevatedButton.styleFrom(backgroundColor: ambuRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('GUARDAR FICHA', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: ambuTextGray),
      filled: true,
      fillColor: ambuCardBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ambuRed, width: 1.5)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, {
    bool isNumber = false,
    bool isName = false,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        if (isNumber) FilteringTextInputFormatter.digitsOnly,
        if (isName) FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      validator: (v) {
        // 1. Si el usuario nos pasó una regla específica (ej. "Requerido" o "Mínimo 10"), la usamos.
        if (validator != null) {
           return validator(v);
        }
        
        // 2. Si es un campo opcional (no tiene validador), pero el usuario escribió algo, 
        // comprobamos que no haya metido números si es de tipo nombre.
        if (isName && v != null && v.isNotEmpty && !RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(v)) {
          return 'Solo se permiten letras';
        }
        
        // 3. Para los opcionales, si está vacío o cumple la regla, no hay error.
        return null;
      },
  
      decoration: _inputDecoration(label),
    );
  }
}