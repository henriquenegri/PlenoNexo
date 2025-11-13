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
    // Ajuste: usar a coleção 'ratings' conforme regras do Firestore
    final reviewRef = _firestore.collection('ratings').doc();
    final appointmentRef = _firestore
        .collection('appointments')
        .doc(appointmentId);

    // Para evitar erros de permissão, não atualizamos o documento do profissional aqui.
    // Em vez disso, registramos a avaliação em 'ratings' e marcamos o agendamento como avaliado.
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
}
