import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plenonexo/models/professional_model.dart';

class ProfessionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para criar o perfil (continua igual)
  Future<void> createProfessionalProfile({
    required String uid,
    required String name,
    required String email,
    required String document,
    required String phone,
    required String officeAddress,
    required String atuationArea,
    required String professionalId,
    required String accessibleLocation,
    required String serviceModality,
    required List<String> accessibilityFeatures,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'document': document,
      'phone': phone,
      'officeAddress': officeAddress,
      'atuationArea': atuationArea,
      'professionalId': professionalId,
      'specialties': accessibleLocation,
      'serviceModality': serviceModality,
      'accessibilityFeatures': accessibilityFeatures,
      'role': 'professional',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Função para retornar as áreas de atuação do array local
  List<String> getAtuationAreas() {
    return atuationAreas;
  }

  // ... (as outras funções como getProfessionalsBySpecialty continuam aqui) ...
  Future<List<ProfessionalModel>> getProfessionalsBySpecialty(
    String specialty,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'professional')
          .where('atuationArea', isEqualTo: specialty)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => ProfessionalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar profissionais por especialidade: $e");
      return [];
    }
  }

  // A nossa lista completa de áreas de atuação
  static final List<String> atuationAreas = [
    'Alergologia',
    'Angiologia',
    'Cardiologia',
    'Clínica Geral',
    'Dermatologia',
    'Dentista',
    'Endocrinologia',
    'Fonoaudiologia',
    'Gastroenterologia',
    'Geriatria',
    'Ginecologia e Obstetrícia',
    'Hematologia',
    'Infectologia',
    'Nefrologia',
    'Neurologia',
    'Nutrologia',
    'Odontologia',
    'Oftalmologia',
    'Oncologia',
    'Ortopedia',
    'Otorrinolaringologia',
    'Pediatria',
    'Pneumologia',
    'Psiquiatria',
    'Reumatologia',
    'Urologia',
    'Psicologia',
    'Psicopedagogia',
    'Terapia Ocupacional',
    'Musicoterapia',
    'Arteterapia',
    'Coaching',
    'Mediação Familiar',
    'Sexologia',
    'Fisioterapia Ortopédica',
    'Fisioterapia Neurológica',
    'Fisioterapia Respiratória',
    'Fisioterapia Pélvica',
    'Quiropraxia',
    'Osteopatia',
    'RPG',
    'Nutrição Clínica',
    'Nutrição Esportiva',
    'Nutrição Funcional',
    'Nutrição Materno-Infantil',
    'Acompanhamento Terapêutico (AT)',
    'Aulas de Reforço Escolar',
    'Consultoria de Amamentação',
    'Doula',
    'Educação Especial',
    'Personal Trainer',
    'Orientação Vocacional',
    'Acupuntura',
    'Aromaterapia',
    'Constelação Familiar',
    'Fitoterapia',
    'Hipnoterapia',
    'Massoterapia',
    'Meditação e Mindfulness',
    'Naturologia',
    'Reiki',
    'Yoga',
    'Cabeleireiro(a)',
    'Design de Sobrancelhas',
    'Esteticista',
    'Manicure e Pedicure',
    'Maquilhador(a)',
  ];
}
