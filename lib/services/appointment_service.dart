import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plenonexo/models/agendamento_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria um novo agendamento
  Future<void> createAppointment({
    required String patientId,
    required String professionalId,
    required DateTime dateTime,
    required String subject,
    required double price,
    String status = 'scheduled',
  }) async {
    await _firestore.collection('appointments').add({
      'patientId': patientId,
      'professionalId': professionalId,
      'dateTime': Timestamp.fromDate(dateTime),
      'subject': subject,
      'price': price,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Busca todos os agendamentos de um paciente
  Future<List<AppointmentModel>> getPatientAppointments(
    String patientId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do paciente: $e");
      return [];
    }
  }

  /// Busca agendamentos de um paciente em uma data específica
  Future<List<AppointmentModel>> getPatientAppointmentsByDate(
    String patientId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos por data: $e");
      return [];
    }
  }

  /// Busca agendamentos de um paciente em um mês específico
  Future<List<AppointmentModel>> getPatientAppointmentsByMonth(
    String patientId,
    DateTime month,
  ) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'dateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do mês: $e");
      return [];
    }
  }

  /// Atualiza o status de um agendamento
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancela um agendamento
  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  /// Busca todos os agendamentos de um profissional
  Future<List<AppointmentModel>> getProfessionalAppointments(
    String professionalId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do profissional: $e");
      return [];
    }
  }
}

