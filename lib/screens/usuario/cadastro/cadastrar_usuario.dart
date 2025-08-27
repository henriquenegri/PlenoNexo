import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/utils/app_theme.dart';

// Como precisamos guardar o que o utilizador seleciona (radio, checkbox),
// esta tela precisa ser um StatefulWidget.
class CadastrarUsuario extends StatefulWidget {
  const CadastrarUsuario({super.key});

  @override
  State<CadastrarUsuario> createState() => _CadastrarUsuario();
}

class _CadastrarUsuario extends State<CadastrarUsuario> {
  // Variáveis para guardar o estado dos nossos widgets
  String?
  _paraQuemERegistro; // Armazena a opção do radio button "Para quem é o registro?"
  final Set<String> _neuroDiversidade =
      {}; // Armazena a opção do radio button "Neuro Diversidade?"
  bool _termosAceitos = false; // Armazena o estado do checkbox
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

  // Função auxiliar para criar os campos de texto e evitar repetição
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 100),
                const SizedBox(height: 8),
                Text('PlenoNexo', style: AppTheme.tituloPrincipal),
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

                      // --- NOVOS CAMPOS ADICIONADOS ---
                      _buildTextField(label: 'Nome Completo:'),
                      _buildTextField(
                        label: 'E-mail:',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // Linha para Estado e Cidade
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna para Estado (Dropdown)
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
                                  items: _estadosBrasileiros.map((
                                    String estado,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: estado,
                                      child: Text(estado),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _estadoSelecionado = newValue;
                                    });
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
                          // Coluna para Cidade (Campo de texto)
                          Expanded(child: _buildTextField(label: 'Cidade:')),
                        ],
                      ),

                      _buildTextField(
                        label: 'Data Nascimento:',
                        keyboardType: TextInputType.datetime,
                      ),
                      _buildTextField(
                        label: 'Informe o CPF:',
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        label: 'Telefone:',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        label: 'Crie sua Senha:',
                        isPassword: true,
                      ),

                      // --- SELEÇÃO "PARA QUEM É O REGISTRO?" ---
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

                      // --- SELEÇÃO "NEURO DIVERSIDADE?" ---
                      Text(
                        'Possui Alguma Neuro Diversidade?',
                        style: AppTheme.corpoTextoBranco,
                      ),
                      const SizedBox(height: 8),
                      // MUDANÇA 2: Usamos FilterChip para seleção múltipla
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
                                  'Nenhum',
                                  'TDAH',
                                  'Transtorno Bipolar',
                                  'TPS',
                                  'Ansiedade',
                                  'Depressão',
                                ]
                                .map(
                                  (label) => FilterChip(
                                    label: Text(label),
                                    // O chip está selecionado se o seu 'label' estiver na nossa lista de selecionados
                                    selected: _neuroDiversidade.contains(label),
                                    onSelected: (isSelected) {
                                      setState(() {
                                        if (isSelected) {
                                          _neuroDiversidade.add(label);
                                        } else {
                                          _neuroDiversidade.remove(label);
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

                      // --- TERMOS E CONDIÇÕES ---
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

                      // --- BOTÃO DE ACESSAR ---
                      ElevatedButton(
                        onPressed: _termosAceitos
                            ? () {
                                print('Botão Acessar pressionado!');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.azul9,
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
