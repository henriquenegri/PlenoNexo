import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AURA/models/agendamento_model.dart';
import 'package:AURA/models/user_model.dart';

/// Método alternativo para debug - busca consultas de hoje com diferentes abordagens
Stream<List<AppointmentModel>> debugGetTodayProfessionalAppointmentsStream(
  String professionalId,
) async* {
  final firestore = FirebaseFirestore.instance;

  if (professionalId.isEmpty) {
    print('DEBUG: professionalId está vazio');
    yield [];
    return;
  }

  // Testar diferentes abordagens de data
  final now = DateTime.now();

  // Abordagem 1: UTC como está atualmente
  final startOfDayUTC = DateTime.utc(now.year, now.month, now.day);
  final endOfDayUTC = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

  // Abordagem 2: Local
  final startOfDayLocal = DateTime(now.year, now.month, now.day);
  final endOfDayLocal = DateTime(now.year, now.month, now.day, 23, 59, 59);

  // Abordagem 3: Expandir range (ontem até amanhã)
  final startOfYesterday = DateTime.utc(now.year, now.month, now.day - 1);
  final endOfTomorrow = DateTime.utc(
    now.year,
    now.month,
    now.day + 1,
    23,
    59,
    59,
  );

  print('DEBUG: Testando diferentes abordagens para: $professionalId');
  print('DEBUG: Hora local atual: $now');
  print('DEBUG: UTC atual: ${now.toUtc()}');

  // Teste 1: UTC atual
  try {
    print('DEBUG: Teste 1 - UTC atual');
    final snapshot1 = await firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDayUTC),
        )
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDayUTC))
        .orderBy('dateTime')
        .get();

    print('DEBUG: Teste 1 encontrou ${snapshot1.docs.length} documentos');

    // Teste 2: Local
    print('DEBUG: Teste 2 - Local');
    final snapshot2 = await firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDayLocal),
        )
        .where(
          'dateTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDayLocal),
        )
        .orderBy('dateTime')
        .get();

    print('DEBUG: Teste 2 encontrou ${snapshot2.docs.length} documentos');

    // Teste 3: Range expandido
    print('DEBUG: Teste 3 - Range expandido');
    final snapshot3 = await firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYesterday),
        )
        .where(
          'dateTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfTomorrow),
        )
        .orderBy('dateTime')
        .get();

    print('DEBUG: Teste 3 encontrou ${snapshot3.docs.length} documentos');

    // Teste 4: Apenas filtro de profissional, sem restrição de data
    print('DEBUG: Teste 4 - Apenas profissional');
    final snapshot4 = await firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .orderBy('dateTime')
        .get();

    print('DEBUG: Teste 4 encontrou ${snapshot4.docs.length} documentos');

    // Mostrar detalhes das consultas encontradas
    if (snapshot4.docs.isNotEmpty) {
      for (var doc in snapshot4.docs.take(3)) {
        // Mostrar apenas 3 primeiras
        final data = doc.data();
        final timestamp = data['dateTime'] as Timestamp;
        print('DEBUG: Consulta encontrada - ID: ${doc.id}');
        print('DEBUG: Assunto: ${data['subject']}');
        print('DEBUG: Data UTC: ${timestamp.toDate()}');
        print('DEBUG: Data local: ${timestamp.toDate().toLocal()}');
        print('DEBUG: Status: ${data['status']}');
        print('---');
      }
    }

    // Processar os resultados do teste principal (UTC)
    List<AppointmentModel> appointments = [];
    for (var doc in snapshot1.docs) {
      final appointment = AppointmentModel.fromFirestore(doc);
      final userDoc = await firestore
          .collection('users')
          .doc(appointment.patientId)
          .get();
      if (userDoc.exists) {
        final userModel = UserModel.fromFirestore(userDoc);
        appointment.patientName = userModel.name;
      }
      appointments.add(appointment);
    }

    print('DEBUG: Total de consultas processadas: ${appointments.length}');
    yield appointments;
  } catch (e) {
    print('DEBUG: Erro ao buscar consultas: $e');
    yield [];
  }
}
