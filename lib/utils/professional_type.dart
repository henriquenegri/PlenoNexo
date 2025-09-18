import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalModel {
  final String uid;
  final String name;
  final String email;
  final String cpfCnpj;
  final String phone;
  final String address;
  final String atuationArea;
  final String code;
  final String specialty;
  final String modality;
  final double price;
  final String password;

  ProfessionalModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpfCnpj,
    required this.phone,
    required this.address,
    required this.atuationArea,
    required this.code,
    required this.specialty,
    required this.modality,
    required this.price,
    required this.password,
  });

  // Factory constructor para criar um ProfessionalModel a partir de um documento do Firestore
  factory ProfessionalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProfessionalModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'Nome não encontrado',
      email: data['email'] ?? '',
      cpfCnpj: data['cpfCnpj'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      atuationArea: data['atuationArea'] ?? 'Especialidade não informada',
      code: data['code'] ?? '',
      specialty: data['specialty'] ?? 'Especialidade não informada',
      modality: data['modality'] ?? 'Modalidade não informada',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      password: data['password'] ?? '',
    );
  }
}
