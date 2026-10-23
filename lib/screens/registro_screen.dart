import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import 'ficha_medica_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Separamos en Nombres y Apellidos
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  
  bool _aceptaPolitica = false;
  bool _cargando = false;

  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  // Función para abrir el calendario y validar mayoría de edad
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: ambuRed, onPrimary: Colors.white, surface: ambuCardBg),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hoy = DateTime.now();
      int edad = hoy.year - picked.year;
      if (hoy.month < picked.month || (hoy.month == picked.month && hoy.day < picked.day)) {
        edad--;
      }

      if (edad < 18) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes ser mayor de edad para registrarte'), backgroundColor: Colors.red));
        }
      } else {
        setState(() {
          _fechaNacimientoController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        });
      }
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_aceptaPolitica) {
      _mostrarAlerta('Debe aceptar la Política de Tratamiento de Datos para continuar.');
      return;
    }

    setState(() => _cargando = true);

    // Unimos nombres y apellidos para enviarlos al backend
    String nombreCompleto = "${_nombresController.text.trim()} ${_apellidosController.text.trim()}";

    final resultado = await ApiService.registrarUsuario(
      nombre: nombreCompleto,
      email: _emailController.text.trim(),
      password: _passwordController.text,
      telefono: _telefonoController.text.trim(),
      fechaNacimiento: _fechaNacimientoController.text.trim(),
    );

    if (mounted) setState(() => _cargando = false);

    if (resultado['success'] == true) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FichaMedicaScreen(usuarioId: resultado['usuario_id'])),
        );
      }
    } else {
      _mostrarAlerta(resultado['mensaje'] ?? 'Error al registrar');
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ambuCardBg,
        title: const Text('AmbuFlash', style: TextStyle(color: Colors.white)),
        content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: ambuRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Crear Cuenta', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Paso 1: Datos Personales', style: TextStyle(color: ambuTextGray, fontSize: 14)),
                const SizedBox(height: 24),

                // --- NOMBRES ---
                _buildTextField(
                  _nombresController, 
                  'Nombres *', 
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(v)) return 'Solo se permiten letras';
                    return null;
                  }
                ),
                const SizedBox(height: 16),

                // --- APELLIDOS ---
                _buildTextField(
                  _apellidosController, 
                  'Apellidos *', 
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(v)) return 'Solo se permiten letras';
                    return null;
                  }
                ),
                const SizedBox(height: 16),
                
                // --- CORREO ---
                _buildTextField(
                  _emailController, 
                  'Correo electrónico *', 
                  keyboardType: TextInputType.emailAddress, 
                  validator: (v) {
                    if (v == null || !RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(v)) return 'Correo inválido';
                    return null;
                  }
                ),
                const SizedBox(height: 16),

                // --- TELÉFONO ---
                _buildTextField(
                  _telefonoController, 
                  'Teléfono *', 
                  keyboardType: TextInputType.phone, 
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v == null || v.length != 10) return 'Debe tener exactamente 10 dígitos';
                    return null;
                  }
                ),
                const SizedBox(height: 16),
                
                // --- FECHA DE NACIMIENTO ---
                TextFormField(
                  controller: _fechaNacimientoController,
                  readOnly: true,
                  onTap: _seleccionarFecha,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Fecha Nacimiento *', icon: Icons.calendar_today),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                // --- CONTRASEÑA ---
                _buildTextField(
                  _passwordController, 
                  'Contraseña *', 
                  obscureText: true, 
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                    if (!v.contains(RegExp(r'[A-Z]'))) return 'Falta una mayúscula';
                    if (!v.contains(RegExp(r'[a-z]'))) return 'Falta una minúscula';
                    if (!v.contains(RegExp(r'[0-9]'))) return 'Falta un número';
                    return null;
                  }
                ),
                const SizedBox(height: 16),
                
                // --- CONFIRMAR CONTRASEÑA ---
                _buildTextField(
                  _confirmPasswordController, 
                  'Confirmar Contraseña *', 
                  obscureText: true, 
                  validator: (v) => v != _passwordController.text ? 'No coinciden' : null
                ),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _aceptaPolitica,
                      onChanged: (val) => setState(() => _aceptaPolitica = val!),
                      activeColor: ambuRed,
                      checkColor: Colors.white,
                    ),
                    Expanded(
                      child: Text('Acepto la Política de Tratamiento de Datos', style: TextStyle(color: ambuTextGray, fontSize: 13)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrar,
                    style: ElevatedButton.styleFrom(backgroundColor: ambuRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _cargando 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('CONTINUAR →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    bool obscureText = false, 
    TextInputType? keyboardType, 
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: _inputDecoration(label),
    );
  }
}