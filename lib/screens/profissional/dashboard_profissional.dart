import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import 'dashboards_detalhados.dart';
import 'opcoes_profissional.dart';
import 'editar_informacoes.dart'; // Já importado
import 'visualizar_consultas.dart'; // Import da nova tela

class DashboardProfissional extends StatefulWidget {
  const DashboardProfissional({super.key});

  @override
  State<DashboardProfissional> createState() => _DashboardProfissionalState();
}

class _DashboardProfissionalState extends State<DashboardProfissional> {
  int _selectedIndex = 0; // Home é o primeiro item
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<BarChartGroupData>> _chartDataStream;
  String _professionalName = "...";

  @override
  void initState() {
    super.initState();
    _loadProfessionalName();
    _chartDataStream = _getChartData();
  }

  void _loadProfessionalName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _professionalName = userDoc.data()?['name'] ?? 'Profissional';
        });
      }
    }
  }

  Stream<List<BarChartGroupData>> _getChartData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('agendamentos')
        .where('professionalId', isEqualTo: user.uid)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: DateTime.now().subtract(
            const Duration(days: 6),
          ),
        )
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return _generateEmptyChartData();
          }

          Map<int, int> dailyCounts = {};
          for (var doc in snapshot.docs) {
            final appointment = doc.data();
            final date = (appointment['dateTime'] as Timestamp).toDate();
            final day = date.weekday;
            dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
          }

          final List<Color> barColors = [
            AppTheme.chartPurple,
            AppTheme.chartLightBlue,
            AppTheme.chartGrayBlue,
            AppTheme.chartLightGreen,
            AppTheme.chartDarkGray,
            AppTheme.chartPurple,
            AppTheme.chartLightBlue,
          ];

          return List.generate(6, (index) {
            final day = DateTime.now().subtract(Duration(days: 5 - index));
            final count = dailyCounts[day.weekday]?.toDouble() ?? 0.0;
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
        });
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
                    'Olá, $_professionalName',
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
          Icon(
            Icons.notifications_none,
            color: AppTheme.pretoPrincipal,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        _buildQuickAccessCard(
          icon: Icons.description,
          text: "Visualizar Consultas",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VisualizarConsultasPage(),
              ),
            );
          },
        ),
        _buildQuickAccessCard(
          icon: Icons.edit,
          text: "Editar Informações",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditarInformacoesPage(),
              ),
            );
          },
        ),
      ],
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
              child: StreamBuilder<List<BarChartGroupData>>(
                stream: _chartDataStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Sem dados de consulta para os últimos 6 dias.',
                        style: GoogleFonts.roboto(color: Colors.white70),
                      ),
                    );
                  }

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
                      barGroups: snapshot.data!,
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
            MaterialPageRoute(
              builder: (context) =>
                  OpcoesProfissional(nomeProfissional: _professionalName),
            ),
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
