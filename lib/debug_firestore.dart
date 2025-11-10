import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugFirestore {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Método para debugar consultas no Firestore
  static Future<void> debugProfessionalAppointments() async {
    try {
      print('=== DEBUG FIRESTORE CONSULTAS ===');
      
      // Obter usuário atual
      final User? user = _auth.currentUser;
      if (user == null) {
        print('ERRO: Nenhum usuário logado');
        return;
      }
      
      final professionalId = user.uid;
      print('Profissional ID: $professionalId');
      
      // 1. Verificar se há consultas para este profissional
      print('\n--- Buscando todas as consultas do profissional ---');
      final allAppointments = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .get();
      
      print('Total de consultas encontradas: ${allAppointments.docs.length}');
      
      if (allAppointments.docs.isEmpty) {
        print('NENHUMA consulta encontrada para este profissional!');
        return;
      }
      
      // Mostrar todas as consultas
      for (var doc in allAppointments.docs) {
        final data = doc.data();
        print('\nConsulta ID: ${doc.id}');
        print('  Assunto: ${data['subject']}');
        print('  Data/Hora: ${data['dateTime']}');
        print('  Status: ${data['status']}');
        print('  Patient ID: ${data['patientId']}');
        
        // Converter timestamp para data legível
        if (data['dateTime'] is Timestamp) {
          final timestamp = data['dateTime'] as Timestamp;
          final date = timestamp.toDate();
          print('  Data legível: $date');
          print('  Data UTC: ${date.toUtc()}');
        }
      }
      
      // 2. Verificar consultas de hoje
      print('\n--- Buscando consultas de hoje ---');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      print('Data de hoje: $now');
      print('Início do dia: $startOfDay');
      print('Fim do dia: $endOfDay');
      
      final todayAppointments = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();
      
      print('Consultas de hoje encontradas: ${todayAppointments.docs.length}');
      
      // 3. Verificar se há índices compostos necessários
      print('\n--- Verificando necessidade de índices ---');
      if (allAppointments.docs.length > 0) {
        print('Atenção: Se a busca por data falhar, você pode precisar criar um índice composto');
        print('no Firestore para professionalId + dateTime.');
        print('Link para criar índice será fornecido no erro, se houver.');
      }
      
      print('\n=== FIM DO DEBUG ===');
      
    } catch (e, stackTrace) {
      print('ERRO no debug: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  /// Método para testar com um profissional específico
  static Future<void> debugWithProfessionalId(String professionalId) async {
    try {
      print('=== DEBUG COM PROFESSIONAL ID ESPECÍFICO ===');
      print('Testing com Professional ID: $professionalId');
      
      // Buscar consultas
      final appointments = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .get();
      
      print('Consultas encontradas: ${appointments.docs.length}');
      
      for (var doc in appointments.docs) {
        final data = doc.data();
        print('\nConsulta: ${data['subject']} - ${data['dateTime']}');
      }
      
      print('=== FIM DO DEBUG ===');
      
    } catch (e) {
      print('ERRO: $e');
    }
  }
}