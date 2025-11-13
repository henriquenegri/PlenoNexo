import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/models/avaliacao_screen.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/screens/usuario/home/home_screem_user.dart';
import 'package:plenonexo/services/appointment_service.dart';
import 'package:plenonexo/services/professional_service.dart';
import 'package:plenonexo/services/user_service.dart';
import 'package:plenonexo/screens/usuario/options/options_screen.dart';
import 'package:flutter_svg/svg.dart';

class AppointmentWithProfessional {
  final AppointmentModel appointment;
  final ProfessionalModel professional;
  AppointmentWithProfessional(this.appointment, this.professional);
}

class ProfessionalRatingScreen extends StatefulWidget {
  const ProfessionalRatingScreen({super.key});

  @override
  State<ProfessionalRatingScreen> createState() =>
      _ProfessionalRatingScreenState();
}

class _ProfessionalRatingScreenState extends State<ProfessionalRatingScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final UserService _userService = UserService();
  final AppointmentService _appointmentService = AppointmentService();

  UserModel? _currentUser;
  List<AppointmentWithProfessional> _pendingReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar dados quando a tela for exibida novamente
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _userService.getCurrentUserData();
      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final allAppointments = await _appointmentService.getPatientAppointments(
        user.uid,
      );

      // Apenas consultas que foram completadas e ainda não foram avaliadas
      final completedAppointments = allAppointments
          .where((app) => app.status.toLowerCase() == 'completed' && !app.isReviewed)
          .toList();

      List<AppointmentWithProfessional> reviewsWithProfessionals = [];
      for (var app in completedAppointments) {
        final prof = await _professionalService.getProfessionalById(
          app.professionalId,
        );
        if (prof != null) {
          reviewsWithProfessionals.add(AppointmentWithProfessional(app, prof));
        }
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _pendingReviews = reviewsWithProfessionals;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados para avaliação: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar profissionais: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFirstName() {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    return _currentUser!.name.split(' ').first;
  }

  Widget _buildReviewCard(AppointmentWithProfessional item) {
    final professional = item.professional;
    final appointment = item.appointment;
    final canReview = appointment.status.toLowerCase() == 'completed' && !appointment.isReviewed;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: canReview ? const Color(0xFF3B748F) : const Color(0xFF6B7280),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: canReview
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvaliacaoScreen(
                      appointment: appointment,
                      professional: professional,
                    ),
                  ),
                ).then((_) => _loadData());
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Consulta em: ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(appointment.dateTime)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: appointment.isReviewed
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.isReviewed
                          ? 'Avaliada'
                          : 'Pendente',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                professional.name,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                professional.atuationArea,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              if (canReview)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Avaliar consulta',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF2A475E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF2A475E),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Já avaliada',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentsSection() {
    if (_currentUser == null) {
      return Center(
        child: Text(
          'Faça login para ver suas consultas.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
      );
    }

    return StreamBuilder<List<AppointmentModel>>(
      stream: _appointmentService.getPatientAppointmentsStream(_currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Nenhuma consulta encontrada.',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          );
        }

        final now = DateTime.now();
        final items = snapshot.data!
            .where((a) => a.dateTime.isAfter(now.subtract(const Duration(days: 7))))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return Column(
          children: items.map(_buildAppointmentTile).toList(),
        );
      },
    );
  }

  Widget _buildAppointmentTile(AppointmentModel appointment) {
    final isCancelled = appointment.status.toLowerCase() == 'cancelled';
    final isScheduled = appointment.status.toLowerCase() == 'scheduled';
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime);

    return Card(
      color: const Color(0xFF3B748F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                        appointment.professionalName ?? 'Profissional',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Colors.redAccent
                        : isScheduled
                            ? Colors.orangeAccent
                            : Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusText(appointment.status),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isScheduled)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _cancelAppointmentFromRating(appointment.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancelar consulta'),
                ),
              )
            else if (isCancelled)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Cancelada',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendada';
      case 'completed':
        return 'Realizada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Future<void> _cancelAppointmentFromRating(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(
        appointmentId,
        'Cancelado pelo paciente',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta cancelada.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar consulta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
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
                        DateTime.now().toString().split(' ')[0],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2A475E).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox.shrink(),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Text(
                            'Minhas Consultas',
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _loadData,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            tooltip: 'Recarregar consultas',
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              children: [
                                // Seção de avaliações pendentes
                                Row(
                                  children: [
                                    Text(
                                      'Avaliações Pendentes',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_pendingReviews.isEmpty)
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 48,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sem avaliações pendentes.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ..._pendingReviews.map(_buildReviewCard).toList(),

                                const SizedBox(height: 24),

                                // Seção de consultas para cancelamento
                                Row(
                                  children: [
                                    Text(
                                      'Consultas Agendadas / Canceladas',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildUpcomingAppointmentsSection(),
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
        unselectedItemColor: const Color(0xFF2A475E).withOpacity(0.6),
        selectedItemColor: const Color(0xFF2A475E),
        currentIndex:
            1, // Garante que o ícone de "Avaliações" esteja selecionado
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/iconeBatimentoCardiaco.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                const Color(0xFF2A475E).withOpacity(0.6),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/iconeBatimentoCardiaco.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                const Color(0xFF2A475E),
                BlendMode.srcIn,
              ),
            ),
            label: 'Consultas',
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
}
