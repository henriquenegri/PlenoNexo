import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String professionalId;
  final double rating;
  final String comment;

  ReviewModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.professionalId,
    required this.rating,
    required this.comment,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      id: doc.id,
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      professionalId: data['professionalId'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
    );
  }
}
