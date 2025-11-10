import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plenonexo/services/appointment_service.dart';
import 'package:plenonexo/services/professional_service.dart'; // Corrigido
import '../../utils/app_theme.dart';
import 'dashboards_detalhados.dart';
import 'opcoes_profissional.dart';
import 'editar_informacoes.dart';
import 'consultas_profissional.dart';
import 'package:plenonexo/debug_firestore.dart';

class DashboardProfissional extends StatefulWidget {
  const DashboardProfissional({super.key});

  @override
  State<DashboardProfissional> createState() => _DashboardProfissionalState();
}

class _DashboardProfissionalState extends State<DashboardProfissional> {
  int _selectedIndex = 0; // Home é o primeiro item
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppointmentService _appointmentService = AppointmentService();
  final ProfessionalService _professionalService = ProfessionalService(); // Corrigido

  late Stream<List<AppointmentModel>> _todayAppointmentsStream;
  late Stream<List<AppointmentModel>> _chartDataStream;
  String _professionalName = "...";

  @override
  void initState() {
    super.initState();
    print('=== DEBUG initState ===');
    _loadProfessionalName();
    final user = _auth.currentUser;
    print('DEBUG: Usuário atual no initState: ${user?.uid}');
    if (user != null) {
      print('DEBUG: Configurando stream com UID: ${user.uid}');
      // Usar método simples que não depende de queries complexas
      _todayAppointmentsStream = _appointmentService
          .getProfessionalAppointmentsSimple(user.uid)
          .map((appointments) {
            // Filtrar apenas consultas de hoje
            final now = DateTime.now();
            return appointments.where((appointment) {
              final appointmentDate = appointment.dateTime;
              return appointmentDate.year == now.year && 
                     appointmentDate.month == now.month && 
                     appointmentDate.day == now.day;
            }).toList();
          });
      // Usar método seguro para gráficos com fallback
      _chartDataStream = _getSafeChartDataStream(user.uid);
      print('Streams inicializadas com sucesso');
    } else {
      print('DEBUG: Usuário é null, streams vazios');
      _todayAppointmentsStream = Stream.value([]);
      _chartDataStream = Stream.value([]);
    }
  }

  void _loadProfessionalName() async {
    // Corrigido para usar ProfessionalService
    final professional = await _professionalService.getCurrentProfessionalData();
    if (mounted && professional != null) {
      setState(() {
        _professionalName = professional.name;
      });
    }
  }

  String get _firstName {
    if (_professionalName.isEmpty || _professionalName == "...") {
      return 'Profissional';
    }
    return _professionalName.split(' ').first;
  }

