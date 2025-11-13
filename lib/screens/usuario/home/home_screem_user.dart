import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/screens/usuario/especialidade_medico/especialidade_medico.dart';
import 'package:plenonexo/screens/usuario/profile/profile_edit_screen.dart';
import 'package:plenonexo/screens/usuario/options/options_screen.dart';
import 'package:plenonexo/screens/usuario/rating/professional_rating_screen.dart';
import 'package:plenonexo/services/appointment_service.dart';
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

  UserModel? _currentUser;
  late Stream<List<AppointmentModel>> _appointmentsStream;
  bool _isLoading = true;

  DateTime _focusedDay = DateTime.now().toUtc();
  DateTime? _selectedDay;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = await _authService.getCurrentUserModel();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
      if (user != null) {
        _appointmentsStream = _appointmentService.getPatientAppointmentsStream(user.uid);
      }
    }
  }

  String get _firstName {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    return _currentUser!.name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

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
                      _buildHeader(formattedDate),
                      const SizedBox(height: 24),
                      _buildQuickAccess(),
                      const SizedBox(height: 24),
                      _buildAppointmentsSection(),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(String formattedDate) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/img/NeuroConecta.svg',
          height: 60,
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
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
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

  Widget _buildAppointmentsSection() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _appointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erro: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Ainda mostra o calendário, mas com uma mensagem de "sem consultas"
          return _buildEmptyAppointmentsCalendar();
        }

        final allAppointments = snapshot.data!;
        // Mostrar também as consultas canceladas para que o usuário veja o histórico
        final appointmentsToShow = List<AppointmentModel>.from(allAppointments)
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return Container(
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
                style: AppTheme.tituloPrincipalBrancoNegrito.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.brancoPrincipal,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TableCalendar<AppointmentModel>(
                  locale: 'pt_BR',
                  firstDay: DateTime.utc(DateTime.now().year - 1),
                  lastDay: DateTime.utc(DateTime.now().year + 1),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  rowHeight: 42,
                  eventLoader: (day) {
                    // Incluir todas as consultas (inclusive canceladas) como marcadores
                    return appointmentsToShow.where((app) {
                      return isSameDay(app.dateTime, day);
                    }).toList();
                  },
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                    titleTextStyle: AppTheme.tituloPrincipal.copyWith(fontSize: 16),
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
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSelectedDayAppointments(appointmentsToShow),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyAppointmentsCalendar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.azul12,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Text(
            'Minhas Consultas',
            style: AppTheme.tituloPrincipalBrancoNegrito.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.brancoPrincipal,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(DateTime.now().year - 1),
              lastDay: DateTime.utc(DateTime.now().year + 1),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              rowHeight: 42,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: AppTheme.tituloPrincipal.copyWith(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Nenhuma consulta agendada.',
              style: AppTheme.corpoTextoBranco.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayAppointments(List<AppointmentModel> appointments) {
    if (_selectedDay == null) return const SizedBox.shrink();

    final selectedAppointments = appointments.where((app) {
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
        final now = DateTime.now();
        final canCancel = app.dateTime.isAfter(now.add(const Duration(hours: 24)));
        final status = _getStatusText(app);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.azul9.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.watch_later_outlined,
                    color: AppTheme.brancoPrincipal,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${DateFormat('HH:mm').format(app.dateTime.toLocal())} - ${app.professionalName ?? 'Profissional'}',
                      style: AppTheme.corpoTextoBranco.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canCancel && app.status == 'scheduled')
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                      onPressed: () => _showCancelDialog(app),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Status: $status',
                style: AppTheme.corpoTextoBranco.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (app.status == 'cancelled' && app.cancellationReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Motivo: ${app.cancellationReason}',
                    style: AppTheme.corpoTextoBranco.copyWith(
                      fontSize: 12,
                      color: Colors.red[100],
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getStatusText(AppointmentModel appointment) {
    final now = DateTime.now();
    if (appointment.status == 'scheduled') {
      if (appointment.dateTime.isBefore(now)) {
        return 'Perdida';
      } else {
        return 'Agendada';
      }
    }
    switch (appointment.status) {
      case 'completed':
        return 'Realizada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return appointment.status;
    }
  }

  void _showCancelDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Consulta'),
          content: const Text('Tem certeza que deseja cancelar esta consulta?'),
          actions: [
            TextButton(
              child: const Text('Voltar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                _cancelAppointment(appointment.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(appointmentId, 'Cancelado pelo paciente');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consulta cancelada com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar a consulta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  BottomNavigationBar _buildBottomNavigation() {
    return BottomNavigationBar(
      unselectedItemColor: AppTheme.pretoPrincipal.withOpacity(0.6),
      selectedItemColor: AppTheme.azul9,
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (_selectedIndex == index) return;

        switch (index) {
          case 0:
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
                builder: (context) => const OptionsScreen(),
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
    );
  }
}