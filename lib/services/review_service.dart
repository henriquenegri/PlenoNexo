import 'package:cloud_firestore/cloud_firestore.dart';

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
    final reviewRef = _firestore.collection('reviews').doc();
    final appointmentRef = _firestore
        .collection('appointments')
        .doc(appointmentId);

    return _firestore.runTransaction((transaction) async {
      final professionalDoc = await transaction.get(professionalRef);
      if (!professionalDoc.exists) {
        throw Exception("Profissional não encontrado!");
      }

      // 2. Calcula a nova nota média
      final oldRatingTotal = professionalDoc.data()?['ratingTotal'] ?? 0.0;
      final oldRatingCount = professionalDoc.data()?['ratingCount'] ?? 0;

      final newRatingTotal = oldRatingTotal + rating;
      final newRatingCount = oldRatingCount + 1;
      final newAverageRating = newRatingTotal / newRatingCount;

      // 3. Atualiza os dados do profissional
      transaction.update(professionalRef, {
        'rating': newAverageRating,
        'ratingTotal': newRatingTotal,
        'ratingCount': newRatingCount,
      });

      // 4. Cria o documento da avaliação
      transaction.set(reviewRef, {
        'professionalId': professionalId,
        'patientId': patientId,
        'appointmentId': appointmentId,
        'rating': rating,
        'reviewText': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. Marca o agendamento como avaliado para não poder avaliar de novo
      transaction.update(appointmentRef, {'isReviewed': true});
    });
  }
}
