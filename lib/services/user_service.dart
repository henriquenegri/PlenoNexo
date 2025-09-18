import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/services/auth_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Cria o documento de perfil para um novo paciente no Firestore.
  Future<void> createPatientProfile({
    required String uid,
    required String name,
    required String email,
    required String state,
    required String city,
    required String birthDate,
    required String cpf,
    required String phone,
    required String? registrationFor,
    required List<String> neurodiversities,
    required String password,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'cpf': cpf,
      'state': state,
      'city': city,
      'phone': phone,
      'birthDate': birthDate,
      'registrationFor': registrationFor,
      'neurodiversities': neurodiversities,
      'role': 'patient',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Busca os dados do utilizador (paciente) atualmente logado.
  Future<UserModel?> getCurrentUserData() async {
    final firebaseUser = _authService.currentUser;

    if (firebaseUser != null) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        }
      } catch (e) {
        print("Erro ao buscar dados do utilizador: $e");
        return null;
      }
    }
    return null;
  }
}
