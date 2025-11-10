import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plenonexo/services/appointment_service.dart';
import '../../utils/app_theme.dart';
import 'dashboard_profissional.dart';
import 'opcoes_profissional.dart';

class DashboardsDetalhados extends StatefulWidget {
  final String nomeProfissional;

  const DashboardsDetalhados({super.key, this.nomeProfissional = "Dr. Silva"});

  @override
  State<DashboardsDetalhados> createState() => _DashboardsDetalhadosState();
}

class _DashboardsDetalhadosState extends State<DashboardsDetalhados> {
  int _selectedIndex = 1;
  int _touchedIndex = -1;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppointmentService _appointmentService = AppointmentService();

  String get _firstName {
    if (widget.nomeProfissional.isEmpty) {
      return 'Profissional';
    }
    return widget.nomeProfissional.split(' ').first;
  }

  Stream<List<BarChartGroupData>> _getBarChartData() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          Map<int, int> dailyCounts = {
            1: 0,
            2: 0,
            3: 0,
            4: 0,
            5: 0,
          }; // Seg a Sex

          for (var doc in snapshot.docs) {
            final date = (doc.data()['dateTime'] as Timestamp).toDate();
            if (date.weekday >= 1 && date.weekday <= 5) {
              dailyCounts[date.weekday] = (dailyCounts[date.weekday] ?? 0) + 1;
            }
          }

