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
  final _addressController = TextEditingController();
  final _professionalIdController = TextEditingController();
  final _accessibleLocation = TextEditingController();
  final _passwordController = TextEditingController();

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
  String? _modalidadeAtendimento;
  bool _naoPossuiCodigo = false;
  List<String> _selectedAccessibilityFeatures = [];

  // Variáveis para o dropdown de áreas de atuação
  List<String> _areasDeAtuacaoList = [];
  String? _areaDeAtuacaoSelecionada;

  final List<String> _modalidades = ['Online', 'Presencial', 'Híbrido'];

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
    _addressController.dispose();
    _professionalIdController.dispose();
    _accessibleLocation.dispose();
    _passwordController.dispose();
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
        await _professionalService.createProfessionalProfile(
          uid: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          document: _cpfCnpjController.text.trim(),
          phone: _phoneController.text.trim(),
          officeAddress: _addressController.text.trim(),
          atuationArea: _areaDeAtuacaoSelecionada ?? '',
          professionalId: _naoPossuiCodigo
              ? 'N/A'
              : _professionalIdController.text.trim(),
          accessibleLocation: _accessibleLocation.text.trim(),
          serviceModality: _modalidadeAtendimento ?? '',
          accessibilityFeatures: _selectedAccessibilityFeatures,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
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
                      _buildTextField(
                        label: 'Endereço Consultório',
                        controller: _addressController,
                      ),

                      _buildDropdownField(
                        label: 'ÁREA DE ATUAÇÃO',
                        items: _areasDeAtuacaoList,
                        value: _areaDeAtuacaoSelecionada,
                        onChanged: (v) =>
                            setState(() => _areaDeAtuacaoSelecionada = v),
                        hint: 'Selecione uma área',
                      ),

                      _buildAccessibilityDropdown(),
                      const SizedBox(height: 16),

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

                      _buildDropdownField(
                        label: 'Modalidade Atendimento',
                        items: _modalidades,
                        value: _modalidadeAtendimento,
                        onChanged: (v) =>
                            setState(() => _modalidadeAtendimento = v),
                      ),

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
