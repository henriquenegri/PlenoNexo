import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/screens/usuario/especialidade_medico/especialidade_medico.dart';
import 'package:plenonexo/screens/usuario/profile/profile_edit_screen.dart';
import 'package:plenonexo/screens/usuario/profile/profile_menu_screen.dart';
import 'package:plenonexo/screens/usuario/rating/professional_rating_screen.dart';
import 'package:plenonexo/services/appointment_service.dart';
import 'package:plenonexo/services/professional_service.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  final ProfessionalService _professionalService = ProfessionalService();

  UserModel? _currentUser;
  bool _isLoading = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedIndex = 0;
  List<AppointmentModel> _appointments = [];
  Map<String, String> _professionalNames = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar dados quando a tela for exibida novamente
    if (_currentUser != null) {
      _loadAppointments(_currentUser!.uid);
    }
  }

  // Método para recarregar agendamentos quando necessário
  Future<void> refreshAppointments() async {
    if (_currentUser != null) {
      await _loadAppointments(_currentUser!.uid);
    }
  }

  Future<void> _loadInitialData() async {
    final user = await _authService.getCurrentUserModel();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
      if (user != null) {
        await _loadAppointments(user.uid);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments(String userId) async {
    try {
      final fetchedAppointments = await _appointmentService
          .getPatientAppointments(userId);

      debugPrint(
        'Total de agendamentos carregados: ${fetchedAppointments.length}',
      );

      // Filtrar apenas consultas não canceladas (incluindo consultas de hoje e futuras)
      final activeAppointments = fetchedAppointments
          .where((app) => app.status.toLowerCase() != 'cancelled')
          .toList();

      debugPrint('Agendamentos ativos: ${activeAppointments.length}');

      activeAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      // Carregar nomes dos profissionais
      for (var app in activeAppointments) {
        if (!_professionalNames.containsKey(app.professionalId)) {
          final prof = await _professionalService.getProfessionalById(
            app.professionalId,
          );
          if (prof != null) {
            _professionalNames[prof.uid] = prof.name;
          }
        }
      }

      if (mounted) {
        setState(() {
          _appointments = activeAppointments;
          if (_appointments.isNotEmpty) {
            _selectedDay = _appointments.first.dateTime;
            _focusedDay = _appointments.first.dateTime;
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar agendamentos: $e');
      if (mounted) {
        setState(() {
          _appointments = [];
        });
      }
    }
  }

  String get _firstName {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    return _currentUser!.name.split(' ').first;
  }

  Widget _buildQuickAccessButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 125,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.azul9,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.corpoTextoBranco.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/img/NeuroConecta.svg',
                            height: 60,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // MUDANÇA: Usamos o nosso novo getter para o primeiro nome.
                              Text(
                                'Olá, $_firstName',
                                style: AppTheme.tituloPrincipalPreto.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: AppTheme.pretoPrincipal,
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
                      const SizedBox(height: 24),

                      Text(
                        'Acesso Rápido',
                        style: AppTheme.tituloPrincipalNegrito.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: AppTheme.azul12,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickAccessButton(
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/iconePessoaCaderno.svg',
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.brancoPrincipal,
                                    BlendMode.srcIn,
                                  ),
                                  height: 45,
                                ),
                                label: 'Marcar\nConsulta',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectSpecialtyScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAccessButton(
                                iconWidget: Icon(
                                  Icons.person_search_outlined,
                                  color: AppTheme.brancoPrincipal,
                                  size: 45,
                                ),
                                label: 'Editar\nPerfil',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileEditScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAccessButton(
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/iconeMedalha.svg',
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.brancoPrincipal,
                                    BlendMode.srcIn,
                                  ),
                                  height: 45,
                                ),
                                label: 'Avaliar\nConsultas',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfessionalRatingScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        // Este container agora tem um filho Column
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.azul12,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Minhas Consultas',
                              style: AppTheme.tituloPrincipalBrancoNegrito
                                  .copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.brancoPrincipal,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TableCalendar<AppointmentModel>(
                                locale: 'pt_BR',
                                firstDay: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDay: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                                focusedDay: _focusedDay,
                                calendarFormat: CalendarFormat.month,
                                eventLoader: (day) {
                                  return _appointments.where((app) {
                                    return isSameDay(app.dateTime, day);
                                  }).toList();
                                },
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  if (!isSameDay(_selectedDay, selectedDay)) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  }
                                },
                                headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: AppTheme.tituloPrincipal
                                      .copyWith(fontSize: 16),
                                ),
                                calendarStyle: CalendarStyle(
                                  selectedDecoration: BoxDecoration(
                                    color: AppTheme.azul9,
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: AppTheme.azul5,
                                    shape: BoxShape.circle,
                                  ),
                                  markerDecoration: BoxDecoration(
                                    color: AppTheme.vermelho1,
                                    shape: BoxShape.circle,
                                  ),
                                  markersMaxCount: 1,
                                  markerSize: 6,
                                  markerMargin: const EdgeInsets.symmetric(
                                    horizontal: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSelectedDayAppointments(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: AppTheme.pretoPrincipal.withOpacity(0.6),
        selectedItemColor: AppTheme.azul9,
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Não atualiza o estado se já estiver na tela selecionada
          if (_selectedIndex == index) return;

          switch (index) {
            case 0:
              // Já estamos na Home, não faz nada.
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessionalRatingScreen(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileMenuScreen(),
                ),
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

  Widget _buildSelectedDayAppointments() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final selectedAppointments = _appointments.where((app) {
      return isSameDay(app.dateTime, _selectedDay);
    }).toList();

    if (selectedAppointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Nenhuma consulta para este dia.',
          style: AppTheme.corpoTextoBranco.copyWith(color: Colors.white),
        ),
      );
    }

    return Column(
      children: selectedAppointments.map((app) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.azul9.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.watch_later_outlined,
                color: AppTheme.brancoPrincipal,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${DateFormat('HH:mm').format(app.dateTime)} - ${_professionalNames[app.professionalId] ?? 'Profissional'}',
                  style: AppTheme.corpoTextoBranco.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
