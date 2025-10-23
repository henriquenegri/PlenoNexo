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
    final firebaseUser = _authService.currentUserAuth;

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

  /// Atualiza o perfil do utilizador.
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String email,
    String? city,
    String? phone,
    String? state,
    String? birthDate,
    List<String>? neuroDiversity,
    String? password,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (city != null) updateData['city'] = city;
      if (phone != null) updateData['phone'] = phone;
      if (state != null) updateData['state'] = state;
      if (birthDate != null) updateData['birthDate'] = birthDate;
      if (neuroDiversity != null) updateData['neuroDiversity'] = neuroDiversity;

      await _firestore.collection('users').doc(uid).update(updateData);

      // If password is provided, update it in Firebase Auth
      if (password != null && password.isNotEmpty) {
        final firebaseUser = _authService.currentUserAuth;
        if (firebaseUser != null) {
          await firebaseUser.updatePassword(password);
        }
      }
    } catch (e) {
      print("Erro ao atualizar perfil do utilizador: $e");
      rethrow;
    }
  }

  /// Exclui a conta do utilizador.
  Future<void> deleteUserAccount(String uid) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print("Erro ao excluir conta do utilizador: $e");
      rethrow;
    }
  }
}
