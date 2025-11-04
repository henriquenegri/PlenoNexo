import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/screens/usuario/home/home_screem_user.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/screens/usuario/options/options_screen.dart';
import 'package:plenonexo/services/appointment_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:plenonexo/services/user_service.dart';

class ScheduleScreen extends StatefulWidget {
  final ProfessionalModel professional;

  const ScheduleScreen({super.key, required this.professional});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final UserService _userService = UserService();

  UserModel? _currentUser;
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;
  bool _isLoadingSlots = false;
  bool _isScheduling = false;

  // Gerar horários dinamicamente baseado na disponibilidade do profissional
  List<String> _generateTimeSlots() {
    final List<String> slots = [];

    // Horários da manhã (8:00 - 12:00)
    for (int hour = 8; hour < 12; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }

    // Horários da tarde (14:00 - 19:00)
    for (int hour = 14; hour < 19; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }

    return slots;
  }

  List<String> _unavailableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadUnavailableSlots(DateTime date) async {
    if (mounted) {
      setState(() {
        _isLoadingSlots = true;
        _unavailableSlots = [];
        _selectedTimeSlot = null;
      });
    }

    try {
      final appointments = await _appointmentService
          .getProfessionalAppointmentsByDate(widget.professional.uid, date);

      // Filtrar apenas consultas não canceladas
      final activeAppointments = appointments
          .where(
            (appointment) => appointment.status.toLowerCase() != 'cancelled',
          )
          .toList();

      final unavailable = activeAppointments.map((appointment) {
        final hour = appointment.dateTime.hour.toString().padLeft(2, '0');
        final minute = appointment.dateTime.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }).toList();

      if (mounted) {
        setState(() {
          _unavailableSlots = unavailable;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar horários indisponíveis: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  String _getFirstName() {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    return _currentUser!.name.split(' ').first;
  }

  bool _isSlotAvailable(String timeSlot) {
    return !_unavailableSlots.contains(timeSlot);
  }

  Color _getSlotColor(String timeSlot) {
    if (!_isSlotAvailable(timeSlot)) {
      return const Color(0xFFC54B4B); // Red for unavailable
    }
    if (_selectedTimeSlot == timeSlot) {
      return const Color(0xFF5E8D6B);
    }
    return const Color(0xFF3B748F);
  }

  /// VALIDAÇÃO 1: Verifica se o horário ainda está disponível com este profissional
  Future<bool> _validateProfessionalAvailability(
    DateTime appointmentDateTime,
  ) async {
    try {
      final appointments = await _appointmentService
          .getProfessionalAppointmentsByDate(
            widget.professional.uid,
            appointmentDateTime,
          );

      // Filtrar apenas consultas não canceladas
      final activeAppointments = appointments
          .where(
            (appointment) => appointment.status.toLowerCase() != 'cancelled',
          )
          .toList();

      // Verifica se já existe um agendamento no mesmo horário com este profissional
      final hasConflict = activeAppointments.any(
        (appointment) =>
            appointment.dateTime.hour == appointmentDateTime.hour &&
            appointment.dateTime.minute == appointmentDateTime.minute,
      );

      if (hasConflict) {
        debugPrint(
          'Conflito: Profissional já tem consulta em ${DateFormat('dd/MM/yyyy HH:mm').format(appointmentDateTime)}',
        );
      }

      return !hasConflict;
    } catch (e) {
      debugPrint('Erro ao validar disponibilidade do profissional: $e');
      return false;
    }
  }

  /// VALIDAÇÃO 2: Verifica se o usuário já tem QUALQUER consulta neste dia/horário
  /// (independente do profissional)
  Future<bool> _checkUserHasConflictingAppointment(
    DateTime appointmentDateTime,
  ) async {
    try {
      if (_currentUser == null) {
        debugPrint('Erro: Usuário não identificado');
        return true; // Bloqueia se não conseguir identificar o usuário
      }

      // Busca TODOS os agendamentos do usuário
      final userAppointments = await _appointmentService.getPatientAppointments(
        _currentUser!.uid,
      );

      // Filtrar apenas consultas não canceladas
      final activeAppointments = userAppointments
          .where(
            (appointment) => appointment.status.toLowerCase() != 'cancelled',
          )
          .toList();

      // Verifica se há conflito no MESMO DIA E HORÁRIO
      final hasConflict = activeAppointments.any((appointment) {
        // Verifica se é no mesmo dia e horário
        return appointment.dateTime.year == appointmentDateTime.year &&
            appointment.dateTime.month == appointmentDateTime.month &&
            appointment.dateTime.day == appointmentDateTime.day &&
            appointment.dateTime.hour == appointmentDateTime.hour &&
            appointment.dateTime.minute == appointmentDateTime.minute;
      });

      if (hasConflict) {
        debugPrint(
          'CONFLITO DETECTADO: Usuário já tem consulta agendada em ${DateFormat('dd/MM/yyyy HH:mm').format(appointmentDateTime)}',
        );
        return true; // Tem conflito
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao verificar conflitos do usuário: $e');
      return false;
    }
  }

  Future<void> _scheduleAppointment() async {
    if (_selectedTimeSlot == null || _selectedDate == null) {
      _showErrorSnackBar('Por favor, selecione um horário');
      return;
    }

    if (_currentUser == null) {
      _showErrorSnackBar('Erro: Usuário não identificado');
      return;
    }

    if (mounted) {
      setState(() => _isScheduling = true);
    }

    try {
      // Criar o DateTime do agendamento
      final timeParts = _selectedTimeSlot!.split(':');
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      debugPrint('=== INICIANDO VALIDAÇÕES DE AGENDAMENTO ===');
      debugPrint('Usuário: ${_currentUser!.name} (${_currentUser!.uid})');
      debugPrint('Profissional: ${widget.professional.name}');
      debugPrint(
        'Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(appointmentDateTime)}',
      );

      // VALIDAÇÃO 1: Verificar se o horário ainda está disponível com o profissional
      debugPrint('Validando disponibilidade do profissional...');
      final isProfessionalAvailable = await _validateProfessionalAvailability(
        appointmentDateTime,
      );

      if (!isProfessionalAvailable) {
        if (mounted) {
          _showErrorSnackBar(
            'Este horário já está ocupado com este profissional. Por favor, selecione outro horário.',
          );
          // Recarregar os horários disponíveis
          await _loadUnavailableSlots(_selectedDate!);
        }
        return;
      }
      debugPrint('✓ Profissional disponível');

      // VALIDAÇÃO 2: Verificar se o usuário já tem consulta neste horário
      debugPrint('Verificando conflitos de horário do usuário...');
      final userHasConflict = await _checkUserHasConflictingAppointment(
        appointmentDateTime,
      );

      if (userHasConflict) {
        if (mounted) {
          _showErrorSnackBar(
            'Você já possui uma consulta agendada neste horário. Não é possível marcar duas consultas ao mesmo tempo.',
          );
        }
        return;
      }
      debugPrint('✓ Sem conflitos para o usuário');

      debugPrint('Criando agendamento...');
      // Criar o agendamento
      await _appointmentService.createAppointment(
        patientId: _currentUser!.uid,
        professionalId: widget.professional.uid,
        dateTime: appointmentDateTime,
        consultationPrice: widget.professional.consultationPrice,
        subject: 'Consulta com ${widget.professional.name}',
      );

      debugPrint('✓ Agendamento criado com sucesso!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consulta agendada com sucesso!'),
            backgroundColor: Color(0xFF5E8D6B),
            duration: Duration(seconds: 3),
          ),
        );
        // Retorna true para indicar sucesso e recarregar a tela principal
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('ERRO ao agendar: $e');

      if (mounted) {
        // Tratamento de erro específico
        String errorMessage = 'Erro ao agendar consulta';

        final errorString = e.toString().toLowerCase();

        if (errorString.contains('already exists') ||
            errorString.contains('já existe') ||
            errorString.contains('duplicate') ||
            errorString.contains('conflict')) {
          errorMessage =
              'Este horário já está ocupado. Por favor, selecione outro.';
          // Recarregar os horários disponíveis
          await _loadUnavailableSlots(_selectedDate!);
        } else {
          errorMessage = 'Erro ao agendar consulta: ${e.toString()}';
        }

        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isScheduling = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFC54B4B),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2A475E),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset('assets/img/PlenoNexo.png', height: 60),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFirstName(),
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A475E),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color.fromARGB(
                            (0.7 * 255).round(),
                            42,
                            71,
                            94,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF2A475E,
                      ).withAlpha((0.9 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('1. Selecione a Data'),
                              _buildCalendar(),
                              const SizedBox(height: 24),
                              Text(
                                'Profissional: ${widget.professional.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_selectedDate != null) ...[
                                _buildSectionTitle('2. Selecione o Horário'),
                                _buildTimeSlotsGrid(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isScheduling
                                  ? null
                                  : () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC54B4B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _isScheduling || _selectedTimeSlot == null
                                  ? null
                                  : _scheduleAppointment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B748F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                              child: _isScheduling
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Agendar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: const Color(
          0xFF2A475E,
        ).withAlpha((0.6 * 255).round()),
        selectedItemColor: const Color(0xFF2A475E),
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const UserHomeScreen()),
                (route) => false,
              );
              break;
            case 1:
              // Already on schedule screen
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptionsScreen()),
              );
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        locale: 'pt_BR',
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDate, selectedDay)) {
            if (mounted) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            }
            _loadUnavailableSlots(selectedDay);
          }
        },
        enabledDayPredicate: (day) {
          final weekday = day.weekday;
          if (weekday == 7) return false;
          return widget.professional.availableDays[weekday - 1];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFF8FA89A).withAlpha((0.5 * 255).round()),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF2A475E),
            shape: BoxShape.circle,
          ),
          disabledTextStyle: TextStyle(
            color: Colors.red.withAlpha((0.5 * 255).round()),
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    if (_isLoadingSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final timeSlots = _generateTimeSlots();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final isAvailable = _isSlotAvailable(timeSlot);

        return ElevatedButton(
          onPressed: isAvailable
              ? () {
                  setState(() {
                    _selectedTimeSlot = timeSlot;
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getSlotColor(timeSlot),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFFC54B4B),
          ),
          child: Text(
            timeSlot,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
