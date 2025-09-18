import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/services/professional_service.dart';
import 'package:plenonexo/utils/app_theme.dart';

class SelectProfessionalScreen extends StatefulWidget {
  final String specialty;

  const SelectProfessionalScreen({super.key, required this.specialty});

  @override
  State<SelectProfessionalScreen> createState() =>
      _SelectProfessionalScreenState();
}

class _SelectProfessionalScreenState extends State<SelectProfessionalScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ProfessionalModel>> _professionalsFuture;
  List<ProfessionalModel> _allProfessionals = [];
  List<ProfessionalModel> _filteredProfessionals = [];

  @override
  void initState() {
    super.initState();
    // Iniciamos a busca pelos profissionais
    _professionalsFuture = _professionalService.getProfessionalsBySpecialty(
      widget.specialty,
    );
    // Adicionamos um listener para o campo de pesquisa
    _searchController.addListener(_filterProfessionals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProfessionals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProfessionals = _allProfessionals.where((prof) {
        return prof.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Widget _buildProfessionalCard(ProfessionalModel prof) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.azul10,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prof.name,
            style: AppTheme.tituloPrincipal.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${prof.rating} ${prof.atuationArea}',
                style: AppTheme.corpoTextoBranco.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Endereço: ${prof.officeAddress}',
            style: AppTheme.corpoTextoBranco.copyWith(fontSize: 12),
          ),
          Text(
            prof.phone,
            style: AppTheme.corpoTextoBranco.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: AppTheme.brancoPrincipal.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "Horários Disponíveis", // TODO: Tornar dinâmico
                style: AppTheme.corpoTextoBranco.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Text(
                'R\$ ${prof.price.toStringAsFixed(2)}',
                style: AppTheme.tituloPrincipal.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navegar para a tela de agendamento de horário
              },
              child: Text(
                'Agendar consulta',
                style: AppTheme.textoBotaoBranco.copyWith(
                  color: AppTheme.azul1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: Column(
          children: [
            // --- CABEÇALHO ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 50),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, Utilizador',
                        style: AppTheme.tituloPrincipalPreto.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '06/09/2025',
                        style: TextStyle(color: AppTheme.pretoPrincipal),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.azul13.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.brancoPrincipal,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTEÚDO PRINCIPAL ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.azul12,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    children: [
                      // --- TÍTULO E PESQUISA ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: AppTheme.brancoPrincipal,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              title: Text(
                                'Selecionar Profissional',
                                style: AppTheme.tituloPrincipal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _searchController,
                              style: TextStyle(color: AppTheme.pretoPrincipal),
                              decoration: InputDecoration(
                                hintText: 'Pesquisar por nome...',
                                hintStyle: TextStyle(
                                  color: AppTheme.pretoPrincipal.withOpacity(
                                    0.5,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.pretoPrincipal.withOpacity(
                                    0.7,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppTheme.brancoPrincipal,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- LISTA DINÂMICA DE PROFISSIONAIS ---
                      Expanded(
                        child: FutureBuilder<List<ProfessionalModel>>(
                          future: _professionalsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Erro ao carregar profissionais',
                                  style: AppTheme.corpoTextoBranco,
                                ),
                              );
                            }

                            // A primeira vez que os dados chegam, guardamos na lista completa
                            if (_allProfessionals.isEmpty && snapshot.hasData) {
                              _allProfessionals = snapshot.data!;
                              _filteredProfessionals = _allProfessionals;
                            }

                            if (_filteredProfessionals.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhum profissional encontrado.',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.corpoTextoBranco,
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: _filteredProfessionals.length,
                              itemBuilder: (context, index) {
                                final prof = _filteredProfessionals[index];
                                // TODO: Lógica para agrupar por data (mais complexa)
                                return _buildProfessionalCard(prof);
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      // TODO: Adicionar a mesma BottomNavigationBar das outras telas
    );
  }
}
