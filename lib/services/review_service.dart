import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AURA/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReview({
    required String professionalId,
    required String patientId,
    required String appointmentId,
    required double rating,
    required String reviewText,
  }) async {
    final professionalRef = _firestore.collection('users').doc(professionalId);
    final reviewRef = _firestore.collection('ratings').doc();
    final appointmentRef = _firestore
        .collection('appointments')
        .doc(appointmentId);

    return _firestore.runTransaction((transaction) async {
      // 1. Cria o documento da avaliação
      transaction.set(reviewRef, {
        'professionalId': professionalId,
        'patientId': patientId,
        'appointmentId': appointmentId,
        'rating': rating,
        'reviewText': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // 2. Marca o agendamento como avaliado para não poder avaliar de novo
      transaction.update(appointmentRef, {'isReviewed': true});
    });
  }

  Future<List<ReviewModel>> getProfessionalReviews(
    String professionalId,
  ) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('professionalId', isEqualTo: professionalId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }
}
