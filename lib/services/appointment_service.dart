import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/models/user_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria um novo agendamento
  Future<void> createAppointment({
    required String patientId,
    required String professionalId,
    required DateTime dateTime,
    required String subject,
    required double consultationPrice,
    String status = 'scheduled',
  }) async {
    // Garantir que a data seja salva em UTC para consistência
    final utcDateTime = dateTime.toUtc();

    await _firestore.collection('appointments').add({
      'patientId': patientId,
      'professionalId': professionalId,
      'dateTime': Timestamp.fromDate(utcDateTime),
      'subject': subject,
      'price': consultationPrice,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Busca todos os agendamentos de um paciente
  Future<List<AppointmentModel>> getPatientAppointments(
    String patientId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do paciente: $e");
      return [];
    }
  }

  /// Busca agendamentos de um paciente em uma data específica
  Future<List<AppointmentModel>> getPatientAppointmentsByDate(
    String patientId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos por data: $e");
      return [];
    }
  }

  /// Busca agendamentos de um profissional em uma data específica
  Future<List<AppointmentModel>> getProfessionalAppointmentsByDate(
    String professionalId,
    DateTime selectedDate,
  ) async {
    // Garante que a busca seja feita em UTC para consistência
    final startOfDay = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final endOfDay = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do profissional por data: $e");
      return [];
    }
  }

  // Obter agendamentos de um paciente por mês
  Future<List<AppointmentModel>> getPatientAppointmentsByMonth(
    String patientId,
    DateTime month,
  ) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'dateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao obter agendamentos do paciente: $e');
      return [];
    }
  }

  /// Atualiza o status de um agendamento
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao atualizar status do agendamento: $e');
      rethrow;
    }
  }

  /// Cancela um agendamento
  /// Cancela um agendamento com motivo
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao cancelar agendamento: $e');
      rethrow;
    }
  }

  /// Cancela um agendamento sem motivo (método antigo para compatibilidade)
  Future<void> cancelAppointmentSimple(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  /// Busca todos os agendamentos de um profissional
  Future<List<AppointmentModel>> getProfessionalAppointments(
    String professionalId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .orderBy('dateTime')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do profissional: $e");
      return [];
    }
  }

  /// Retorna um stream com todos os agendamentos de um profissional.
  Stream<List<AppointmentModel>> getProfessionalAppointmentsStream(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<AppointmentModel> appointments = [];
      for (var doc in snapshot.docs) {
        final appointment = AppointmentModel.fromFirestore(doc);

        // Buscar nome do paciente
        final userDoc = await _firestore
            .collection('users')
            .doc(appointment.patientId)
            .get();
        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          appointment.patientName = userModel.name;
        }

        appointments.add(appointment);
      }
      return appointments;
    }).handleError((error) {
      print('DEBUG: Erro em getProfessionalAppointmentsStream: $error');
      print('DEBUG: Usando método fallback devido a erro de permissão');
      // Se houver erro de permissão, usar método alternativo
      return _getProfessionalAppointmentsFallback(professionalId);
    });
  }
  
  /// Método fallback para buscar consultas do profissional (sem query composta)
  Future<List<AppointmentModel>> _getProfessionalAppointmentsFallback(String professionalId) async {
    try {
      print('DEBUG: Usando fallback para buscar todas as consultas do profissional');
      
      // Buscar todas as consultas e filtrar localmente
      final snapshot = await _firestore
          .collection('appointments')
          .get();
      
      print('DEBUG: Fallback encontrou ${snapshot.docs.length} documentos na coleção');
      
      List<AppointmentModel> appointments = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Verificar se é consulta do profissional
        if (data['professionalId'] == professionalId) {
          final appointment = AppointmentModel.fromFirestore(doc);
          
          // Buscar nome do paciente
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(appointment.patientId)
                .get();
            if (userDoc.exists) {
              final userModel = UserModel.fromFirestore(userDoc);
              appointment.patientName = userModel.name;
            }
          } catch (e) {
            print('DEBUG: Erro ao buscar paciente: $e');
          }
          
          appointments.add(appointment);
          print('DEBUG: Fallback - consulta adicionada: ${appointment.subject}');
        }
      }
      
      // Ordenar por data decrescente
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      
      print('DEBUG: Fallback - total de consultas do profissional: ${appointments.length}');
      return appointments;
      
    } catch (error) {
      print('DEBUG: Erro no fallback: $error');
      return [];
    }
  }

  /// Retorna um stream com os agendamentos de hoje para um profissional.
  Stream<List<AppointmentModel>> getTodayProfessionalAppointmentsStream(
      String professionalId) {
    if (professionalId.isEmpty) {
      print('DEBUG: professionalId está vazio');
      return Stream.value([]);
    }

    final now = DateTime.now();
    // Usar UTC para consistência com o salvamento
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    final endOfDay = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

    print('DEBUG: Buscando consultas para profissional: $professionalId');
    print('DEBUG: Data de hoje (local): $now');
    print('DEBUG: Data de hoje (UTC): ${now.toUtc()}');
    print('DEBUG: Início do dia (UTC): $startOfDay');
    print('DEBUG: Fim do dia (UTC): $endOfDay');

    // Método 1: Buscar todas as consultas do profissional (sem restrição de data)
    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .orderBy('dateTime', descending: true)
        .limit(10)
        .snapshots()
        .handleError((error) {
          print('DEBUG: Erro ao buscar consultas: $error');
          print('DEBUG: Verifique as regras de segurança do Firestore');
        })
        .asyncMap((snapshot) async {
      print('DEBUG: Snapshot recebido com ${snapshot.docs.length} documentos');
      
      if (snapshot.docs.isEmpty) {
        print('DEBUG: Nenhuma consulta encontrada para este profissional');
        return <AppointmentModel>[];
      }
      
      // Processar todas as consultas encontradas
      List<AppointmentModel> allAppointments = [];
      for (var doc in snapshot.docs) {
        final appointment = AppointmentModel.fromFirestore(doc);
        print('DEBUG: Processando consulta: ${appointment.subject} às ${appointment.dateTime}');
        
        // Buscar nome do paciente
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(appointment.patientId)
              .get();
          if (userDoc.exists) {
            final userModel = UserModel.fromFirestore(userDoc);
            appointment.patientName = userModel.name;
            print('DEBUG: Paciente encontrado: ${userModel.name}');
          } else {
            print('DEBUG: Paciente não encontrado para ID: ${appointment.patientId}');
          }
        } catch (e) {
          print('DEBUG: Erro ao buscar paciente: $e');
        }
        
        allAppointments.add(appointment);
      }
      
      // Filtrar apenas as consultas de hoje
      final todayAppointments = allAppointments.where((appointment) {
        final appointmentDate = appointment.dateTime;
        final isToday = appointmentDate.year == now.year && 
                       appointmentDate.month == now.month && 
                       appointmentDate.day == now.day;
        print('DEBUG: Consulta ${appointment.subject} é de hoje? $isToday');
        return isToday;
      }).toList();
      
      print('DEBUG: Total de consultas de hoje: ${todayAppointments.length}');
      return todayAppointments;
    });
  }
  
  /// Método alternativo para buscar consultas com tratamento de erro
  Stream<List<AppointmentModel>> getTodayProfessionalAppointmentsStreamSafe(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    print('DEBUG: Safe method - buscando consultas com filtro por profissional');
    
    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Safe method - encontradas ${snapshot.docs.length} consultas');
          
          final appointments = snapshot.docs.map((doc) {
            final appointment = AppointmentModel.fromFirestore(doc);
            print('DEBUG: Safe method - consulta: ${appointment.subject}');
            return appointment;
          }).toList();
          
          // Filtrar por data
          final now = DateTime.now();
          final todayAppointments = appointments.where((appointment) {
            final appointmentDate = appointment.dateTime;
            return appointmentDate.year == now.year && 
                   appointmentDate.month == now.month && 
                   appointmentDate.day == now.day;
          }).toList();
          
          print('DEBUG: Safe method - consultas de hoje: ${todayAppointments.length}');
          return todayAppointments;
        }).handleError((error) {
          print('DEBUG: Safe method - erro: $error');
          print('DEBUG: Safe method - tentando método alternativo');
          // Se falhar, tentar buscar todas e filtrar
          return _getTodayAppointmentsFromAll(professionalId);
        });
  }

  /// Método auxiliar para buscar de todas as consultas e filtrar
  List<AppointmentModel> _getTodayAppointmentsFromAll(String professionalId) {
    print('DEBUG: Método auxiliar - buscando todas as consultas');
    
    // Este método será chamado sincronamente, então precisamos de uma abordagem diferente
    return [];
  }
  
  /// Método de fallback: buscar todas as consultas e filtrar localmente
  Stream<List<AppointmentModel>> getTodayProfessionalAppointmentsFallback(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    print('DEBUG: Usando método fallback para buscar consultas');
    
    return _firestore
        .collection('appointments')
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Fallback - total de documentos na coleção: ${snapshot.docs.length}');
          
          // Filtrar localmente as consultas do profissional
          final professionalAppointments = snapshot.docs
              .where((doc) {
                final data = doc.data();
                return data['professionalId'] == professionalId;
              })
              .map((doc) {
                final appointment = AppointmentModel.fromFirestore(doc);
                print('DEBUG: Fallback - consulta encontrada: ${appointment.subject}');
                return appointment;
              })
              .toList();
          
          print('DEBUG: Fallback - consultas do profissional: ${professionalAppointments.length}');
          
          // Filtrar por data
          final now = DateTime.now();
          final todayAppointments = professionalAppointments.where((appointment) {
            final appointmentDate = appointment.dateTime;
            return appointmentDate.year == now.year && 
                   appointmentDate.month == now.month && 
                   appointmentDate.day == now.day;
          }).toList();
          
          print('DEBUG: Fallback - consultas de hoje: ${todayAppointments.length}');
          return todayAppointments;
        }).handleError((error) {
          print('DEBUG: Fallback - erro: $error');
          return <AppointmentModel>[];
        });
  }
  
  /// Método para visualizar todas as consultas do profissional (fallback)
  Stream<List<AppointmentModel>> getProfessionalAppointmentsFallback(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    print('DEBUG: Usando fallback para visualizar todas as consultas do profissional');
    
    return _firestore
        .collection('appointments')
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Visualizar todas - total de documentos na coleção: ${snapshot.docs.length}');
          
          // Filtrar localmente as consultas do profissional
          final professionalAppointments = snapshot.docs
              .where((doc) {
                final data = doc.data();
                return data['professionalId'] == professionalId;
              })
              .map((doc) {
                final appointment = AppointmentModel.fromFirestore(doc);
                print('DEBUG: Visualizar todas - consulta encontrada: ${appointment.subject}');
                return appointment;
              })
              .toList();
          
          print('DEBUG: Visualizar todas - consultas do profissional: ${professionalAppointments.length}');
          
          // Versão simplificada: usar ID como nome fallback
          for (var appointment in professionalAppointments) {
            appointment.patientName = 'Paciente ${appointment.patientId.substring(0, 8)}';
          }
          
          // Ordenar por data decrescente
          professionalAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          return professionalAppointments;
        })
        .handleError((error) {
          print('DEBUG: Visualizar todas - erro: $error');
          return <AppointmentModel>[];
        });
  }

  /// Método alternativo que busca apenas consultas sem depender de dados externos
  Stream<List<AppointmentModel>> getProfessionalAppointmentsSimple(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    print('DEBUG: Usando método simples para visualizar consultas');
    
    // Buscar apenas as consultas do profissional
    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .snapshots()
        .asyncMap((snapshot) async {
          print('DEBUG: Simples - encontradas ${snapshot.docs.length} consultas');
          
          final appointments = <AppointmentModel>[];
          
          for (final doc in snapshot.docs) {
            final data = doc.data();
            
            // Carregar nome do paciente se não estiver no agendamento
            String? patientName = data['patientName'];
            if (patientName == null || patientName.isEmpty) {
              try {
                final patientDoc = await _firestore.collection('users').doc(data['patientId']).get();
                if (patientDoc.exists) {
                  final patientData = patientDoc.data();
                  patientName = '${patientData?['firstName'] ?? ''} ${patientData?['lastName'] ?? ''}'.trim();
                }
              } catch (e) {
                print('DEBUG: Erro ao carregar nome do paciente: $e');
                patientName = 'Paciente não identificado';
              }
            }
            
            final appointment = AppointmentModel.fromFirestore(doc);
            appointment.patientName = patientName ?? 'Paciente ${appointment.patientId.substring(0, 8)}';
            appointments.add(appointment);
          }
          
          // Ordenar por data decrescente
          appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          print('DEBUG: Processadas ${appointments.length} consultas com nomes');
          return appointments;
        })
        .handleError((error) {
          print('DEBUG: Simples - erro: $error');
          return <AppointmentModel>[];
        });
  }

  /// Retorna um stream com os agendamentos dos últimos 7 dias para o gráfico.
  Stream<List<AppointmentModel>> getAppointmentsForChartStream(
      String professionalId) {
    if (professionalId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: DateTime.now().subtract(
            const Duration(days: 6),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Retorna um stream com todos os agendamentos de um paciente.
  Stream<List<AppointmentModel>> getPatientAppointmentsStream(String patientId) {
    if (patientId.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<AppointmentModel> appointments = [];
      for (var doc in snapshot.docs) {
        final appointment = AppointmentModel.fromFirestore(doc);

        final professionalDoc = await _firestore
            .collection('professionals')
            .doc(appointment.professionalId)
            .get();
        if (professionalDoc.exists) {
          final professionalModel =
              ProfessionalModel.fromFirestore(professionalDoc);
          appointment.professionalName = professionalModel.name;
        }

        appointments.add(appointment);
      }
      return appointments;
    });
  }
}