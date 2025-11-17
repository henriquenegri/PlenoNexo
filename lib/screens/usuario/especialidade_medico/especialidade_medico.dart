import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:AURA/models/user_model.dart';
import 'package:AURA/screens/usuario/especialidade_medico/selecionar_profissional/selecionar_profissional.dart';
import 'package:AURA/screens/usuario/home/home_screem_user.dart';
import 'package:AURA/screens/usuario/options/options_screen.dart';
import 'package:AURA/services/professional_service.dart';
import 'package:AURA/services/user_service.dart';
import 'package:AURA/utils/app_theme.dart';

class SelectSpecialtyScreen extends StatefulWidget {
  const SelectSpecialtyScreen({super.key});

  @override
  State<SelectSpecialtyScreen> createState() => _SelectSpecialtyScreenState();
}

class _SelectSpecialtyScreenState extends State<SelectSpecialtyScreen> {
  final int _selectedIndex = 1;
  final UserService _userService = UserService();
  final ProfessionalService _professionalService = ProfessionalService();
  final Map<String, List<String>> _groupedSpecialties = {};
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
    _groupSpecialties();
  }

  String get _userName {
    return _currentUser?.name.split(' ').first ?? 'Utilizador';
  }

  void _groupSpecialties() {
    final specialties = _professionalService.getAtuationAreas();
    specialties.sort();

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
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectProfessionalScreen(specialty: title),
          ),
        );

        // Se um agendamento foi criado com sucesso, recarregar a tela principal
        if (result == true) {
          // Navegar de volta para a tela principal para mostrar o novo agendamento
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
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
          color: AppTheme.brancoPrincipal.withAlpha((255 * 0.3).round()),
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
                  Image.asset('assets/img/PlenoNexo.png', height: 60),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $_userName',
                        style: AppTheme.tituloPrincipalPreto.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        style: TextStyle(color: AppTheme.pretoPrincipal),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox.shrink(),
                ],
              ),
            ),

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
                        title: Text(
                          'Selecionar Especialidade',
                          style: AppTheme.tituloPrincipal,
                        ),
                      ),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          unselectedItemColor: AppTheme.pretoPrincipal.withAlpha(
            (255 * 0.6).round(),
          ),
          selectedItemColor: AppTheme.azul9,
          currentIndex: _selectedIndex,
          onTap: (index) {
          switch (index) {
            case 0: // Início
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const UserHomeScreen()),
                (Route<dynamic> route) => false,
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptionsScreen()),
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
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Consultas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        ),
      ),
    );
  }
}
