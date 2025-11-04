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

      debugPrint(
        'Total de agendamentos carregados para avaliação: ${allAppointments.length}',
      );

      // Mostrar todas as consultas não canceladas, mas apenas permitir avaliação das que já passaram
      final activeAppointments = allAppointments
          .where((app) => app.status.toLowerCase() != 'cancelled')
          .toList();

      debugPrint(
        'Agendamentos ativos para avaliação: ${activeAppointments.length}',
      );

      List<AppointmentWithProfessional> reviewsWithProfessionals = [];
      for (var app in activeAppointments) {
        final prof = await _professionalService.getProfessionalById(
          app.professionalId,
        );
        if (prof != null) {
          reviewsWithProfessionals.add(AppointmentWithProfessional(app, prof));
        }
      }

      debugPrint(
        'Consultas com profissionais carregados: ${reviewsWithProfessionals.length}',
      );

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
    final now = DateTime.now();
    final isPastAppointment = appointment.dateTime.isBefore(now);
    final canReview = isPastAppointment && !appointment.isReviewed;

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
                  Text(
                    'Consulta em: ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(appointment.dateTime)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: appointment.isReviewed
                          ? const Color(0xFF10B981)
                          : isPastAppointment
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF6B7280),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.isReviewed
                          ? 'Avaliada'
                          : isPastAppointment
                          ? 'Pendente'
                          : 'Futura',
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
              else if (appointment.isReviewed)
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
                      color: const Color(0xFF6B7280),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Aguardando consulta',
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
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A475E).withOpacity(0.9),
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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : _pendingReviews.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Você não tem consultas agendadas.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: _pendingReviews.length,
                              itemBuilder: (context, index) {
                                final item = _pendingReviews[index];
                                return _buildReviewCard(item);
                              },
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
