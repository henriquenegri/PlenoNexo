import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import 'dashboard_profissional.dart';
import 'dashboards_detalhados.dart';
import 'opcoes_profissional.dart';

class MainProfissionalScreen extends StatefulWidget {
  final String nomeProfissional;

  const MainProfissionalScreen({Key? key, this.nomeProfissional = "Dr. Silva"})
    : super(key: key);

  @override
  State<MainProfissionalScreen> createState() => _MainProfissionalScreenState();
}

class _MainProfissionalScreenState extends State<MainProfissionalScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardProfissional(),
      DashboardsDetalhados(nomeProfissional: widget.nomeProfissional),
      const OpcoesProfissional(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final today = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(today);

    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(screenWidth, formattedDate),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(double screenWidth, String formattedDate) {
    return Container(
      height: 80,
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: AppTheme.azul13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.azul5,
                child: Text(
                  widget.nomeProfissional.substring(0, 1),
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
                    "Olá, ${widget.nomeProfissional}",
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
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.brancoPrincipal,
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
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.azul5 : AppTheme.azul13,
            size: 24,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isSelected ? AppTheme.azul5 : AppTheme.azul13,
            ),
          ),
        ],
      ),
    );
  }
}
