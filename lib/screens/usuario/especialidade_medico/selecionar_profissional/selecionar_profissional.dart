import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/services/professional_service.dart';
import 'package:plenonexo/services/user_service.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:plenonexo/screens/usuario/especialidade_medico/selecionar_profissional/schedule/schedule_screen.dart';

class SelectProfessionalScreen extends StatefulWidget {
  final String specialty;

  const SelectProfessionalScreen({super.key, required this.specialty});

  @override
  State<SelectProfessionalScreen> createState() =>
      _SelectProfessionalScreenState();
}

class _SelectProfessionalScreenState extends State<SelectProfessionalScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ProfessionalModel>> _professionalsFuture;
  List<ProfessionalModel> _allProfessionals = [];
  List<ProfessionalModel> _filteredProfessionals = [];
  List<ProfessionalModel> _sortedProfessionals = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _professionalsFuture = Future.value([]);
    _initialLoad();
    _searchController.addListener(_filterProfessionals);
  }

  Future<void> _initialLoad() async {
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _professionalsFuture = _professionalService.getProfessionalsBySpecialty(
          widget.specialty,
          city: _currentUser?.city,
        );
      });
    }
  }

  String _getFirstName() {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Olá, Utilizador';
    }
    return 'Olá, ${_currentUser!.name.split(' ').first}';
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
        return prof.name.toLowerCase().contains(query) ||
            prof.especialidades.any((esp) => esp.toLowerCase().contains(query));
      }).toList();
      _sortProfessionalsByMatch();
    });
  }

  void _sortProfessionalsByMatch() {
    if (_currentUser?.neuroDiversity == null ||
        _currentUser!.neuroDiversity!.isEmpty) {
      _sortedProfessionals = List.from(_filteredProfessionals);
      return;
    }

    _sortedProfessionals = List.from(_filteredProfessionals);
    _sortedProfessionals.sort((a, b) {
      final aMatches = _countMatches(
        a.especialidades,
        _currentUser!.neuroDiversity!,
      );
      final bMatches = _countMatches(
        b.especialidades,
        _currentUser!.neuroDiversity!,
      );

      if (aMatches != bMatches) {
        return bMatches.compareTo(aMatches);
      }

      return b.rating.compareTo(a.rating);
    });
  }

  int _countMatches(
    List<String> professionalSpecialties,
    List<String> userNeurodiversities,
  ) {
    int matches = 0;
    for (String userNeuro in userNeurodiversities) {
      if (professionalSpecialties.any(
        (profSpecialty) =>
            profSpecialty.toLowerCase().contains(userNeuro.toLowerCase()) ||
            userNeuro.toLowerCase().contains(profSpecialty.toLowerCase()),
      )) {
        matches++;
      }
    }
    return matches;
  }

  String _formatAddress(String fullAddress) {
    List<String> parts = fullAddress.split(',');
    if (parts.length >= 2) {
      return '${parts[0].trim()}, ${parts[1].trim()}';
    }
    return fullAddress;
  }

  Widget _buildProfessionalCard(ProfessionalModel prof) {
    final matches = _currentUser?.neuroDiversity != null
        ? _countMatches(prof.especialidades, _currentUser!.neuroDiversity!)
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.brancoPrincipal,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pretoPrincipal.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prof.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.pretoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.verde13, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          prof.ratingCount > 0
                              ? prof.rating.toStringAsFixed(1)
                              : 'Novo',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.pretoPrincipal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          prof.ratingCount > 0 ? ' (${prof.ratingCount})' : '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.pretoPrincipal.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (matches > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.verde13.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${matches} match${matches > 1 ? 'es' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.verde13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.azul13.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prof.atuationArea,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.azul13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildInfoRow(Icons.location_on, _formatAddress(prof.officeAddress)),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.phone, prof.phone),

          const SizedBox(height: 12),

          if (prof.especialidades.isNotEmpty) ...[
            Text(
              'Acessibilidade para neurodiversidade:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.pretoPrincipal,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: prof.especialidades.take(3).map((especialidade) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.azul5.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    especialidade,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.azul8,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (prof.especialidades.length > 3)
              Text(
                '+${prof.especialidades.length - 3} mais',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.pretoPrincipal.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor da consulta',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.pretoPrincipal.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'R\$ ${prof.consultationPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.verde13,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduleScreen(professional: prof),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.azul13,
                  foregroundColor: AppTheme.brancoPrincipal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Agendar consulta',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.pretoPrincipal.withOpacity(0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.pretoPrincipal.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppTheme.pretoPrincipal,
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
                          color: AppTheme.pretoPrincipal,
                        ),
                      ),
                      Text(
                        '06/09/2025',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.pretoPrincipal.withOpacity(0.7),
                        ),
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
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.brancoPrincipal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _searchController,
                              style: GoogleFonts.poppins(
                                color: AppTheme.pretoPrincipal,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Pesquisar por nome ou especialidade...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppTheme.pretoPrincipal.withOpacity(
                                    0.5,
                                  ),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.azul13.withOpacity(0.7),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: AppTheme.brancoPrincipal,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: AppTheme.azul13,
                                    width: 2,
                                  ),
                                ),
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
                              // Não podemos chamar setState dentro do builder
                              // Atualizamos as variáveis diretamente
                              _allProfessionals = snapshot.data!;
                              _filteredProfessionals = _allProfessionals;
                              _sortProfessionalsByMatch();

                              // Agendamos um setState para o próximo frame
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) setState(() {});
                              });
                            }

                            // Se a busca por nome estiver vazia, usa a lista ordenada.
                            // Senão, usa a lista filtrada localmente.
                            final displayList = _searchController.text.isEmpty
                                ? _sortedProfessionals
                                : _filteredProfessionals;

                            if (displayList.isEmpty &&
                                snapshot.connectionState ==
                                    ConnectionState.done) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: AppTheme.pretoPrincipal
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum profissional encontrado.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.pretoPrincipal
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _currentUser?.city != null
                                          ? 'Não há profissionais da sua especialidade em "${_currentUser!.city}".'
                                          : 'Verifique a cidade em seu perfil.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppTheme.pretoPrincipal
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final prof = displayList[index];
                                return _buildProfessionalCard(prof);
                              },
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
