import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Importe para formatar a data
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/screens/welcome/welcome_screen.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/services/user_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otherNeurodiversityController = TextEditingController();

  // Máscaras
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Variáveis de estado
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isCurrentPasswordVisible = false;
  String? _selectedState;
  DateTime? _selectedBirthDate;
  List<String> _selectedNeurodiversities = [];

  UserModel? _currentUser;

  final List<String> _states = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  final List<String> _neurodiversityOptions = [
    'Autismo',
    'TDAH',
    'Transtorno Bipolar',
    'Dislexia',
    'Dispraxia',
    'TPS',
    'Discalculia',
    'Ansiedade',
    'Síndrome Tourette',
    'TOC',
    'Depressão',
    'Nenhum',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getCurrentUserData();
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _cityController.text = user.city ?? '';
        _phoneController.text = user.phone ?? '';
        _selectedState = user.state;
        _selectedBirthDate = user.birthDate != null
            ? DateTime.tryParse(user.birthDate!)
            : null;

        // Carrega as neurodiversidades
        _selectedNeurodiversities = user.neuroDiversity ?? [];

        // Verifica se há uma opção "Outros" personalizada
        String? otherText;
        for (var item in _selectedNeurodiversities) {
          if (!_neurodiversityOptions.contains(item)) {
            otherText = item;
            break;
          }
        }

        if (otherText != null) {
          _selectedNeurodiversities.remove(otherText);
          _selectedNeurodiversities.add('Outros');
          _otherNeurodiversityController.text = otherText;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otherNeurodiversityController.dispose();
    super.dispose();
  }

  String _getFirstName() {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    return _currentUser!.name.split(' ').first;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // --- LÓGICA DE ALTERAÇÃO DE SENHA ---
    if (_currentPasswordController.text.isNotEmpty ||
        _passwordController.text.isNotEmpty) {
      if (_currentPasswordController.text.isEmpty) {
        _showError('Para alterar a senha, informe sua senha atual.');
        return;
      }
      if (_passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showError('Preencha os campos de nova senha e confirmação.');
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('As novas senhas não coincidem.');
        return;
      }

      final (success, message) = await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _passwordController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Senha alterada com sucesso! Por favor, faça login novamente.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          await _authService.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
          );
        }
        return; // Interrompe a execução para não salvar o resto do perfil
      } else {
        _showError(message ?? 'Ocorreu um erro ao alterar a senha.');
        return;
      }
    }

    // --- LÓGICA DE ATUALIZAÇÃO DO PERFIL ---
    try {
      List<String> neurodiversity = List.from(_selectedNeurodiversities);
      if (_selectedNeurodiversities.contains('Outros') &&
          _otherNeurodiversityController.text.trim().isNotEmpty) {
        neurodiversity.remove('Outros');
        neurodiversity.add(_otherNeurodiversityController.text.trim());
      }
      if (neurodiversity.contains('Nenhum') && neurodiversity.length > 1) {
        neurodiversity.remove('Nenhum');
      }

      await _userService.updateUserProfile(
        uid: _currentUser!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        state: _selectedState,
        birthDate: _selectedBirthDate?.toIso8601String(),
        neuroDiversity: neurodiversity,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Color(0xFF5E8D6B),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Erro ao atualizar perfil: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  // **** NOVO MÉTODO ****
  // Função para abrir o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }
  // **** FIM DO NOVO MÉTODO ****

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // **** NOVO WIDGET ****
  // Widget para o Dropdown de Estados
  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedState,
          items: _states.map((String state) {
            return DropdownMenuItem<String>(value: state, child: Text(state));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedState = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  // **** FIM DO NOVO WIDGET ****

  // **** NOVO WIDGET ****
  // Widget para o Seletor de Data de Nascimento
  Widget _buildBirthDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data de Nascimento',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedBirthDate == null
                      ? 'Selecione sua data'
                      : DateFormat('dd/MM/yyyy').format(_selectedBirthDate!),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  // **** FIM DO NOVO WIDGET ****

  // **** NOVO WIDGET ****
  // Widget para os Chips de Neurodiversidade
  Widget _buildNeurodiversityChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Neurodiversidade(s)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _neurodiversityOptions.map((neuro) {
              final isSelected = _selectedNeurodiversities.contains(neuro);
              return FilterChip(
                label: Text(neuro),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedNeurodiversities.add(neuro);
                    } else {
                      _selectedNeurodiversities.remove(neuro);
                    }
                  });
                },
                backgroundColor: Colors.white.withOpacity(0.7),
                selectedColor: const Color(0xFF5E8D6B),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Campo "Outros"
        if (_selectedNeurodiversities.contains('Outros'))
          _buildTextField(
            label: 'Qual(is)?',
            controller: _otherNeurodiversityController,
          ),
      ],
    );
  }
  // **** FIM DO NOVO WIDGET ****

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header (sem alterações)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2A475E),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset('assets/img/PlenoNexo.png', height: 60),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFirstName(),
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A475E),
                        ),
                      ),
                      Text(
                        DateTime.now().toString().split(' ')[0],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2A475E).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A475E).withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Editar Perfil',
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildTextField(
                          label: 'Nome',
                          controller: _nameController,
                        ),
                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          label: 'Cidade',
                          controller: _cityController,
                        ),

                        // **** INÍCIO DAS MUDANÇAS ****

                        // Estado
                        _buildStateDropdown(),

                        // Telefone
                        _buildTextField(
                          label: 'Telefone',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneFormatter],
                        ),

                        // Data de Nascimento
                        _buildBirthDatePicker(),

                        // Neurodiversidades
                        _buildNeurodiversityChips(),

                        // **** FIM DAS MUDANÇAS ****
                        const SizedBox(height: 24),
                        Text(
                          'Alterar Senha',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Senha Atual',
                          controller: _currentPasswordController,
                          obscureText: !_isCurrentPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isCurrentPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(
                              () => _isCurrentPasswordVisible =
                                  !_isCurrentPasswordVisible,
                            ),
                          ),
                        ),

                        _buildTextField(
                          label: 'Nova Senha',
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                          ),
                        ),

                        _buildTextField(
                          label: 'Confirme a Nova Senha',
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(
                              () => _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botões de ação
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC54B4B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'CANCELAR',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5E8D6B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
