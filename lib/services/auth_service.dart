import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plenonexo/models/user_model.dart';

class AuthService {
  // 1. Instâncias do Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerPatient({
    required String name,
    required String email,
    required String state,
    required String city,
    required String birthDate,
    required String cpf,
    required String phone,
    required String password,
    required String? register,
    required List<String> neurodiversities,
  }) async {
    try {
      // Passo 1: Criar o utilizador no Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;

      // Passo 2: Criar o documento no Firestore com os dados do paciente
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'name': name,
        'email': email,
        'cpf': cpf,
        'state': state,
        'city': city,
        'phone': phone,
        'birthDate': birthDate,
        'register': register,
        'neuroDiversity': neurodiversities,
        'password': password,
        'role': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Tenta registar um novo profissional.
  Future<String?> registerProfessional({
    required String professionalId,
    required String name,
    required String email,
    required String cpfCnpj,
    required String phone,
    required String address,
    required String atuationArea,
    required String code,
    required String specialty,
    required String modality,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;

      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'professionalId': professionalId,
        'name': name,
        'email': email,
        'cpfCnpj': cpfCnpj,
        'phone': phone,
        'address': address,
        'atuationArea': atuationArea,
        'code': code,
        'specialty': specialty,
        'modality': modality,
        'password': password,
        'role': 'professional',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  // --- FUNÇÕES DE LOGIN ---

  /// Tenta fazer o login de um utilizador.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Busca os dados do usuário.
  Future<UserModel?> getCurrentUserData() async {
    final User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      try {
        final DocumentSnapshot userDoc = await _firestore
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

  /// Faz o logout do utilizador atual.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
