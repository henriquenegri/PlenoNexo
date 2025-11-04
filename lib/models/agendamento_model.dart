import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String professionalId;
  final DateTime dateTime;
  final String status;
  final double consultationPrice;
  final String subject;
  String? patientName;
  String? professionalName;
  final bool isReviewed;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.professionalId,
    required this.dateTime,
    required this.status,
    required this.consultationPrice,
    required this.subject,
    this.isReviewed = false,
    this.patientName,
    this.professionalName,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Converter a data do Firestore para o timezone local
    final timestamp = data['dateTime'] as Timestamp;
    final utcDateTime = timestamp.toDate();

    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      professionalId: data['professionalId'] ?? '',
      dateTime: utcDateTime,
      status: data['status'] ?? 'scheduled',
      consultationPrice: (data['price'] as num?)?.toDouble() ?? 0.0,
      subject: data['subject'] ?? 'Consulta',
      isReviewed: data['isReviewed'] ?? false,
    );
  }
}