  List<BarChartGroupData> _generateChartData(List<AppointmentModel> appointments) {
    print('=== DEBUG _generateChartData ===');
    print('Total de consultas recebidas: ${appointments.length}');
    
    if (appointments.isEmpty) {
      print('Lista vazia, retornando gráfico vazio');
      return _generateEmptyChartData();
    }

    Map<int, int> dailyCounts = {};
    for (var appointment in appointments) {
      final day = appointment.dateTime.weekday;
      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      print('Consulta "${appointment.subject}" no weekday $day');
    }

    print('Contagem por weekday: $dailyCounts');

    final List<Color> barColors = [
      AppTheme.chartPurple,
      AppTheme.chartLightBlue,
      AppTheme.chartGrayBlue,
      AppTheme.chartLightGreen,
      AppTheme.chartDarkGray,
      AppTheme.chartPurple,
      AppTheme.chartLightBlue,
    ];

    final result = List.generate(6, (index) {
      final day = DateTime.now().subtract(Duration(days: 5 - index));
      final count = dailyCounts[day.weekday]?.toDouble() ?? 0.0;
      print('Barra $index: dia ${day.weekday} (${DateFormat('dd/MM').format(day)}) -> $count consultas');
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count,
            color: barColors[index % barColors.length],
            width: 15,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
    
    print('Barras geradas: ${result.length}');
    print('=================================');
    
    return result;
  }

  List<BarChartGroupData> _generateEmptyChartData() {
    return List.generate(6, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: 0,
            color: Colors.grey[300],
            width: 15,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Acesso Rápido',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.pretoPrincipal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickAccessSection(),
                      const SizedBox(height: 24),
                      _buildTodayAppointments(),
                      const SizedBox(height: 24),
                      _buildConsultationChart(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business_center, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $_firstName',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.pretoPrincipal,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bug_report, color: Colors.grey, size: 24),
                onPressed: () {
                  print('=== BOTÃO DEBUG PRESSIONADO ===');
                  DebugFirestore.debugProfessionalAppointments();
                },
              ),
              Icon(
                Icons.notifications_none,
                color: AppTheme.pretoPrincipal,
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickAccessCard(
            icon: Icons.show_chart,
            text: "Dashboards",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DashboardsDetalhados(nomeProfissional: _professionalName),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          _buildQuickAccessCard(
              icon: Icons.event_note,
              text: "Visualizar Consultas",
              onTap: _navigateToConsultas,
            ),
          const SizedBox(width: 12),
          _buildQuickAccessCard(
            icon: Icons.person,
            text: "Perfil",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OpcoesProfissional(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final cardSize = (MediaQuery.of(context).size.width - 32 - 32) / 3;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppTheme.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: cardSize,
          height: cardSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                text,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consultas de Hoje',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.pretoPrincipal,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.grey),
              onPressed: () {
                print('DEBUG: Botão de refresh pressionado');
                final user = _auth.currentUser;
                if (user != null) {
                  setState(() {
                    _todayAppointmentsStream = _appointmentService
                        .getTodayProfessionalAppointmentsStream(user.uid);
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: StreamBuilder<List<AppointmentModel>>(
            stream: _todayAppointmentsStream,
            builder: (context, snapshot) {
               // Debug log
               print('=== DEBUG CONSULTAS HOJE ===');
               print('Connection State: ${snapshot.connectionState}');
               print('Has Data: ${snapshot.hasData}');
               print('Has Error: ${snapshot.hasError}');
               if (snapshot.hasError) {
                 print('Error: ${snapshot.error}');
               }
               if (snapshot.hasData) {
                 print('Data Length: ${snapshot.data?.length ?? 0}');
                 if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                   print('First appointment: ${snapshot.data!.first.subject} at ${snapshot.data!.first.dateTime}');
                 }
               }
               print('===========================');
 
                if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'Nenhuma consulta para hoje.',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ),
                );
              }

              final appointments = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final now = DateTime.now();
                  final isPast = appointment.dateTime.isBefore(now);
                  final status = _getAppointmentStatus(appointment, isPast);
                  final statusColor = _getStatusColor(appointment.status, isPast);
                  final statusIcon = _getStatusIcon(appointment.status, isPast);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      appointment.patientName ?? 'Paciente não identificado',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('HH:mm').format(appointment.dateTime),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _translateStatus(status),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationChart() {
    return Card(
      color: AppTheme.primaryGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboards',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quantidade de Consultas Marcadas',
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: StreamBuilder<List<AppointmentModel>>(
                stream: _chartDataStream,
                builder: (context, snapshot) {
                  print('=== DEBUG GRÁFICO ===');
                  print('Connection State: ${snapshot.connectionState}');
                  print('Has Data: ${snapshot.hasData}');
                  print('Has Error: ${snapshot.hasError}');
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    print('Data Length: ${snapshot.data?.length ?? 0}');
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      print('Primeira consulta: ${snapshot.data!.first.subject}');
                    }
                  }
                  print('===========================');
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            color: Colors.white.withOpacity(0.5),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sem dados de consulta para os últimos 6 dias.',
                            style: GoogleFonts.roboto(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'As consultas aparecerão aqui conforme forem agendadas.',
                            style: GoogleFonts.roboto(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final chartData = _generateChartData(snapshot.data!);
                  print('DEBUG: Gráfico gerado com ${chartData.length} barras');

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 90,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final day = DateTime.now().subtract(
                                Duration(days: 5 - value.toInt()),
                              );
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  DateFormat('dd/MM').format(day),
                                  style: GoogleFonts.roboto(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value % 30 == 0) {
                                return Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.roboto(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 28,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 30,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshTodayAppointments() {
    print('DEBUG: Refreshing today appointments');
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _todayAppointmentsStream = _appointmentService
            .getTodayProfessionalAppointmentsStreamSafe(user.uid);
      });
    }
  }

  void _navigateToConsultas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConsultasProfissional(),
      ),
    );
  }

  String _getAppointmentStatus(AppointmentModel appointment, bool isPast) {
    if (appointment.status == 'scheduled') {
      if (isPast) {
        return 'missed'; // Perdido
      } else {
        return 'scheduled'; // Agendada
      }
    }
    return appointment.status;
  }

  Color _getStatusColor(String status, bool isPast) {
    if (status == 'scheduled' && isPast) {
      return Colors.orange; // Perdido
    }
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'missed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status, bool isPast) {
    if (status == 'scheduled' && isPast) {
      return Icons.event_busy;
    }
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.event_available;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'missed':
        return Icons.event_busy;
      default:
        return Icons.help_outline;
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendada';
      case 'completed':
        return 'Realizada';
      case 'cancelled':
        return 'Cancelada';
      case 'missed':
        return 'Perdida';
      default:
        return status;
    }
  }

  /// Método seguro para obter dados do gráfico com fallback
  Stream<List<AppointmentModel>> _getSafeChartDataStream(String professionalId) {
    print('=== DEBUG _getSafeChartDataStream ===');
    print('Professional ID: $professionalId');
    
    return _appointmentService.getAppointmentsForChartStream(professionalId)
        .handleError((error) {
          print('DEBUG: Erro no stream original do gráfico: $error');
          print('DEBUG: Tentando método alternativo');
          // Se falhar, retornar stream vazio para não quebrar o gráfico
          return Stream.value([]);
        })
        .asyncMap((appointments) async {
          print('DEBUG: Processando ${appointments.length} consultas para gráfico');
          
          // Se não houver consultas, tentar método alternativo
          if (appointments.isEmpty) {
            print('DEBUG: Nenhuma consulta encontrada, tentando método alternativo');
            try {
              final fallbackAppointments = await _getChartDataFallback(professionalId);
              print('DEBUG: Método alternativo retornou ${fallbackAppointments.length} consultas');
              return fallbackAppointments;
            } catch (e) {
              print('DEBUG: Método alternativo também falhou: $e');
              return appointments; // Retorna lista vazia
            }
          }
          
          return appointments;
        });
  }

  /// Método de fallback para obter dados do gráfico
  Future<List<AppointmentModel>> _getChartDataFallback(String professionalId) async {
    print('=== DEBUG _getChartDataFallback ===');
    print('Professional ID: $professionalId');
    
    try {
      // Buscar consultas dos últimos 7 dias sem restrições complexas
      final snapshot = await _firestore
          .collection('appointments')
          .where('professionalId', isEqualTo: professionalId)
          .get();
      
      print('DEBUG: Fallback - encontradas ${snapshot.docs.length} consultas no total');
      
      // Filtrar localmente por data
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .where((appointment) => appointment.dateTime.isAfter(sevenDaysAgo))
          .toList();
      
      print('DEBUG: Fallback - ${appointments.length} consultas nos últimos 7 dias');
      return appointments;
    } catch (e) {
      print('DEBUG: Fallback também falhou: $e');
      return [];
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      // Estilo copiado de dashboards_detalhados.dart
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, "Home"),
          _buildNavItem(1, Icons.bar_chart, "Estatísticas"),
          _buildNavItem(2, Icons.person, "Perfil"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        if (_selectedIndex == index) return; // Evita recarregar a mesma tela

        setState(() {
          _selectedIndex = index;
        });

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DashboardsDetalhados(nomeProfissional: _professionalName),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OpcoesProfissional()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.secondaryGreen,
            size: 24,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isSelected
                  ? AppTheme.primaryGreen
                  : AppTheme.secondaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
