import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:AURA/utils/time_utils.dart';
import 'package:AURA/models/agendamento_model.dart';
import 'package:AURA/services/appointment_service.dart';
import 'package:AURA/utils/app_theme.dart';

class VisualizarConsultasPage extends StatefulWidget {
  const VisualizarConsultasPage({super.key});

  @override
  State<VisualizarConsultasPage> createState() =>
      _VisualizarConsultasPageState();
}

class _VisualizarConsultasPageState extends State<VisualizarConsultasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppointmentService _appointmentService = AppointmentService();
  late Stream<List<AppointmentModel>> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      print('DEBUG: VisualizarConsultas - Usuário atual: ${user.uid}');
      // Usar método simples que não depende de buscar dados externos
      _appointmentsStream = _appointmentService
          .getProfessionalAppointmentsSimple(user.uid);
    } else {
      print('DEBUG: VisualizarConsultas - Usuário não autenticado');
      _appointmentsStream = Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.brancoPrincipal,
        title: Row(
          children: [Image.asset('assets/img/PlenoNexo.png', height: 40)],
        ),
        elevation: 0,
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _appointmentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma consulta agendada.'));
          }

          final appointments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(appointment);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final date = appointment.dateTime;
    final formattedDate = BrazilTime.formatDate(date);
    final formattedTime = BrazilTime.formatTime(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.patientName ?? 'Paciente não encontrado',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.pretoPrincipal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.secondaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  '$formattedDate às $formattedTime',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:', style: GoogleFonts.poppins()),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGreen.withAlpha(
                      (255 * 0.2).round(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
