import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String professionalId;
  final String patientId;
  final String appointmentId;
  final double rating;
  final String reviewText;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.professionalId,
    required this.patientId,
    required this.appointmentId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      professionalId: data['professionalId'] ?? '',
      patientId: data['patientId'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewText: data['reviewText'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
