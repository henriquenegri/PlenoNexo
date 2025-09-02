import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/services.dart';

class CadastrarUsuario extends StatefulWidget {
  const CadastrarUsuario({super.key});

  @override
  State<CadastrarUsuario> createState() => _CadastrarUsuarioState();
}

class _CadastrarUsuarioState extends State<CadastrarUsuario> {
  final AuthService _authService = AuthService();

  // Controllers para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Criando as máscaras
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  // MUDANÇA: Adicionando a máscara para a data de nascimento
  final _dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Variáveis de estado
  bool _isLoading = false;
  String? _paraQuemERegistro;
  final Set<String> _neuroDiversidades = {};
  bool _termosAceitos = false;
  String? _estadoSelecionado;
  final List<String> _estadosBrasileiros = [
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validação de CPF
    final cpf = _cpfController.text;
    if (cpf.isNotEmpty && !CPFValidator.isValid(cpf)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O CPF informado não é válido.')),
      );
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha os campos obrigatórios.'),
        ),
      );
      return;
    }
    if (_paraQuemERegistro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione para quem é o registro.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.registerPatient(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      state: _estadoSelecionado ?? '',
      city: _cityController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      cpf: _cpfController.text.trim(),
      phone: _phoneController.text.trim(),
      register: _paraQuemERegistro,
      neurodiversities: _neuroDiversidades.toList(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.corpoTextoBranco),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: AppTheme.pretoPrincipal),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.brancoPrincipal,
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
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppTheme.pretoPrincipal,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 100),
                const SizedBox(height: 8),
                Text(
                  'PlenoNexo',
                  style: AppTheme.tituloPrincipal.copyWith(
                    color: AppTheme.pretoPrincipal,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.azul13,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Text('CADASTRAR', style: AppTheme.tituloPrincipal),
                          const SizedBox(height: 2),
                          Divider(
                            color: AppTheme.brancoPrincipal.withAlpha(128),
                            thickness: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Nome Completo:',
                        controller: _nameController,
                      ),
                      _buildTextField(
                        label: 'E-mail:',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado:',
                                  style: AppTheme.corpoTextoBranco,
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _estadoSelecionado,
                                  items: _estadosBrasileiros
                                      .map(
                                        (String estado) =>
                                            DropdownMenuItem<String>(
                                              value: estado,
                                              child: Text(estado),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: (newValue) {
                                    setState(
                                      () => _estadoSelecionado = newValue,
                                    );
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppTheme.brancoPrincipal,
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Cidade:',
                              controller: _cityController,
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        label: 'Data Nascimento:',
                        controller: _birthDateController,
                        keyboardType: TextInputType.datetime,
                        // MUDANÇA: Aplicando a máscara de data
                        inputFormatters: [_dateFormatter],
                      ),
                      _buildTextField(
                        label: 'Informe o CPF:',
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cpfFormatter],
                      ),
                      _buildTextField(
                        label: 'Telefone:',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneFormatter],
                      ),
                      _buildTextField(
                        label: 'Crie sua Senha:',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Para quem é o registro?',
                        style: AppTheme.corpoTextoBranco,
                      ),
                      Wrap(
                        spacing: 8.0,
                        children:
                            [
                                  'Para mim',
                                  'Para meu filho/minha filha',
                                  'Para outro familiar',
                                  'Para um amigo',
                                ]
                                .map(
                                  (label) => ChoiceChip(
                                    label: Text(label),
                                    selected: _paraQuemERegistro == label,
                                    onSelected: (isSelected) => setState(
                                      () => _paraQuemERegistro = label,
                                    ),
                                    backgroundColor: AppTheme.azul9,
                                    selectedColor: AppTheme.azul5,
                                    labelStyle: AppTheme.corpoTextoBranco
                                        .copyWith(fontSize: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Possui Alguma Neuro Diversidade?',
                        style: AppTheme.corpoTextoBranco,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            [
                                  'Autismo',
                                  'Dislexia',
                                  'Dispraxia',
                                  'Discalculia',
                                  'TOC',
                                  'TDAH',
                                  'Transtorno Bipolar',
                                  'TPS',
                                  'Ansiedade',
                                  'Depressão',
                                  'Nenhum',
                                ]
                                .map(
                                  (label) => FilterChip(
                                    label: Text(label),
                                    selected: _neuroDiversidades.contains(
                                      label,
                                    ),
                                    onSelected: (isSelected) {
                                      setState(() {
                                        if (label == 'Nenhum') {
                                          _neuroDiversidades.clear();
                                          _neuroDiversidades.add('Nenhum');
                                        } else {
                                          _neuroDiversidades.remove('Nenhum');
                                          if (isSelected) {
                                            _neuroDiversidades.add(label);
                                          } else {
                                            _neuroDiversidades.remove(label);
                                          }
                                        }
                                      });
                                    },
                                    backgroundColor: AppTheme.azul9,
                                    selectedColor: AppTheme.azul5,
                                    labelStyle: AppTheme.corpoTextoBranco
                                        .copyWith(fontSize: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _termosAceitos,
                            onChanged: (value) =>
                                setState(() => _termosAceitos = value!),
                            activeColor: AppTheme.brancoPrincipal,
                            checkColor: AppTheme.azul9,
                          ),
                          Expanded(
                            child: Text(
                              'Li e concordo com os Termos de Serviço e a Política de Privacidade.',
                              style: AppTheme.corpoTextoBranco.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _termosAceitos && !_isLoading
                            ? _register
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.azul9,
                          foregroundColor: AppTheme.brancoPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
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
                            : Text('ACESSAR', style: AppTheme.textoBotaoBranco),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
