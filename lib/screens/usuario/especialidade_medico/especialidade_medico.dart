import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/screens/usuario/especialidade_medico/selecionar_profissional/selecionar_profissional.dart';
import 'package:plenonexo/screens/usuario/home/home_screem_user.dart';
import 'package:plenonexo/services/professional_service.dart';
import 'package:plenonexo/utils/app_theme.dart';

class SelectSpecialtyScreen extends StatefulWidget {
  const SelectSpecialtyScreen({super.key});

  @override
  State<SelectSpecialtyScreen> createState() => _SelectSpecialtyScreenState();
}

class _SelectSpecialtyScreenState extends State<SelectSpecialtyScreen> {
  int _selectedIndex = 1; // Começa com o índice 1 (Consultas) selecionado
  final ProfessionalService _professionalService = ProfessionalService();
  Map<String, List<String>> _groupedSpecialties = {};

  @override
  void initState() {
    super.initState();
    _groupSpecialties();
  }

  void _groupSpecialties() {
    final specialties = _professionalService.getAtuationAreas();
    specialties.sort(); // Ordena alfabeticamente

    _groupedSpecialties.clear();

    for (String specialty in specialties) {
      String firstLetter = specialty[0].toUpperCase();
      if (!_groupedSpecialties.containsKey(firstLetter)) {
        _groupedSpecialties[firstLetter] = [];
      }
      _groupedSpecialties[firstLetter]!.add(specialty);
    }
  }

  Widget _buildSpecialtyItem(BuildContext context, String title) {
    return ListTile(
      leading: Text(
        '•',
        style: TextStyle(color: AppTheme.brancoPrincipal, fontSize: 24),
      ),
      title: Text(title, style: AppTheme.corpoTextoBranco),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectProfessionalScreen(specialty: title),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: AppTheme.tituloPrincipal.copyWith(fontSize: 18),
          ),
        ),
        Divider(
          color: AppTheme.brancoPrincipal.withOpacity(0.3),
          thickness: 1,
          indent: 16,
          endIndent: 16,
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
            // --- CABEÇALHO (similar ao da HomeScreen) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 50),
                  const SizedBox(width: 12),
                  // TODO: Tornar este cabeçalho dinâmico com os dados do utilizador
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
                        '03/09/2025',
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

            // --- LISTA DE ESPECIALIDADES ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.azul12,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListView(
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
                          'Selecionar Especialidade',
                          style: AppTheme.tituloPrincipal,
                        ),
                      ),
                      // Gera dinamicamente as especialidades organizadas por letra
                      ...(_groupedSpecialties.keys.toList()..sort()).map((
                        letter,
                      ) {
                        return Column(
                          children: [
                            _buildHeader(letter),
                            ...(_groupedSpecialties[letter] ?? []).map(
                              (specialty) =>
                                  _buildSpecialtyItem(context, specialty),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: AppTheme.pretoPrincipal.withOpacity(0.6),
        selectedItemColor: AppTheme.azul9,
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Lógica de navegação para esta tela
          switch (index) {
            case 0: // Início
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const UserHomeScreen()),
                (Route<dynamic> route) => false,
              );
              break;
            case 1:
              // Já estamos aqui, não faz nada
              break;
            case 2: // Perfil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserHomeScreen()),
              );
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/iconeBatimentoCardiaco.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                AppTheme.pretoPrincipal.withOpacity(0.6),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/iconeBatimentoCardiaco.svg',
              height: 24,
              colorFilter: ColorFilter.mode(AppTheme.azul9, BlendMode.srcIn),
            ),
            label: 'Consultas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
