import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';

class RegistroAmbulanciaScreen extends StatefulWidget {
  const RegistroAmbulanciaScreen({super.key});

  @override
  State<RegistroAmbulanciaScreen> createState() => _RegistroAmbulanciaScreenState();
}

class _RegistroAmbulanciaScreenState extends State<RegistroAmbulanciaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores Conductor
  final _cNombres = TextEditingController();
  final _cApellidos = TextEditingController();
  final _cCedula = TextEditingController();
  final _cTelefono = TextEditingController();
  final _cEmail = TextEditingController();
  final _cPassword = TextEditingController();
  final _cConfirmPassword = TextEditingController(); // NUEVO
  final _cLicencia = TextEditingController();

  // Controladores Paramédico
  final _pNombres = TextEditingController();
  final _pApellidos = TextEditingController();
  final _pCedula = TextEditingController();
  final _pTelefono = TextEditingController();
  final _pRegistro = TextEditingController();

  // Controladores Vehículo
  final _vCodigo = TextEditingController();
  final _vPlaca = TextEditingController();
  final _vHospital = TextEditingController();
  final _vSoat = TextEditingController();
  final _vRevision = TextEditingController();

  bool _cargando = false;

  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    // Unimos los nombres y apellidos antes de enviarlos
    String nombreConductor = "${_cNombres.text.trim()} ${_cApellidos.text.trim()}";
    String nombreParamedico = "${_pNombres.text.trim()} ${_pApellidos.text.trim()}";

    final res = await ApiService.registrarAmbulancia({
      'conductor_nombre': nombreConductor,
      'conductor_cedula': _cCedula.text.trim(),
      'conductor_telefono': _cTelefono.text.trim(),
      'conductor_email': _cEmail.text.trim(),
      'conductor_password': _cPassword.text,
      'conductor_licencia': _cLicencia.text.trim(),
      'paramedico_nombre': nombreParamedico,
      'paramedico_cedula': _pCedula.text.trim(),
      'paramedico_telefono': _pTelefono.text.trim(),
      'paramedico_registro': _pRegistro.text.trim(),
      'ambulancia_codigo': _vCodigo.text.trim(),
      'ambulancia_placa': _vPlaca.text.trim(),
      'ambulancia_hospital': _vHospital.text.trim(),
      'ambulancia_soat': _vSoat.text.trim(),
      'ambulancia_revision': _vRevision.text.trim(),
    });

    if (mounted) setState(() => _cargando = false);

    if (res['success'] == true) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ambuCardBg,
            title: const Text('¡Registro Exitoso!', style: TextStyle(color: Colors.white)),
            content: Text(res['mensaje'], style: TextStyle(color: ambuTextGray)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra diálogo
                  Navigator.pop(context); // Vuelve al Login
                },
                child: Text('OK', style: TextStyle(color: ambuRed)),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje']), backgroundColor: ambuRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(
        title: const Text('Registrar Ambulancia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECCIÓN 1: CONDUCTOR ---
                _buildSectionTitle('1. Datos del Conductor'),
                _buildTextField(_cNombres, 'Nombres *', isName: true),
                const SizedBox(height: 12),
                _buildTextField(_cApellidos, 'Apellidos *', isName: true),
                const SizedBox(height: 12),
                _buildTextField(_cCedula, 'Cédula *', isNumber: true, maxLength: 10),
                const SizedBox(height: 12),
                _buildTextField(_cTelefono, 'Teléfono *', isNumber: true, maxLength: 10),
                const SizedBox(height: 12),
                _buildTextField(_cEmail, 'Correo Electrónico *', isEmail: true),
                const SizedBox(height: 12),
                _buildTextField(_cPassword, 'Contraseña *', isPassword: true),
                const SizedBox(height: 12),
                _buildTextField(_cConfirmPassword, 'Confirmar Contraseña *', isPassword: true, isConfirmPassword: true), // NUEVO
                const SizedBox(height: 12),
                _buildTextField(_cLicencia, 'Licencia de Conducción *'),

                const SizedBox(height: 32),

                // --- SECCIÓN 2: PARAMÉDICO ---
                _buildSectionTitle('2. Datos del Paramédico'),
                _buildTextField(_pNombres, 'Nombres *', isName: true),
                const SizedBox(height: 12),
                _buildTextField(_pApellidos, 'Apellidos *', isName: true),
                const SizedBox(height: 12),
                _buildTextField(_pCedula, 'Cédula *', isNumber: true, maxLength: 10),
                const SizedBox(height: 12),
                _buildTextField(_pTelefono, 'Teléfono *', isNumber: true, maxLength: 10),
                const SizedBox(height: 12),
                _buildTextField(_pRegistro, 'Registro Profesional *'),

                const SizedBox(height: 32),

                // --- SECCIÓN 3: VEHÍCULO ---
                _buildSectionTitle('3. Datos del Vehículo'),
                _buildTextField(_vCodigo, 'Código Interno * (Ej: AMB-01)'),
                const SizedBox(height: 12),
                _buildTextField(_vPlaca, 'Placa del Vehículo * (Ej: ABC-123)'),
                const SizedBox(height: 12),
                _buildTextField(_vHospital, 'Hospital o Clínica *'),
                const SizedBox(height: 12),
                
                // Fechas con calendario
                TextFormField(
                  controller: _vSoat,
                  readOnly: true,
                  onTap: () => _seleccionarFecha(_vSoat),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Vencimiento SOAT *', icon: Icons.calendar_today),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vRevision,
                  readOnly: true,
                  onTap: () => _seleccionarFecha(_vRevision),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Vencimiento Revisión *', icon: Icons.calendar_today),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),

                const SizedBox(height: 40),

                // --- BOTÓN GUARDAR ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ambuRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _cargando 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('GUARDAR REGISTRO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(text, style: TextStyle(color: ambuRed, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: ambuTextGray),
      prefixIcon: icon != null ? Icon(icon, color: ambuTextGray, size: 20) : null,
      filled: true,
      fillColor: ambuCardBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ambuRed, width: 1.5)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, {
    bool isPassword = false, 
    bool isNumber = false, 
    bool isName = false,
    bool isEmail = false,
    bool isConfirmPassword = false,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        if (isNumber) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: _inputDecoration(label),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requerido';
        if (isName && !RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(v)) return 'Solo se permiten letras';
        if (isEmail && !RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(v)) return 'Correo inválido';
        if (isNumber && maxLength != null && v.length != maxLength) return 'Debe tener $maxLength dígitos';
        if (isPassword && v.length < 6) return 'Mínimo 6 caracteres';
        if (isConfirmPassword && v != _cPassword.text) return 'Las contraseñas no coinciden'; // Validación de confirmación
        return null;
      },
    );
  }
}