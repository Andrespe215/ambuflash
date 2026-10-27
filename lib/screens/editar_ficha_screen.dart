import 'package:flutter/material.dart';
import '../api_service.dart';

class EditarFichaScreen extends StatefulWidget {
  final int usuarioId;
  final Map<String, dynamic> fichaActual;

  const EditarFichaScreen({super.key, required this.usuarioId, required this.fichaActual});

  @override
  State<EditarFichaScreen> createState() => _EditarFichaScreenState();
}

class _EditarFichaScreenState extends State<EditarFichaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _tipoSangre;
  late TextEditingController _alergiasController;
  late TextEditingController _enfermedadesController;
  late TextEditingController _medicamentosController;
  late TextEditingController _cirugiasController;
  late TextEditingController _discapacidadesController;
  late TextEditingController _antecedentesController;
  
  late TextEditingController _contactoNombreController;
  late TextEditingController _contactoParentescoController;
  late TextEditingController _contactoTelefonoController;

  bool _cargando = false;

  final Color ambuRed = const Color(0xFFE53935);
  final Color ambuDarkBg = const Color(0xFF121212);
  final Color ambuCardBg = const Color(0xFF1E1E1E);
  final Color ambuTextGray = const Color(0xFFB0B0B0);

  final List<String> _tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    // Llenamos las variables con los datos que nos pasaron
    _tipoSangre = widget.fichaActual['tipo_sangre'];
    if (!_tiposSangre.contains(_tipoSangre)) _tipoSangre = null; // Por si acaso viene vacío o mal

    _alergiasController = TextEditingController(text: widget.fichaActual['alergias'] ?? '');
    _enfermedadesController = TextEditingController(text: widget.fichaActual['enfermedades_cronicas'] ?? '');
    _medicamentosController = TextEditingController(text: widget.fichaActual['medicamentos_actuales'] ?? '');
    _cirugiasController = TextEditingController(text: widget.fichaActual['cirugias_previas'] ?? '');
    _discapacidadesController = TextEditingController(text: widget.fichaActual['discapacidades'] ?? '');
    _antecedentesController = TextEditingController(text: widget.fichaActual['antecedentes_familiares'] ?? '');
    
    _contactoNombreController = TextEditingController(text: widget.fichaActual['contacto_nombre'] ?? '');
    _contactoParentescoController = TextEditingController(text: widget.fichaActual['contacto_parentesco'] ?? '');
    _contactoTelefonoController = TextEditingController(text: widget.fichaActual['contacto_telefono'] ?? '');
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final resultado = await ApiService.actualizarFichaMedica(
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ficha actualizada correctamente'), backgroundColor: Colors.green));
      Navigator.pop(context, true); // Retorna true para avisar que hubo cambios
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado['mensaje'] ?? 'Error'), backgroundColor: ambuRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ambuDarkBg,
      appBar: AppBar(title: const Text('Editar Ficha Médica'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Actualiza tu información', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                _buildTextField(_alergiasController, 'Alergias'),
                const SizedBox(height: 16),
                _buildTextField(_enfermedadesController, 'Enfermedades crónicas'),
                const SizedBox(height: 16),
                _buildTextField(_medicamentosController, 'Medicamentos actuales'),
                const SizedBox(height: 16),
                _buildTextField(_cirugiasController, 'Cirugías previas'),
                const SizedBox(height: 16),
                _buildTextField(_discapacidadesController, 'Discapacidades'),
                const SizedBox(height: 16),
                _buildTextField(_antecedentesController, 'Antecedentes familiares'),

                const SizedBox(height: 32),
                const Text('Contacto de Emergencia', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(_contactoNombreController, 'Nombre del contacto *', validator: (v) => v!.isEmpty ? 'Requerido' : null),
                const SizedBox(height: 16),
                _buildTextField(_contactoParentescoController, 'Parentesco *', validator: (v) => v!.isEmpty ? 'Requerido' : null),
                const SizedBox(height: 16),
                _buildTextField(_contactoTelefonoController, 'Teléfono de emergencia *', keyboardType: TextInputType.phone, validator: (v) => v!.length < 10 ? 'Mínimo 10 dígitos' : null),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _guardarCambios,
                    style: ElevatedButton.styleFrom(backgroundColor: ambuRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: _inputDecoration(label),
    );
  }
}