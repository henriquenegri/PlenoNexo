import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalModel {
  final String uid;
  final String name;
  final String email;
  final String document;
  final String phone;
  final String officeAddress;
  final String city;
  final String atuationArea;
  final String professionalId;
  final String accessibleLocation;
  final String specialties;
  final String serviceModality;
  final List<String> accessibilityFeatures;
  final List<String> especialidades;
  final double rating;
  final double consultationPrice;
  final int ratingCount;
  final double ratingTotal;
  final String password;
  final List<bool> availableDays;

  ProfessionalModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.document,
    required this.phone,
    required this.officeAddress,
    required this.city,
    required this.atuationArea,
    required this.professionalId,
    required this.accessibleLocation,
    required this.specialties,
    required this.serviceModality,
    required this.accessibilityFeatures,
    required this.especialidades,
    this.rating = 0.0,
    this.consultationPrice = 0.0,
    this.ratingCount = 0,
    this.ratingTotal = 0.0,
    required this.password,
    this.availableDays = const [true, true, true, true, true, false, false],
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
      city: data['city'] ?? '',
      atuationArea: data['atuationArea'] ?? 'Não informado',
      professionalId: data['professionalId'] ?? '',
      accessibleLocation: data['accessibleLocation'] ?? '',
      specialties: data['specialties'] ?? '',
      serviceModality: data['serviceModality'] ?? 'Não informado',
      accessibilityFeatures: List<String>.from(
        data['accessibilityFeatures'] ?? [],
      ),
      especialidades: List<String>.from(data['especialidades'] ?? []),
      password: data['password'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      consultationPrice: (data['consultationPrice'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      ratingTotal: (data['ratingTotal'] as num?)?.toDouble() ?? 0.0,
      availableDays: data['availableDays'] != null
          ? List<bool>.from(data['availableDays'])
          : [true, true, true, true, true, false, false],
    );
  }
}
