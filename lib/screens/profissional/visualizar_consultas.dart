import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/utils/app_theme.dart';

class VisualizarConsultasPage extends StatefulWidget {
  const VisualizarConsultasPage({super.key});

  @override
  State<VisualizarConsultasPage> createState() =>
      _VisualizarConsultasPageState();
}

class _VisualizarConsultasPageState extends State<VisualizarConsultasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppointmentModel>> _getAppointmentsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: user.uid)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<AppointmentModel> appointments = [];
          for (var doc in snapshot.docs) {
            final appointment = AppointmentModel.fromFirestore(doc);

            // Buscar nome do paciente
            final userDoc = await _firestore
                .collection('users')
                .doc(appointment.patientId)
                .get();
            if (userDoc.exists) {
              final userModel = UserModel.fromFirestore(userDoc);
              appointment.patientName = userModel.name;
            }

            appointments.add(appointment);
          }
          return appointments;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.brancoPrincipal,
        title: const Text('Minhas Consultas'),
        elevation: 0,
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _getAppointmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);

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
