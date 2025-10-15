import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/services/professional_service.dart';
import 'package:plenonexo/utils/app_theme.dart';

class EditarInformacoesPage extends StatefulWidget {
  const EditarInformacoesPage({super.key});

  @override
  State<EditarInformacoesPage> createState() => _EditarInformacoesPageState();
}

class _EditarInformacoesPageState extends State<EditarInformacoesPage> {
  final ProfessionalService _professionalService = ProfessionalService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _consultationPriceController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _professionalIdController = TextEditingController();
  final _accessibleLocationController = TextEditingController();
  final _outrasEspecialidadesController = TextEditingController();

  // Máscaras
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Variáveis de estado
  bool _isLoading = true;
  ProfessionalModel? _currentProfessional;
  String? _selectedAtuationArea;
  List<String> _atuationAreas = [];
  List<String> _selectedModalidades = [];
  List<String> _selectedEspecialidades = [];
  List<String> _selectedAccessibilityFeatures = [];
  List<bool> _availableDays = List.filled(7, false);
  bool _showAddressFields = false;
  bool _naoPossuiCodigo = false;

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

  final List<String> _modalidadesList = ['Online', 'Presencial', 'Híbrido'];

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
    _atuationAreas = _professionalService.getAtuationAreas();
    _loadProfessionalData();
  }

  Future<void> _loadProfessionalData() async {
    setState(() => _isLoading = true);
    try {
      final professional = await _professionalService
          .getCurrentProfessionalData();
      if (professional != null) {
        setState(() {
          _currentProfessional = professional;
          _nameController.text = professional.name;
          _phoneController.text = professional.phone;
          _consultationPriceController.text = professional.consultationPrice
              .toString()
              .replaceAll('.', ',');
          _cityController.text = professional.city;
          _streetController.text = professional.officeAddress.split(',').first;
          _professionalIdController.text = professional.professionalId;
          _accessibleLocationController.text = professional.accessibleLocation;
          _selectedAtuationArea = professional.atuationArea;
          _selectedModalidades = professional.serviceModality.split(', ');
          _selectedEspecialidades = professional.especialidades;
          _selectedAccessibilityFeatures = professional.accessibilityFeatures;
          _availableDays = professional.availableDays;
          _naoPossuiCodigo = professional.professionalId == 'N/A';

          _showAddressFields =
              _selectedModalidades.contains('Presencial') ||
              _selectedModalidades.contains('Híbrido');

          // Preenche o campo "Outros" se necessário
          final outras = _selectedEspecialidades.firstWhere(
            (e) => !_especialidadesList.contains(e),
            orElse: () => '',
          );
          if (outras.isNotEmpty) {
            _outrasEspecialidadesController.text = outras;
            if (!_selectedEspecialidades.contains('Outros')) {
              _selectedEspecialidades.add('Outros');
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
    _consultationPriceController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _professionalIdController.dispose();
    _accessibleLocationController.dispose();
    _outrasEspecialidadesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      double consultationPrice = 0.0;
      if (_consultationPriceController.text.trim().isNotEmpty) {
        String priceText = _consultationPriceController.text.trim().replaceAll(
          ',',
          '.',
        );
        consultationPrice = double.tryParse(priceText) ?? 0.0;
      }

      final List<String> finalEspecialidades = List.from(
        _selectedEspecialidades,
      );
      if (_selectedEspecialidades.contains('Outros')) {
        finalEspecialidades.remove('Outros');
        if (_outrasEspecialidadesController.text.trim().isNotEmpty) {
          finalEspecialidades.add(_outrasEspecialidadesController.text.trim());
        }
      }

      final addressParts = [
        _streetController.text.trim(),
        _numberController.text.trim(),
        _neighborhoodController.text.trim(),
        _cityController.text.trim(),
      ];
      final fullAddress = addressParts
          .where((part) => part.isNotEmpty)
          .join(', ');

      await _professionalService.updateProfessionalProfile(
        uid: _currentProfessional!.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        officeAddress: fullAddress,
        city: _cityController.text.trim(),
        atuationArea: _selectedAtuationArea ?? '',
        professionalId: _naoPossuiCodigo
            ? 'N/A'
            : _professionalIdController.text.trim(),
        accessibleLocation: _accessibleLocationController.text.trim(),
        serviceModality: _selectedModalidades.join(', '),
        accessibilityFeatures: _selectedAccessibilityFeatures,
        consultationPrice: consultationPrice,
        especialidades: finalEspecialidades,
        availableDays: _availableDays,
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
          : _currentProfessional == null
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
                    const SizedBox(height: 24),
                    _buildSectionTitle('Endereço e Atuação'),
                    _buildDropdownField(
                      label: 'Área de Atuação',
                      items: _atuationAreas,
                      value: _selectedAtuationArea,
                      onChanged: (v) =>
                          setState(() => _selectedAtuationArea = v),
                    ),
                    _buildModalidadeCheckboxes(),
                    if (_showAddressFields) ...[
                      _buildTextField(
                        label: 'Cidade',
                        controller: _cityController,
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
                      _buildAccessibilityDropdown(),
                    ],
                    _buildTextField(
                      label: 'Código Profissional (Ex: CRM, CRP)',
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
                        ),
                        const Text('Não possuo código profissional'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Detalhes do Atendimento'),
                    _buildTextField(
                      label: 'Valor da Consulta (R\$)',
                      controller: _consultationPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    _buildEspecialidadesCheckboxes(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Disponibilidade'),
                    _buildAvailableDaysCheckboxes(),
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
    bool isEnabled = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        enabled: isEnabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEspecialidadesCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Especialidades em Neurodiversidade',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppTheme.pretoPrincipal,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ExpansionTile(
            title: Text(
              _selectedEspecialidades.isEmpty ||
                      _selectedEspecialidades.every((e) => e.isEmpty)
                  ? 'Selecione suas especialidades'
                  : '${_selectedEspecialidades.where((e) => e.isNotEmpty).length} selecionada(s)',
            ),
            children: _especialidadesList.map((especialidade) {
              return CheckboxListTile(
                title: Text(especialidade),
                value: _selectedEspecialidades.contains(especialidade),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedEspecialidades.add(especialidade);
                    } else {
                      _selectedEspecialidades.remove(especialidade);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        if (_selectedEspecialidades.contains('Outros'))
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildTextField(
              label: 'Especifique outras especialidades',
              controller: _outrasEspecialidadesController,
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Modalidade de Atendimento',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppTheme.pretoPrincipal,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ExpansionTile(
            title: Text(
              _selectedModalidades.isEmpty
                  ? 'Selecione as modalidades'
                  : '${_selectedModalidades.length} selecionada(s)',
            ),
            children: _modalidadesList.map((modalidade) {
              return CheckboxListTile(
                title: Text(modalidade),
                value: _selectedModalidades.contains(modalidade),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedModalidades.add(modalidade);
                    } else {
                      _selectedModalidades.remove(modalidade);
                    }
                    _showAddressFields =
                        _selectedModalidades.contains('Presencial') ||
                        _selectedModalidades.contains('Híbrido');
                  });
                },
              );
            }).toList(),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Recursos de Acessibilidade',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppTheme.pretoPrincipal,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ExpansionTile(
            title: Text(
              _selectedAccessibilityFeatures.isEmpty
                  ? 'Selecione os recursos'
                  : '${_selectedAccessibilityFeatures.length} selecionado(s)',
            ),
            children: _accessibilityOptions.map((option) {
              return CheckboxListTile(
                title: Text(option, style: const TextStyle(fontSize: 14)),
                value: _selectedAccessibilityFeatures.contains(option),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedAccessibilityFeatures.add(option);
                    } else {
                      _selectedAccessibilityFeatures.remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAvailableDaysCheckboxes() {
    final days = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(7, (index) {
        return ChoiceChip(
          label: Text(days[index]),
          selected: _availableDays[index],
          onSelected: (selected) {
            setState(() {
              _availableDays[index] = selected;
            });
          },
          selectedColor: AppTheme.primaryGreen,
          labelStyle: TextStyle(
            color: _availableDays[index]
                ? Colors.white
                : AppTheme.pretoPrincipal,
          ),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _availableDays[index]
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade400,
            ),
          ),
        );
      }),
    );
  }
}
