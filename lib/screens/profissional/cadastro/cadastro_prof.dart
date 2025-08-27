import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/utils/app_theme.dart';

class CadastrarProfissional extends StatefulWidget {
  const CadastrarProfissional({super.key});

  @override
  State<CadastrarProfissional> createState() => _CadastrarProfissional();
}

class _CadastrarProfissional extends State<CadastrarProfissional> {
  // Variáveis de estado
  bool _termosAceitos = false;
  String? _modalidadeAtendimento;

  // TODO: Substituir por listas de uma API no futuro
  final List<String> _modalidades = ['Online', 'Presencial'];

  // Função auxiliar para criar os campos de texto
  Widget _buildTextField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.corpoTextoBranco),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          obscureText: isPassword,
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

  // Função auxiliar para criar os campos de dropdown
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.corpoTextoBranco),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
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
                SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 100),
                const SizedBox(height: 8),
                Text('PlenoNexo', style: AppTheme.tituloPrincipalPreto),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.verde13, // Cor verde para o profissional
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

                      // --- CAMPOS DO FORMULÁRIO ---
                      _buildTextField(label: 'NOME:'),
                      _buildTextField(
                        label: 'EMAIL:',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(label: 'CPF/CNPJ:'),
                      _buildTextField(
                        label: 'TELEFONE:',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(label: 'Endereço Consultório'),
                      _buildTextField(label: 'ÁREA DE ATUAÇÃO'),
                      _buildTextField(label: 'CÓDIGO PROFISSIONAL'),
                      _buildTextField(label: 'Especialidades'),

                      // Dropdown para Modalidade de Atendimento
                      _buildDropdownField(
                        label: 'Modalidade Atendimento',
                        items: _modalidades,
                        value: _modalidadeAtendimento,
                        onChanged: (newValue) {
                          setState(() {
                            _modalidadeAtendimento = newValue;
                          });
                        },
                      ),

                      _buildTextField(label: 'SENHA:', isPassword: true),

                      // --- TERMOS E CONDIÇÕES ---
                      Row(
                        children: [
                          Checkbox(
                            value: _termosAceitos,
                            onChanged: (value) =>
                                setState(() => _termosAceitos = value!),
                            activeColor: AppTheme.verde8,
                            checkColor: AppTheme.brancoPrincipal,
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

                      // --- BOTÃO DE ACESSAR ---
                      ElevatedButton(
                        onPressed: _termosAceitos
                            ? () {
                                print(
                                  'Botão Acessar (Profissional) pressionado!',
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.verde8,
                          foregroundColor: AppTheme.brancoPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
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
    );
  }
}
