import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/screens/usuario/home/home_screem_user.dart';
import 'package:plenonexo/screens/usuario/rating/professional_rating_screen.dart';
import 'package:plenonexo/services/user_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
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
    if (user != null) {
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
        _selectedNeurodiversities = user.neuroDiversity ?? [];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2A475E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare neurodiversity data
      List<String> neurodiversity = List.from(_selectedNeurodiversities);

      // Handle "Outros" option
      if (_selectedNeurodiversities.contains('Outros')) {
        if (_otherNeurodiversityController.text.trim().isNotEmpty) {
          // Remove "Outros" and add the custom text
          neurodiversity.remove('Outros');
          neurodiversity.add(_otherNeurodiversityController.text.trim());
        }
      }

      // Remove "Nenhum" if other options are selected
      if (neurodiversity.contains('Nenhum') && neurodiversity.length > 1) {
        neurodiversity.remove('Nenhum');
      }

      // Update user data
      await _userService.updateUserProfile(
        uid: _currentUser!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        state: _selectedState,
        birthDate: _selectedBirthDate?.toIso8601String(),
        neuroDiversity: neurodiversity,
        password: _passwordController.text.trim().isNotEmpty
            ? _passwordController.text.trim()
            : null,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
          obscureText: isPassword,
          inputFormatters: inputFormatters,
          validator: validator,
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
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        if (controller == _passwordController) {
                          _isPasswordVisible = !_isPasswordVisible;
                        } else {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        }
                      });
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    String hint = 'Selecione',
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
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 50),
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
                        // Title
                        Center(
                          child: Text(
                            'Perfil',
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Personal Data Form
                        _buildTextField(
                          label: 'Nome',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                        ),

                        _buildTextField(
                          label: 'E-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'E-mail é obrigatório';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'E-mail inválido';
                            }
                            return null;
                          },
                        ),

                        _buildTextField(
                          label: 'Cidade',
                          controller: _cityController,
                        ),

                        _buildDropdownField(
                          label: 'Estado',
                          items: _states,
                          value: _selectedState,
                          onChanged: (value) {
                            setState(() {
                              _selectedState = value;
                            });
                          },
                        ),

                        _buildTextField(
                          label: 'Telefone',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneFormatter],
                        ),

                        // Birth Date
                        Column(
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
                              onTap: _selectBirthDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedBirthDate != null
                                            ? '${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}'
                                            : 'Selecione a data',
                                        style: TextStyle(
                                          color: _selectedBirthDate != null
                                              ? Colors.black
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                        _buildTextField(
                          label: 'Senha',
                          controller: _passwordController,
                          isPassword: !_isPasswordVisible,
                        ),

                        _buildTextField(
                          label: 'Confirme a Senha',
                          controller: _confirmPasswordController,
                          isPassword: !_isConfirmPasswordVisible,
                        ),

                        const SizedBox(height: 24),

                        // Neurodiversity Section
                        Text(
                          'Editar Neuro diversidade',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _neurodiversityOptions.map((option) {
                            final isSelected = _selectedNeurodiversities
                                .contains(option);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedNeurodiversities.remove(option);
                                    if (option == 'Outros') {
                                      _otherNeurodiversityController.clear();
                                    }
                                  } else {
                                    _selectedNeurodiversities.add(option);
                                    // If "Nenhum" is selected, clear all others
                                    if (option == 'Nenhum') {
                                      _selectedNeurodiversities.clear();
                                      _selectedNeurodiversities.add('Nenhum');
                                    }
                                    // If any other option is selected, remove "Nenhum"
                                    else if (_selectedNeurodiversities.contains(
                                      'Nenhum',
                                    )) {
                                      _selectedNeurodiversities.remove(
                                        'Nenhum',
                                      );
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF5E8D6B)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF5E8D6B)
                                        : Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      option,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        if (_selectedNeurodiversities.contains('Outros')) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Informe sua Neuro Diversidade',
                            controller: _otherNeurodiversityController,
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Action Buttons
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
                                  elevation: 0,
                                ),
                                child: Text(
                                  'CANCELAR ALTERAÇÕES',
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
                                  elevation: 0,
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
                                        'CONFIRMAR ALTERAÇÕES',
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
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: const Color(0xFF2A475E).withOpacity(0.6),
        selectedItemColor: const Color(0xFF2A475E),
        currentIndex: 2, // Profile edit screen is the profile tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const UserHomeScreen()),
                (route) => false,
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessionalRatingScreen(),
                ),
              );
              break;
            case 2:
              // Already on profile edit screen
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Avaliações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
