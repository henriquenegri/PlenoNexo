import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/services.dart';
import 'package:plenonexo/services/user_service.dart';

class CadastrarUsuario extends StatefulWidget {
  const CadastrarUsuario({super.key});

  @override
  State<CadastrarUsuario> createState() => _CadastrarUsuarioState();
}

class _CadastrarUsuarioState extends State<CadastrarUsuario> {
  // MUDANÇA: Agora temos os dois serviços disponíveis na tela.
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Controllers para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otherNeurodiversityController = TextEditingController();

  // Criando as máscaras
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Variáveis de estado
  bool _isLoading = false;
  String? _paraQuemERegistro;
  final Set<String> _neuroDiversidades = {};
  bool _termosAceitos = false;

  // Lista de neurodiversidades
  final List<String> _neurodiversidadesList = [
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
    'Nenhum',
    'Outros',
  ];
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
    _otherNeurodiversityController.dispose();
    super.dispose();
  }

  // MUDANÇA: A função _register agora segue a nova arquitetura
  Future<void> _register() async {
    // Validações (continuam iguais)
    final cpf = _cpfController.text;
    if (cpf.isNotEmpty && !CPFValidator.isValid(cpf)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O CPF informado não é válido.')),
        );
        return;
      }
    }
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha os campos obrigatórios.'),
          ),
        );
        return;
      }
    }
    // ... outras validações ...

    if (mounted) {
      setState(() => _isLoading = true);
    }

    // Passo 1: Tenta criar a conta de autenticação (chama o "Porteiro")
    final (userCredential, authError) = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Se houve um erro na autenticação, para o processo e mostra a mensagem
    if (authError != null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authError)));
      }
      return;
    }

    // Se a autenticação foi bem-sucedida, prossegue para criar o perfil no banco de dados
    if (userCredential != null) {
      try {
        final List<String> finalNeurodiversities = _neuroDiversidades.toList();
        if (_neuroDiversidades.contains('Outros')) {
          finalNeurodiversities.remove('Outros');
          if (_otherNeurodiversityController.text.trim().isNotEmpty) {
            finalNeurodiversities.add(
              _otherNeurodiversityController.text.trim(),
            );
          }
        }

        // Passo 2: Chama o UserService para guardar os dados (chama o "RH")
        await _userService.createPatientProfile(
          uid: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          state: _estadoSelecionado ?? '',
          city: _cityController.text.trim(),
          birthDate: _birthDateController.text.trim(),
          cpf: _cpfController.text.trim(),
          phone: _phoneController.text.trim(),
          registrationFor: _paraQuemERegistro,
          neurodiversities: finalNeurodiversities,
          password: _passwordController.text.trim(),
        );

        // Se chegou aqui, tudo correu bem!
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Lida com possíveis erros ao guardar no Firestore
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao guardar dados do perfil: $e')),
          );
        }
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
  }) {
    // ... (código inalterado)
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
    // O código da sua UI (build method) continua exatamente o mesmo,
    // apenas a lógica do botão foi alterada na função _register.
    // ... (cole o seu build method completo aqui) ...
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
                SvgPicture.asset('assets/img/NeuroConecta.svg', height: 100),
                const SizedBox(height: 8),
                Text(
                  'AURA',
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
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              label: 'Cidade:',
                              controller: _cityController,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                    if (mounted) {
                                      setState(
                                        () => _estadoSelecionado = newValue,
                                      );
                                    }
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
                        ],
                      ),
                      _buildTextField(
                        label: 'Data Nascimento:',
                        controller: _birthDateController,
                        keyboardType: TextInputType.datetime,
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
                                    onSelected: (isSelected) {
                                      if (mounted) {
                                        setState(
                                          () => _paraQuemERegistro = label,
                                        );
                                      }
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
                      _buildNeurodiversidadeCheckboxes(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _termosAceitos,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() => _termosAceitos = value!);
                              }
                            },
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

  Widget _buildNeurodiversidadeCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Possui Alguma Neuro Diversidade?',
          style: AppTheme.corpoTextoBranco,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.brancoPrincipal,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ExpansionTile(
            title: Text(
              _neuroDiversidades.isEmpty
                  ? 'Selecione as neurodiversidades'
                  : '${_neuroDiversidades.length} neurodiversidade(s) selecionada(s)',
              style: TextStyle(
                color: _neuroDiversidades.isEmpty
                    ? Colors.grey[600]
                    : AppTheme.pretoPrincipal,
              ),
            ),
            trailing: Icon(
              Icons.arrow_drop_down,
              color: AppTheme.pretoPrincipal,
            ),
            children: _neurodiversidadesList.map((neurodiversidade) {
              final isSelected = _neuroDiversidades.contains(neurodiversidade);
              return CheckboxListTile(
                title: Text(
                  neurodiversidade,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.pretoPrincipal,
                  ),
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  if (mounted) {
                    setState(() {
                      if (neurodiversidade == 'Nenhum') {
                        if (value == true) {
                          _neuroDiversidades.clear();
                          _neuroDiversidades.add('Nenhum');
                        }
                      } else {
                        _neuroDiversidades.remove('Nenhum');
                        if (value == true) {
                          _neuroDiversidades.add(neurodiversidade);
                        } else {
                          _neuroDiversidades.remove(neurodiversidade);
                        }
                      }
                    });
                  }
                },
                activeColor: AppTheme.azul13,
                checkColor: AppTheme.brancoPrincipal,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
        if (_neuroDiversidades.contains('Outros'))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildTextField(
              label: 'Por favor, especifique:',
              controller: _otherNeurodiversityController,
            ),
          ),
      ],
    );
  }
}
