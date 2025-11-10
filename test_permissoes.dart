import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Testar acesso ao Firestore
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    
    print('=== TESTE DE PERMISSÕES DO FIRESTORE ===');
    
    // Verificar usuário atual
    final user = auth.currentUser;
    if (user != null) {
      print('Usuário autenticado: ${user.uid}');
      print('Email: ${user.email}');
      
      try {
        // Testar leitura de usuário
        print('\n--- Testando leitura de usuário ---');
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        print('Documento do usuário existe: ${userDoc.exists}');
        if (userDoc.exists) {
          print('Dados do usuário: ${userDoc.data()}');
        }
      } catch (e) {
        print('ERRO ao ler usuário: $e');
      }
      
      try {
        // Testar leitura de profissional
        print('\n--- Testando leitura de profissional ---');
        final profDoc = await firestore.collection('professionals').doc(user.uid).get();
        print('Documento do profissional existe: ${profDoc.exists}');
        if (profDoc.exists) {
          print('Dados do profissional: ${profDoc.data()}');
        }
      } catch (e) {
        print('ERRO ao ler profissional: $e');
      }
      
      try {
        // Testar leitura de consultas
        print('\n--- Testando leitura de consultas ---');
        final appointmentsSnapshot = await firestore.collection('appointments').get();
        print('Total de consultas na coleção: ${appointmentsSnapshot.docs.length}');
        
        // Filtrar consultas do profissional
        final professionalAppointments = appointmentsSnapshot.docs
            .where((doc) {
              final data = doc.data();
              return data['professionalId'] == user.uid;
            })
            .toList();
        
        print('Consultas do profissional: ${professionalAppointments.length}');
        
        if (professionalAppointments.isNotEmpty) {
          print('Primeira consulta: ${professionalAppointments.first.data()}');
        }
      } catch (e) {
        print('ERRO ao ler consultas: $e');
      }
      
    } else {
      print('Nenhum usuário autenticado');
    }
    
    print('\n=== FIM DO TESTE ===');
    
  } catch (e) {
    print('ERRO GERAL: $e');
  }
}