          return List.generate(5, (index) {
            final day = index + 1;
            return _makeBarGroup(
              index,
              dailyCounts[day]!.toDouble(),
              AppTheme.chartColors[index % AppTheme.chartColors.length],
            );
          });
        });
  }

  Stream<Map<String, double>> _getPieChartData() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value({});

    return _firestore
        .collection('appointments')
        .where('professionalId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          Map<String, int> statusCounts = {};
          for (var doc in snapshot.docs) {
            final status = doc.data()['status'] as String? ?? 'Pendente';
            statusCounts[status] = (statusCounts[status] ?? 0) + 1;
          }

          final total = statusCounts.values.fold(
            0,
            (previousValue, item) => previousValue + item,
          );
          if (total == 0) return {};

          return statusCounts.map(
            (key, value) => MapEntry(key, (value / total) * 100),
          );
        });
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendada';
      case 'completed':
        return 'Realizada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final today = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(today);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header fixo
            _buildHeader(screenWidth, formattedDate),

            // Conteúdo principal com scroll
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Gráfico de barras
                      _buildBarChart(),

                      const SizedBox(height: 24),

                      // Gráfico de pizza
                      _buildPieChart(),

                      const SizedBox(height: 24),

                      // Lista de consultas com ações
                      _buildAppointmentsSection(),
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

  Widget _buildAppointmentsSection() {
    final user = _auth.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Consultas", style: AppTheme.tituloPrincipal),
          const SizedBox(height: 8),
          Text(
            "Gerencie suas consultas: confirmar presença ou cancelar",
            style: AppTheme.corpoTextoBranco.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('appointments')
                .where('professionalId', isEqualTo: user.uid)
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma consulta encontrada.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final subject = (data['subject'] as String?) ?? 'Consulta';
                  final status = (data['status'] as String?) ?? 'scheduled';
                  final patientId = (data['patientId'] as String?) ?? '';
                  final ts = data['dateTime'] as Timestamp?;
                  final dateTime = ts?.toDate();
                  final dateStr = dateTime != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
                      : 'Data não disponível';

                  final isCompleted = status == 'completed';
                  final isCancelled = status == 'cancelled';

                  return Card(
                    color: AppTheme.secondaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject,
                                      style:
                                          AppTheme.tituloPrincipalBrancoNegrito,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: AppTheme.corpoTextoBranco,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isCancelled
                                      ? Colors.redAccent
                                      : isCompleted
                                      ? Colors.blueAccent
                                      : Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _translateStatus(status),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            future: patientId.isNotEmpty
                                ? _firestore
                                      .collection('users')
                                      .doc(patientId)
                                      .get()
                                : null,
                            builder: (context, userSnap) {
                              String patientName = 'Paciente';
                              if (userSnap.hasData && userSnap.data!.exists) {
                                final udata = userSnap.data!.data();
                                final firstName =
                                    (udata?['firstName'] as String?) ?? '';
                                final lastName =
                                    (udata?['lastName'] as String?) ?? '';
                                patientName =
                                    ('$firstName $lastName').trim().isEmpty
                                    ? (udata?['name'] as String? ?? 'Paciente')
                                    : '$firstName $lastName';
                              }

                              return Text(
                                'Paciente: $patientName',
                                style: AppTheme.corpoTextoBranco.copyWith(
                                  color: Colors.white70,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (isCompleted || isCancelled)
                                      ? null
                                      : () => _confirmAppointment(doc.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Confirmar'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isCancelled
                                      ? null
                                      : () => _cancelAppointmentByProfessional(
                                          doc.id,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isCancelled
                                      ? null
                                      : () =>
                                            _cancelAppointmentByPatient(doc.id),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Cancelar (Paciente)'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmAppointment(String appointmentId) async {
    try {
      await _appointmentService.updateAppointmentStatus(
        appointmentId,
        'completed',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta confirmada como realizada.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar consulta: $e')),
        );
      }
    }
  }

  void _cancelAppointmentByProfessional(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(
        appointmentId,
        'cancelled_by_professional',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consulta cancelada pelo profissional.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar consulta: $e')),
        );
      }
    }
  }

  void _cancelAppointmentByPatient(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(
        appointmentId,
        'cancelled_by_patient',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta cancelada pelo paciente.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar consulta: $e')),
        );
      }
    }
  }

  Widget _buildHeader(double screenWidth, String formattedDate) {
    return Container(
      height: 80,
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: AppTheme.primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar e nome
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.secondaryGreen,
                child: Text(
                  _firstName.isNotEmpty ? _firstName.substring(0, 1) : 'P',
                  style: AppTheme.tituloPrincipalBrancoNegrito.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Olá, $_firstName",
                    style: AppTheme.tituloPrincipalBrancoNegrito.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: AppTheme.corpoTextoBranco.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          // Ícone de notificação
          Icon(Icons.notifications, color: AppTheme.brancoPrincipal, size: 24),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Consultas por Dia", style: AppTheme.tituloPrincipal),
          const SizedBox(height: 4),
          Text(
            "Quantidade de consultas marcadas por dia da semana",
            style: AppTheme.corpoTextoBranco.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: StreamBuilder<List<BarChartGroupData>>(
              stream: _getBarChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum dado de consulta encontrado.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} consultas',
                            AppTheme.corpoTextoBranco.copyWith(
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final style = GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 10,
                            );
                            const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
                            return Text(days[value.toInt()], style: style);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return const Text('');
                          },
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
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppTheme.secondaryGreen.withAlpha(
                          (255 * 0.3).round(),
                        ),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: snapshot.data!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Status das Consultas", style: AppTheme.tituloPrincipal),
          const SizedBox(height: 4),
          Text(
            "Distribuição de consultas por status",
            style: AppTheme.corpoTextoBranco.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: StreamBuilder<Map<String, double>>(
              stream: _getPieChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum dado de status encontrado.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final data = snapshot.data!;
                final sections = _buildPieChartSections(data);
                final indicators = _buildPieChartIndicators(data);

                return Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: sections,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: indicators,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.corpoTextoBranco),
      ],
    );
  }

  List<Widget> _buildPieChartIndicators(Map<String, double> data) {
    List<Widget> indicators = [];
    int i = 0;
    data.forEach((status, value) {
      indicators.add(
        _buildIndicator(
          _translateStatus(status),
          AppTheme.chartColors[i % AppTheme.chartColors.length],
        ),
      );
      indicators.add(const SizedBox(height: 4));
      i++;
    });
    return indicators;
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    List<PieChartSectionData> sections = [];
    int i = 0;
    data.forEach((status, value) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;

      sections.add(
        PieChartSectionData(
          color: AppTheme.chartColors[i % AppTheme.chartColors.length],
          value: value,
          title: '${value.toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.brancoPrincipal,
          ),
        ),
      );
      i++;
    });
    return sections;
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).round()),
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
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardProfissional()),
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

BarChartGroupData _makeBarGroup(int x, double y, Color color) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        color: color,
        width: 15,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
    ],
  );
}
