import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/services/user_service.dart';
import 'package:plenonexo/utils/app_theme.dart';

class EditarInformacoesUsuarioPage extends StatefulWidget {
  const EditarInformacoesUsuarioPage({super.key});

  @override
  State<EditarInformacoesUsuarioPage> createState() =>
      _EditarInformacoesUsuarioPageState();
}

class _EditarInformacoesUsuarioPageState
    extends State<EditarInformacoesUsuarioPage> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _outrasNeurodiversidadesController = TextEditingController();

  // Máscaras
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _birthDateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Variáveis de estado
  bool _isLoading = true;
  UserModel? _currentUser;
  List<String> _selectedNeurodiversities = [];

  final List<String> _neurodiversityOptions = [
    'Autismo',
    'Dislexia',
    'Dispraxia',
    'Discalculia',
    'TOC (Transtorno Obsessivo-Compulsivo)',
    'TDAH (Transtorno do Déficit de Atenção e Hiperatividade)',
    'Transtorno Bipolar',
    'Transtorno de Personalidade Borderline',
    'Ansiedade Generalizada',
    'Depressão',
    'Síndrome de Asperger',
    'Transtorno de Aprendizagem',
    'Deficiência Intelectual',
    'Paralisia Cerebral',
    'Síndrome de Down',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getCurrentUserData();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _phoneController.text = user.phone ?? '';
          _birthDateController.text = user.birthDate ?? '';
          _cityController.text = user.city ?? '';
          _stateController.text = user.state ?? '';
          _selectedNeurodiversities = List<String>.from(
            user.neuroDiversity ?? [],
          );

          // Preenche o campo "Outros" se necessário
          final outras = _selectedNeurodiversities.firstWhere(
            (e) => !_neurodiversityOptions.contains(e),
            orElse: () => '',
          );
          if (outras.isNotEmpty) {
            _outrasNeurodiversidadesController.text = outras;
            if (!_selectedNeurodiversities.contains('Outros')) {
              _selectedNeurodiversities.add('Outros');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _outrasNeurodiversidadesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final List<String> finalNeurodiversities = List.from(
        _selectedNeurodiversities,
      );
      if (_selectedNeurodiversities.contains('Outros')) {
        finalNeurodiversities.remove('Outros');
        if (_outrasNeurodiversidadesController.text.trim().isNotEmpty) {
          finalNeurodiversities.add(
            _outrasNeurodiversidadesController.text.trim(),
          );
        }
      }

      await _userService.updateUserProfile(
        uid: _currentUser!.uid,
        name: _nameController.text.trim(),
        email: _currentUser!.email, // Email não é editável aqui
        phone: _phoneController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        neuroDiversity: finalNeurodiversities,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: AppTheme.vermelho1,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.brancoPrincipal,
        title: const Text('Editar Informações'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? const Center(child: Text('Não foi possível carregar os dados.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Informações Pessoais'),
                    _buildTextField(
                      label: 'Nome Completo',
                      controller: _nameController,
                    ),
                    _buildTextField(
                      label: 'Telefone',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneFormatter],
                    ),
                    _buildTextField(
                      label: 'Data de Nascimento',
                      controller: _birthDateController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [_birthDateFormatter],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Endereço'),
                    _buildTextField(
                      label: 'Cidade',
                      controller: _cityController,
                    ),
                    _buildTextField(
                      label: 'Estado',
                      controller: _stateController,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Neurodiversidades'),
                    _buildNeurodiversityCheckboxes(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Segurança (Opcional)'),
                    _buildTextField(
                      label: 'Nova Senha',
                      controller: _passwordController,
                      isPassword: true,
                      isOptional: true,
                    ),
                    _buildTextField(
                      label: 'Confirmar Nova Senha',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      isOptional: true,
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty &&
                            value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'SALVAR ALTERAÇÕES',
                              style: AppTheme.textoBotaoBranco,
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.pretoPrincipal,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<MaskTextInputFormatter>? inputFormatters,
    bool isPassword = false,
    bool isOptional = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.trim().isEmpty)) {
            return 'Este campo é obrigatório';
          }
          if (validator != null) {
            return validator(value);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNeurodiversityCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ExpansionTile(
            title: Text(
              _selectedNeurodiversities.isEmpty ||
                      _selectedNeurodiversities.every((e) => e.isEmpty)
                  ? 'Selecione as neurodiversidades'
                  : '${_selectedNeurodiversities.where((e) => e.isNotEmpty).length} selecionada(s)',
            ),
            children: _neurodiversityOptions.map((neuro) {
              return CheckboxListTile(
                title: Text(neuro),
                value: _selectedNeurodiversities.contains(neuro),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedNeurodiversities.add(neuro);
                    } else {
                      _selectedNeurodiversities.remove(neuro);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        if (_selectedNeurodiversities.contains('Outros'))
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildTextField(
              label: 'Especifique outras neurodiversidades',
              controller: _outrasNeurodiversidadesController,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
