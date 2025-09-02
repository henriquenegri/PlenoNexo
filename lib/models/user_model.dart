import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String cpf;
  final String? state;
  final String? city;
  final String? phone;
  final String? birthDate;
  final String? register;
  final List<String>? neuroDiversity;
  final String password;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    this.state,
    this.city,
    this.phone,
    this.birthDate,
    this.register,
    this.neuroDiversity,
    required this.password,
  });

  // Factory constructor para criar um UserModel a partir de um documento do Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'Nome não encontrado',
      email: data['email'] ?? '',
      cpf: data['cpf'] ?? '',
      state: data['state'],
      city: data['city'],
      phone: data['phone'],
      birthDate: data['birthDate'],
      register: data['register'],
      neuroDiversity: List<String>.from(data['neuroDiversity'] ?? []),
      password: data['password'] ?? '',
    );
  }
}
