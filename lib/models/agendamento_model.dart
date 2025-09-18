import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String professionalId;
  final DateTime dateTime;
  final String status;
  final double price;
  final String subject;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.professionalId,
    required this.dateTime,
    required this.status,
    required this.price,
    required this.subject,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      professionalId: data['professionalId'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'scheduled',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      subject: data['subject'] ?? 'Consulta',
    );
  }
}
