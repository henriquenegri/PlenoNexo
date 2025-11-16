import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // Inicializar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  
  // ID do profissional (você precisará substituir pelo ID real)
  final professionalId = 'SEU_ID_AQUI';
  
  final now = DateTime.now();
  final startOfDay = DateTime.utc(now.year, now.month, now.day);
  final endOfDay = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

  print('Buscando consultas para o profissional: $professionalId');
  print('Período: $startOfDay até $endOfDay');
  
  try {
    final snapshot = await firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dateTime')
        .get();
    
    print('Encontradas ${snapshot.docs.length} consultas');
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      print('Consulta: ${data['subject']} - Data: ${data['dateTime']}');
    }
  } catch (e) {
    print('Erro ao buscar consultas: $e');
  }
}