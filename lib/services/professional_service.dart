import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plenonexo/models/professional_model.dart';

class ProfessionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para criar o perfil (atualizada com consultationPrice e availableDays)
  Future<void> createProfessionalProfile({
    required String uid,
    required String name,
    required String email,
    required String document,
    required String phone,
    required String officeAddress,
    required String city,
    required String atuationArea,
    required String professionalId,
    required String accessibleLocation,
    required String serviceModality,
    required List<String> accessibilityFeatures,
    required List<String> especialidades,
    required String password,
    double consultationPrice = 0.0,
    List<bool> availableDays = const [
      true,
      true,
      true,
      true,
      true,
      false,
      false,
    ],
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'document': document,
      'phone': phone,
      'officeAddress': officeAddress,
      'city': city,
      'cityLower': city.trim().toLowerCase(),
      'atuationArea': atuationArea,
      'professionalId': professionalId,
      'accessibleLocation': accessibleLocation,
      'serviceModality': serviceModality,
      'accessibilityFeatures': accessibilityFeatures,
      'especialidades': especialidades,
      'consultationPrice': consultationPrice,
      'password': password,
      'availableDays': availableDays,
      'role': 'professional',
      'rating': 0.0,
      'ratingCount': 0,
      'ratingTotal': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Função para buscar os dados do profissional logado
  Future<ProfessionalModel?> getCurrentProfessionalData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnapshot.exists) {
          return ProfessionalModel.fromFirestore(docSnapshot);
        }
      } catch (e) {
        print("Erro ao buscar dados do profissional: $e");
        return null;
      }
    }
    return null;
  }

  // Função para buscar um profissional pelo seu ID
  Future<ProfessionalModel?> getProfessionalById(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return ProfessionalModel.fromFirestore(docSnapshot);
      }
    } catch (e) {
      print("Erro ao buscar profissional por ID: $e");
      return null;
    }
    return null;
  }

  // Função para atualizar o perfil do profissional
  Future<void> updateProfessionalProfile({
    required String uid,
    required String name,
    required String phone,
    required String officeAddress,
    required String city,
    required String atuationArea,
    required String professionalId,
    required String accessibleLocation,
    required String serviceModality,
    required List<String> accessibilityFeatures,
    required double consultationPrice,
    required List<String> especialidades,
    required List<bool> availableDays,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'officeAddress': officeAddress,
        'city': city,
        'cityLower': city.trim().toLowerCase(),
        'atuationArea': atuationArea,
        'professionalId': professionalId,
        'accessibleLocation': accessibleLocation,
        'serviceModality': serviceModality,
        'accessibilityFeatures': accessibilityFeatures,
        'consultationPrice': consultationPrice,
        'especialidades': especialidades,
        'availableDays': availableDays,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erro ao atualizar perfil do profissional: $e");
      rethrow;
    }
  }

  // Função para excluir a conta do profissional do Firestore
  Future<void> deleteProfessionalAccount(String uid) async {
    try {
      // Exclui o documento do profissional do Firestore
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print("Erro ao excluir conta do profissional: $e");
      rethrow;
    }
  }

  // Função para retornar as áreas de atuação do array local
  List<String> getAtuationAreas() {
    return atuationAreas;
  }

  // ... (as outras funções como getProfessionalsBySpecialty continuam aqui) ...
  Future<List<ProfessionalModel>> getProfessionalsBySpecialty(
    String specialty, {
    String? city,
  }) async {
    try {
      final base = _firestore
          .collection('users')
          .where('role', isEqualTo: 'professional');

      // Primeira tentativa: campo 'atuationArea' igual à especialidade
      Query query1 = base.where('atuationArea', isEqualTo: specialty);
      if (city != null && city.isNotEmpty) {
        query1 = query1.where('city', isEqualTo: city.trim());
      }
      final snap1 = await query1.get();

      if (snap1.docs.isNotEmpty) {
        return snap1.docs
            .map((doc) => ProfessionalModel.fromFirestore(doc))
            .toList();
      }

      // Segunda tentativa: array 'especialidades' contém a especialidade
      Query query2 = base.where('especialidades', arrayContains: specialty);
      if (city != null && city.isNotEmpty) {
        query2 = query2.where('city', isEqualTo: city.trim());
      }
      final snap2 = await query2.get();

      if (snap2.docs.isEmpty) {
        return [];
      }

      return snap2.docs
          .map((doc) => ProfessionalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar profissionais por especialidade: $e");
      return [];
    }
  }

  // Função para buscar todos os profissionais
  Future<List<ProfessionalModel>> getAllProfessionals() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'professional')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => ProfessionalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar todos os profissionais: $e");
      return [];
    }
  }

  // A nossa lista completa de áreas de atuação
  static final List<String> atuationAreas = [
    'Acupuntura',
    'Advogado',
    'Alergologia',
    'Angiologia',
    'Acompanhamento Terapêutico (AT)',
    'Aromaterapia',
    'Arteterapia',
    'Barbeiro',
    'Cabeleireiro(a)',
    'Cardiologia',
    'Clínico Geral',
    'Coaching',
    'Consultoria de Amamentação',
    'Cuidador de Idoso',
    'Dentista',
    'Dermatologia',
    'Design de Sobrancelhas',
    'Designer de Sobrancelhas',
    'Doula',
    'Educação Especial',
    'Endocrinologia',
    'Esteticista',
    'Fitoterapia',
    'Fisioterapia',
    'Fonoaudiologia',
    'Gastroenterologia',
    'Geriatria',
    'Ginecologia e Obstetrícia',
    'Hematologia',
    'Hipnoterapia',
    'Infectologia',
    'Maquilhador(a)',
    'Manicure',
    'Manicure e Pedicure',
    'Massoterapia',
    'Meditação e Mindfulness',
    'Musicoterapia',
    'Naturólogo',
    'Naturologia',
    'Nefrologia',
    'Neurologia',
    'Nutrição Clínica',
    'Nutrição Esportiva',
    'Nutrição Funcional',
    'Nutrição Materno-Infantil',
    'Nutrologia',
    'Odontologia',
    'Oftalmologia',
    'Oncologia',
    'Orientação Vocacional',
    'Orientador(a) Vocacional',
    'Ortopedia',
    'Osteopatia',
    'Otorrinolaringologia',
    'Pediatria',
    'Personal Organizer',
    'Personal Trainer',
    'Pneumologia',
    'Professor(a) de Idiomas',
    'Professor(a) de Música',
    'Professor(a) Particular',
    'Psicologia',
    'Psicopedagogia',
    'Psicopedagogo',
    'Psicólogo',
    'Psiquiatria',
    'Quiropraxia',
    'Reiki',
    'Reumatologia',
    'RPG',
    'Sexologia',
    'Terapia Ocupacional',
    'Yoga',
  ];
}
