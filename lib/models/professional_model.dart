import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalModel {
  final String uid;
  final String name;
  final String email;
  final String document;
  final String phone;
  final String officeAddress;
  final String atuationArea;
  final String professionalId;
  final String specialties;
  final String serviceModality;
  final List<String> accessibilityFeatures;
  final double rating;
  final double price;
  final String password;

  ProfessionalModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.document,
    required this.phone,
    required this.officeAddress,
    required this.atuationArea,
    required this.professionalId,
    required this.specialties,
    required this.serviceModality,
    required this.accessibilityFeatures,
    this.rating = 0.0,
    this.price = 0.0,
    required this.password,
  });

  factory ProfessionalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ProfessionalModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'Nome não encontrado',
      email: data['email'] ?? '',
      document: data['document'] ?? '',
      phone: data['phone'] ?? '',
      officeAddress: data['officeAddress'] ?? '',
      atuationArea: data['atuationArea'] ?? 'Não informado',
      professionalId: data['professionalId'] ?? '',
      specialties: data['specialties'] ?? '',
      serviceModality: data['serviceModality'] ?? 'Não informado',
      accessibilityFeatures: List<String>.from(
        data['accessibilityFeatures'] ?? [],
      ),
      password: data['password'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
