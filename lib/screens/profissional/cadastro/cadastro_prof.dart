import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/services/professional_service.dart';
import 'package:plenonexo/utils/app_theme.dart';

class ProfessionalRegistrationScreen extends StatefulWidget {
  const ProfessionalRegistrationScreen({super.key});

  @override
  State<ProfessionalRegistrationScreen> createState() =>
      _ProfessionalRegistrationScreenState();
}

class _ProfessionalRegistrationScreenState
    extends State<ProfessionalRegistrationScreen> {
  // Serviços
  final AuthService _authService = AuthService();
  final ProfessionalService _professionalService = ProfessionalService();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityControllerProf = TextEditingController();
  final _professionalIdController = TextEditingController();
  final _accessibleLocation = TextEditingController();
  final _passwordController = TextEditingController();
  final _outrasEspecialidadesController = TextEditingController();
  final _consultationPriceController = TextEditingController();

  // Máscaras
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Variáveis de estado
  bool _isLoading = false;
  bool _termosAceitos = false;
  bool _showAddressFields = false;
  final List<String> _modalidadeAtendimento = [];
  bool _naoPossuiCodigo = false;
  final List<String> _selectedAccessibilityFeatures = [];
  final List<String> _especialidadesNeurodiversidade = [];
  final List<bool> _availableDays = [
    true,
    true,
    true,
    true,
    true,
    false,
    false,
  ]; // [seg, ter, qua, qui, sex, sab, dom]

  // Variáveis para o dropdown de áreas de atuação
  List<String> _areasDeAtuacaoList = [];
  String? _areaDeAtuacaoSelecionada;

  final List<String> _modalidades = ['Online', 'Presencial', 'Híbrido'];

  final List<String> _especialidadesList = [
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

  final List<String> _accessibilityOptions = [
    'Rampas de acesso com corrimão',
    'Banheiro adaptado',
    'Portas e corredores largos – Largura mínima de 80 cm para circulação de cadeiras de rodas e carrinhos',
    'Elevador ou plataforma elevatória',
    'Vagas de estacionamento reservadas',
    'Piso tátil (alerta e direcional)',
    'Sinalização visual clara e contrastante – Placas de identificação, saídas de emergência e rotas de fuga legíveis',
    'Alarmes sonoros e visuais',
    'Materiais em Braille e/ou QR Code acessível',
    'Atendimento inclusivo e capacitação da equipe – Treinamento para Libras básica, acolhimento de pessoas com deficiência intelectual, TEA e mobilidade reduzida',
  ];

  @override
  void initState() {
    super.initState();
    // Carregamos as áreas de atuação do array local
    _areasDeAtuacaoList = _professionalService.getAtuationAreas();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfCnpjController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityControllerProf.dispose();
    _professionalIdController.dispose();
    _accessibleLocation.dispose();
    _passwordController.dispose();
    _outrasEspecialidadesController.dispose();
    _consultationPriceController.dispose();
    super.dispose();
  }

  Future<void> _registerProfessional() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha os campos obrigatórios.'),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final (userCredential, authError) = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (authError != null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authError)));
      }
      return;
    }

    if (userCredential != null) {
      try {
        // Processa as especialidades, incluindo "Outros" se especificado
        final List<String> finalEspecialidades = List.from(
          _especialidadesNeurodiversidade,
        );
        if (_especialidadesNeurodiversidade.contains('Outros')) {
          finalEspecialidades.remove('Outros');
          if (_outrasEspecialidadesController.text.trim().isNotEmpty) {
            finalEspecialidades.add(
              _outrasEspecialidadesController.text.trim(),
            );
          }
        }

        // Converter o valor da consulta para double
        double consultationPrice = 0.0;
        if (_consultationPriceController.text.trim().isNotEmpty) {
          try {
            // Substitui vírgula por ponto para garantir formato correto
            String priceText = _consultationPriceController.text
                .trim()
                .replaceAll(',', '.');
            consultationPrice = double.parse(priceText);
          } catch (e) {}
        }

        // Combina os campos de endereço em uma única string
        final addressParts = [
          _streetController.text.trim(),
          _numberController.text.trim(),
          _neighborhoodController.text.trim(),
          _cityControllerProf.text.trim(),
        ];
        final fullAddress = addressParts
            .where((part) => part.isNotEmpty)
            .join(', ');

        await _professionalService.createProfessionalProfile(
          uid: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          document: _cpfCnpjController.text.trim(),
          city: _cityControllerProf.text.trim(),
          phone: _phoneController.text.trim(),
          officeAddress: fullAddress,
          atuationArea: _areaDeAtuacaoSelecionada ?? '',
          professionalId: _naoPossuiCodigo
              ? 'N/A'
              : _professionalIdController.text.trim(),
          accessibleLocation: _accessibleLocation.text.trim(),
          serviceModality: _modalidadeAtendimento.join(', '),
          accessibilityFeatures: _selectedAccessibilityFeatures,
          especialidades: finalEspecialidades,
          consultationPrice: consultationPrice,
          availableDays: _availableDays,
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastro de profissional realizado com sucesso!'),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
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
    bool isEnabled = true,
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
          enabled: isEnabled,
          style: TextStyle(
            color: isEnabled ? AppTheme.pretoPrincipal : Colors.grey[700],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEnabled ? AppTheme.brancoPrincipal : Colors.grey[300],
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Center(
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
                      color: AppTheme.verde13,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Text(
                              'CADASTRAR PROFISSIONAIS',
                              style: AppTheme.tituloPrincipal,
                            ),
                            const SizedBox(height: 2),
                            Divider(
                              color: AppTheme.brancoPrincipal.withAlpha(128),
                              thickness: 1,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'NOME:',
                          controller: _nameController,
                        ),
                        _buildTextField(
                          label: 'EMAIL:',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          label: 'CPF/CNPJ:',
                          controller: _cpfCnpjController,
                          inputFormatters: [_cpfCnpjFormatter],
                        ),
                        _buildTextField(
                          label: 'TELEFONE:',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneFormatter],
                        ),
                        if (_showAddressFields) ...[
                          _buildTextField(
                            label: 'Cidade',
                            controller: _cityControllerProf,
                          ),
                          _buildTextField(
                            label: 'Bairro',
                            controller: _neighborhoodController,
                          ),
                          _buildTextField(
                            label: 'Rua',
                            controller: _streetController,
                          ),
                          _buildTextField(
                            label: 'Número',
                            controller: _numberController,
                          ),
                        ],
                        _buildDropdownField(
                          label: 'ÁREA DE ATUAÇÃO',
                          items: _areasDeAtuacaoList,
                          value: _areaDeAtuacaoSelecionada,
                          onChanged: (v) =>
                              setState(() => _areaDeAtuacaoSelecionada = v),
                          hint: 'Selecione uma área',
                        ),
                        if (_showAddressFields) _buildAccessibilityDropdown(),
                        if (_showAddressFields) const SizedBox(height: 16),
                        _buildTextField(
                          label: 'CÓDIGO PROFISSIONAL (Ex: CRM, CRP):',
                          controller: _professionalIdController,
                          isEnabled: !_naoPossuiCodigo,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _naoPossuiCodigo,
                              onChanged: (value) {
                                setState(() {
                                  _naoPossuiCodigo = value!;
                                  if (_naoPossuiCodigo) {
                                    _professionalIdController.clear();
                                  }
                                });
                              },
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                            ),
                            Text(
                              'Não possuo código profissional',
                              style: AppTheme.corpoTextoBranco.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildModalidadeCheckboxes(),
                        _buildEspecialidadesCheckboxes(),
                        _buildTextField(
                          label: 'VALOR DA CONSULTA RS: ',
                          controller: _consultationPriceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'DIAS DISPONÍVEIS PARA CONSULTA:',
                          style: AppTheme.corpoTextoBranco,
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: Text(
                                'Segunda-feira',
                                style: AppTheme.corpoTextoBranco,
                              ),
                              value: _availableDays[0],
                              onChanged: (value) =>
                                  setState(() => _availableDays[0] = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Terça-feira',
                                style: AppTheme.corpoTextoBranco,
                              ),
                              value: _availableDays[1],
                              onChanged: (value) =>
                                  setState(() => _availableDays[1] = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Quarta-feira',
                                style: AppTheme.corpoTextoBranco,
                              ),
                              value: _availableDays[2],
                              onChanged: (value) =>
                                  setState(() => _availableDays[2] = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Quinta-feira',
                                style: AppTheme.corpoTextoBranco,
                              ),
                              value: _availableDays[3],
                              onChanged: (value) =>
                                  setState(() => _availableDays[3] = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Sexta-feira',
                                style: AppTheme.corpoTextoBranco,
                              ),
                              value: _availableDays[4],
                              onChanged: (value) =>
                                  setState(() => _availableDays[4] = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Sábado',
                                style: AppTheme.corpoTextoBranco,
                              ),
                              value: _availableDays[5],
                              onChanged: (value) =>
                                  setState(() => _availableDays[5] = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Domingo',
                                style: AppTheme.corpoTextoBranco,
                              ),
                              value: _availableDays[6],
                              onChanged: (value) =>
                                  setState(() => _availableDays[6] = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'SENHA:',
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _termosAceitos,
                              onChanged: (value) =>
                                  setState(() => _termosAceitos = value!),
                              activeColor: AppTheme.brancoPrincipal,
                              checkColor: AppTheme.verde13,
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
                              ? _registerProfessional
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.verde8,
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
                              : Text(
                                  'ACESSAR',
                                  style: AppTheme.textoBotaoBranco,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        Text(label, style: AppTheme.corpoTextoBranco),
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

  Widget _buildModalidadeCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MODALIDADE DE ATENDIMENTO', style: AppTheme.corpoTextoBranco),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.brancoPrincipal,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ExpansionTile(
            title: Text(
              _modalidadeAtendimento.isEmpty
                  ? 'Selecione as modalidades de atendimento'
                  : '${_modalidadeAtendimento.length} modalidade(s) selecionada(s)',
              style: TextStyle(
                color: _modalidadeAtendimento.isEmpty
                    ? Colors.grey[600]
                    : AppTheme.pretoPrincipal,
              ),
            ),
            trailing: Icon(
              Icons.arrow_drop_down,
              color: AppTheme.pretoPrincipal,
            ),
            children: _modalidades.map((modalidade) {
              final isSelected = _modalidadeAtendimento.contains(modalidade);
              return CheckboxListTile(
                title: Text(
                  modalidade,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.pretoPrincipal,
                  ),
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _modalidadeAtendimento.add(modalidade);
                    } else {
                      _modalidadeAtendimento.remove(modalidade);
                    }
                    // Lógica para mostrar/esconder campos de endereço
                    _showAddressFields =
                        _modalidadeAtendimento.contains('Presencial') ||
                        _modalidadeAtendimento.contains('Híbrido');
                  });
                },
                activeColor: AppTheme.verde13,
                checkColor: AppTheme.brancoPrincipal,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEspecialidadesCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESPECIALIDADES EM NEURODIVERSIDADE',
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
              _especialidadesNeurodiversidade.isEmpty
                  ? 'Selecione suas especialidades'
                  : '${_especialidadesNeurodiversidade.length} especialidade(s) selecionada(s)',
              style: TextStyle(
                color: _especialidadesNeurodiversidade.isEmpty
                    ? Colors.grey[600]
                    : AppTheme.pretoPrincipal,
              ),
            ),
            trailing: Icon(
              Icons.arrow_drop_down,
              color: AppTheme.pretoPrincipal,
            ),
            children: _especialidadesList.map((especialidade) {
              final isSelected = _especialidadesNeurodiversidade.contains(
                especialidade,
              );
              return CheckboxListTile(
                title: Text(
                  especialidade,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.pretoPrincipal,
                  ),
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _especialidadesNeurodiversidade.add(especialidade);
                    } else {
                      _especialidadesNeurodiversidade.remove(especialidade);
                    }
                  });
                },
                activeColor: AppTheme.verde13,
                checkColor: AppTheme.brancoPrincipal,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
        if (_especialidadesNeurodiversidade.contains('Outros'))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildTextField(
              label: 'Por favor, especifique outras especialidades:',
              controller: _outrasEspecialidadesController,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccessibilityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECURSOS DE ACESSIBILIDADE', style: AppTheme.corpoTextoBranco),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.brancoPrincipal,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ExpansionTile(
            title: Text(
              _selectedAccessibilityFeatures.isEmpty
                  ? 'Selecione os recursos de acessibilidade'
                  : '${_selectedAccessibilityFeatures.length} recursos selecionados',
              style: TextStyle(
                color: _selectedAccessibilityFeatures.isEmpty
                    ? Colors.grey[600]
                    : AppTheme.pretoPrincipal,
              ),
            ),
            trailing: Icon(
              Icons.arrow_drop_down,
              color: AppTheme.pretoPrincipal,
            ),
            children: _accessibilityOptions.map((option) {
              final isSelected = _selectedAccessibilityFeatures.contains(
                option,
              );
              return CheckboxListTile(
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.pretoPrincipal,
                  ),
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedAccessibilityFeatures.add(option);
                    } else {
                      _selectedAccessibilityFeatures.remove(option);
                    }
                  });
                },
                activeColor: AppTheme.verde13,
                checkColor: AppTheme.brancoPrincipal,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
