import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/models/user_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria um novo agendamento
  Future<void> createAppointment({
    required String patientId,
    required String professionalId,
    required DateTime dateTime,
    required String subject,
    required double consultationPrice,
    String status = 'scheduled',
  }) async {
    // Garantir que a data seja salva em UTC para consistência
    final utcDateTime = dateTime.toUtc();

    await _firestore.collection('appointments').add({
      'patientId': patientId,
      'professionalId': professionalId,
      'dateTime': Timestamp.fromDate(utcDateTime),
      'subject': subject,
      'price': consultationPrice,
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

  /// Busca agendamentos de um profissional em uma data específica
  Future<List<AppointmentModel>> getProfessionalAppointmentsByDate(
    String professionalId,
    DateTime selectedDate,
  ) async {
    // Garante que a busca seja feita em UTC para consistência
    final startOfDay = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final endOfDay = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do profissional por data: $e");
      return [];
    }
  }

  // Obter agendamentos de um paciente por mês
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
      print('Erro ao obter agendamentos do paciente: $e');
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

  /// Retorna um stream com todos os agendamentos de um profissional.
  Stream<List<AppointmentModel>> getProfessionalAppointmentsStream(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
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

  /// Retorna um stream com os agendamentos de hoje para um profissional.
  Stream<List<AppointmentModel>> getTodayProfessionalAppointmentsStream(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dateTime')
        .snapshots()
        .asyncMap((snapshot) async {
      List<AppointmentModel> appointments = [];
      for (var doc in snapshot.docs) {
        final appointment = AppointmentModel.fromFirestore(doc);
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

  /// Retorna um stream com os agendamentos dos últimos 7 dias para o gráfico.
  Stream<List<AppointmentModel>> getAppointmentsForChartStream(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: DateTime.now().subtract(
            const Duration(days: 6),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Retorna um stream com todos os agendamentos de um paciente.
  Stream<List<AppointmentModel>> getPatientAppointmentsStream(String patientId) {
    if (patientId.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<AppointmentModel> appointments = [];
      for (var doc in snapshot.docs) {
        final appointment = AppointmentModel.fromFirestore(doc);

        final professionalDoc = await _firestore
            .collection('professionals')
            .doc(appointment.professionalId)
            .get();
        if (professionalDoc.exists) {
          final professionalModel =
              ProfessionalModel.fromFirestore(professionalDoc);
          appointment.professionalName = professionalModel.name;
        }

        appointments.add(appointment);
      }
      return appointments;
    });
  }
}