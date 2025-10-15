import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:plenonexo/screens/usuario/especialidade_medico/especialidade_medico.dart';
import 'package:plenonexo/screens/usuario/rating/professional_rating_screen.dart';
import 'package:plenonexo/screens/usuario/options/options_screen.dart';
import 'package:plenonexo/services/user_service.dart';
import 'package:plenonexo/services/appointment_service.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final UserService _userService = UserService();
  final AppointmentService _appointmentService = AppointmentService();
  UserModel? _currentUser;
  bool _isLoading = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedIndex = 0;

  // Variáveis para o calendário
  Map<DateTime, List<AppointmentModel>> _appointmentsMap = {};
  List<AppointmentModel> _selectedDayAppointments = [];
  DateTime? _nextAppointmentDate;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });

      // Carrega os agendamentos após carregar os dados do usuário
      if (user != null) {
        _loadAppointments();
      }
    }
  }

  Future<void> _loadAppointments() async {
    if (_currentUser == null) return;

    final appointments = await _appointmentService
        .getPatientAppointmentsByMonth(_currentUser!.uid, _focusedDay);

    // Encontra a data da próxima consulta
    _findNextAppointmentDate();

    if (mounted) {
      setState(() {
        _appointmentsMap = _groupAppointmentsByDate(appointments);
        _selectedDayAppointments = _getAppointmentsForDay(_selectedDay!);
      });
    }
  }

  Future<void> _findNextAppointmentDate() async {
    if (_currentUser == null) return;

    final allAppointments = await _appointmentService.getPatientAppointments(
      _currentUser!.uid,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    allAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final futureAppointments = allAppointments.where(
      (appt) => !appt.dateTime.isBefore(today),
    );

    if (futureAppointments.isNotEmpty) {
      final date = futureAppointments.first.dateTime;
      _nextAppointmentDate = DateTime(date.year, date.month, date.day);
    }
  }

  Map<DateTime, List<AppointmentModel>> _groupAppointmentsByDate(
    List<AppointmentModel> appointments,
  ) {
    Map<DateTime, List<AppointmentModel>> grouped = {};

    for (AppointmentModel appointment in appointments) {
      final date = DateTime(
        appointment.dateTime.year,
        appointment.dateTime.month,
        appointment.dateTime.day,
      );

      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(appointment);
    }

    return grouped;
  }

  List<AppointmentModel> _getAppointmentsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _appointmentsMap[date] ?? [];
  }

  bool _hasAppointmentOnDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _appointmentsMap.containsKey(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppTheme.azul9;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      default:
        return AppTheme.azul9;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendada';
      case 'confirmed':
        return 'Confirmada';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Concluída';
      default:
        return 'Agendada';
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                            'assets/img/logoPlenoNexo.svg',
                            height: 50,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                onTap: () {
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
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/iconeDente.svg',
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.brancoPrincipal,
                                    BlendMode.srcIn,
                                  ),
                                  height: 45,
                                ),
                                label: 'Marcar\nDentista',
                                onTap: () {
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
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/iconeMedalha.svg',
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.brancoPrincipal,
                                    BlendMode.srcIn,
                                  ),
                                  height: 45,
                                ),
                                label: 'Avaliar\nConsultas',
                                onTap: () {
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
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.azul12,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Data da Próxima Consulta',
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
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: CalendarFormat.month,
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                    _selectedDayAppointments =
                                        _getAppointmentsForDay(selectedDay);
                                  });
                                },
                                onPageChanged: (focusedDay) {
                                  setState(() {
                                    _focusedDay = focusedDay;
                                  });
                                  _loadAppointments(); // Recarrega os agendamentos do novo mês
                                },
                                eventLoader: (day) {
                                  return _getAppointmentsForDay(day);
                                },
                                headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: AppTheme.tituloPrincipal
                                      .copyWith(
                                        fontSize: 16,
                                        color: AppTheme.pretoPrincipal,
                                      ),
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
                                  markersMaxCount: 1,
                                  markerDecoration: BoxDecoration(
                                    color: AppTheme.vermelho1,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, day, events) {
                                    if (events.isNotEmpty) {
                                      return Positioned(
                                        bottom: 1,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: AppTheme.vermelho1,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                  outsideBuilder: (context, day, focusedDay) {
                                    final isToday = isSameDay(
                                      day,
                                      DateTime.now(),
                                    );
                                    final hasAppointment = _hasAppointmentOnDay(
                                      day,
                                    );
                                    final isNextAppointment = isSameDay(
                                      day,
                                      _nextAppointmentDate,
                                    );

                                    return Container(
                                      margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? AppTheme.azul5.withOpacity(0.3)
                                            : hasAppointment
                                            ? AppTheme.vermelho1.withOpacity(
                                                0.3,
                                              )
                                            : null,
                                        border: isNextAppointment
                                            ? Border.all(
                                                color: AppTheme.primaryGreen,
                                                width: 2,
                                              )
                                            : null,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: isToday
                                                ? AppTheme.azul9
                                                : hasAppointment
                                                ? AppTheme.vermelho1
                                                : null,
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  defaultBuilder: (context, day, focusedDay) {
                                    final isToday = isSameDay(
                                      day,
                                      DateTime.now(),
                                    );
                                    final hasAppointment = _hasAppointmentOnDay(
                                      day,
                                    );
                                    final isNextAppointment = isSameDay(
                                      day,
                                      _nextAppointmentDate,
                                    );

                                    return Container(
                                      margin: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? AppTheme.azul5.withOpacity(0.3)
                                            : hasAppointment
                                            ? AppTheme.vermelho1.withOpacity(
                                                0.3,
                                              )
                                            : null,
                                        border: isNextAppointment
                                            ? Border.all(
                                                color: AppTheme.primaryGreen,
                                                width: 2,
                                              )
                                            : null,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: isToday
                                                ? AppTheme.azul9
                                                : hasAppointment
                                                ? AppTheme.vermelho1
                                                : null,
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Seção de consultas do dia selecionado
                            if (_selectedDayAppointments.isNotEmpty) ...[
                              Text(
                                'Consultas do dia ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
                                style: AppTheme.tituloPrincipalBrancoNegrito
                                    .copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              ...(_selectedDayAppointments
                                  .map(
                                    (appointment) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.brancoPrincipal
                                            .withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppTheme.azul9.withOpacity(
                                            0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: AppTheme.azul9,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat(
                                                  'HH:mm',
                                                ).format(appointment.dateTime),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.azul9,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    appointment.status,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _getStatusText(
                                                    appointment.status,
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            appointment.subject,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.pretoPrincipal,
                                            ),
                                          ),
                                          if (appointment.consultationPrice >
                                              0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Valor: R\$ ${appointment.consultationPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: AppTheme.pretoPrincipal
                                                    .withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList()),
                            ] else ...[
                              Text(
                                'Nenhuma consulta agendada para ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
                                style: AppTheme.corpoTextoBranco.copyWith(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
        // MUDANÇA: Lógica de navegação para todos os itens
        onTap: (index) {
          switch (index) {
            case 0:
              // Já estamos na Home, então só atualizamos o índice para o feedback visual
              setState(() {
                _selectedIndex = index;
              });
              break;
            case 1: // Avaliações
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessionalRatingScreen(),
                ), // MUDANÇA: Navega para a tela de avaliações
              );
              break;
            case 2: // Perfil
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
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Avaliações',
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
