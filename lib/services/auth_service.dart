import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plenonexo/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tenta registar um novo utilizador no Firebase Authentication.
  Future<(UserCredential?, String?)> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (userCredential, null); // Sucesso
    } on FirebaseAuthException catch (e) {
      // Mapeia os códigos de erro do Firebase para mensagens mais amigáveis
      if (e.code == 'weak-password') {
        return (null, 'A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        return (null, 'Este email já está a ser utilizado por outra conta.');
      } else if (e.code == 'invalid-email') {
        return (null, 'O formato do email é inválido.');
      }
      return (null, e.message); // Retorna a mensagem padrão para outros erros
    } catch (e) {
      return (null, 'Ocorreu um erro inesperado.');
    }
  }

  /// Tenta fazer o login e verifica se o 'role' do utilizador é o esperado.
  Future<String?> signIn({
    required String email,
    required String password,
    required String expectedRole, // Parâmetro: 'patient' ou 'professional'
  }) async {
    try {
      // Passo 1: Tenta autenticar com o Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Se o login for bem-sucedido, vamos ao passo 2
      if (userCredential.user != null) {
        // Passo 2: Busca o perfil do utilizador no Firestore para verificar o 'role'
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['role'] == expectedRole) {
          // Sucesso! O utilizador está autenticado E tem o 'role' correto.
          return null;
        } else {
          // O utilizador autenticou, mas não tem permissão para esta área.
          // Fazemos o logout por segurança e retornamos uma mensagem de erro.
          await _auth.signOut();
          return 'Você não tem permissão para aceder a esta área.';
        }
      }
      return 'Não foi possível verificar o utilizador.';
    } on FirebaseAuthException catch (e) {
      // Mapeia os códigos de erro do Firebase para mensagens mais amigáveis
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Email ou senha inválidos. Por favor, tente novamente.';
      }
      return e.message; // Retorna a mensagem padrão para outros erros
    } catch (e) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Envia um email de redefinição de senha para o email fornecido.
  Future<(bool, String?)> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return (true, null); // Sucesso
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return (false, 'Não há utilizador correspondente a este email.');
      }
      return (false, e.message); // Outros erros do Firebase
    } catch (e) {
      return (false, 'Ocorreu um erro inesperado ao tentar redefinir a senha.');
    }
  }

  /// Altera a senha do utilizador logado.
  /// Requer a senha atual para reautenticação.
  Future<(bool, String?)> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return (false, 'Nenhum utilizador logado para alterar a senha.');
    }

    try {
      // Reautenticar o utilizador com a senha atual
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Se a reautenticação for bem-sucedida, atualiza a senha
      await user.updatePassword(newPassword);
      return (true, 'Senha alterada com sucesso.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return (false, 'A senha atual está incorreta.');
      } else if (e.code == 'weak-password') {
        return (false, 'A nova senha é muito fraca.');
      }
      return (false, 'Erro ao alterar a senha: ${e.message}');
    } catch (e) {
      return (false, 'Ocorreu um erro inesperado.');
    }
  }

  /// Faz o logout do utilizador atual.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Exclui o utilizador atual do Firebase Authentication.
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Retorna o utilizador do Firebase atualmente logado.
  User? get currentUserAuth => _auth.currentUser;

  Future<UserModel?> getCurrentUserModel() async {
    // Passo 1: Pega o usuário autenticado (a credencial)
    final userAuth = _auth.currentUser;

    if (userAuth == null) {
      // Se não há ninguém logado, não há perfil para buscar.
      return null;
    }

    try {
      // Passo 2: Usa o UID para buscar o documento no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userAuth.uid)
          .get();

      if (userDoc.exists) {
        // Passo 3: Se o documento existe, converte para UserModel e retorna
        return UserModel.fromFirestore(userDoc);
      } else {
        return null;
      }
    } catch (e) {
      // Tratar possíveis erros de rede, etc.
      print("Erro ao buscar dados do usuário: $e");
      return null;
    }
  }
}
