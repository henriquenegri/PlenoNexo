import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/screens/profissional/login/login_prof.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/services/professional_service.dart';
import '../../utils/app_theme.dart';
import 'dashboard_profissional.dart';
import 'dashboards_detalhados.dart';
import 'perfil_profissional.dart';

class OpcoesProfissional extends StatefulWidget {
  const OpcoesProfissional({Key? key}) : super(key: key);

  @override
  State<OpcoesProfissional> createState() => _OpcoesProfissionalState();
}

class _OpcoesProfissionalState extends State<OpcoesProfissional> {
  int _selectedIndex = 2;
  final AuthService _authService = AuthService();
  final ProfessionalService _professionalService = ProfessionalService();
  ProfessionalModel? _currentProfessional;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  Future<void> _loadProfessionalData() async {
    final professional = await _professionalService
        .getCurrentProfessionalData();
    if (mounted) {
      setState(() {
        _currentProfessional = professional;
        _isLoading = false;
      });
    }
  }

  String get _firstName {
    if (_currentProfessional == null || _currentProfessional!.name.isEmpty) {
      return 'Profissional';
    }
    return _currentProfessional!.name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final today = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(today);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                            const SizedBox(height: 24),

                            // Card de opções
                            _buildOptionsCard(),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _isLoading ? null : _buildBottomNavigation(),
    );
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
                child: _firstName.isNotEmpty
                    ? Text(
                        _firstName.substring(0, 1),
                        style: AppTheme.tituloPrincipalBrancoNegrito.copyWith(
                          fontSize: 18,
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white),
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

  Widget _buildOptionsCard() {
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
          Text("Opções", style: AppTheme.tituloPrincipal),
          const SizedBox(height: 16),

          // Opção Perfil
          _buildOptionItem(
            icon: Icons.person,
            label: "Perfil",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PerfilProfissional(),
                ),
              );
            },
          ),

          const Divider(color: AppTheme.secondaryGreen, height: 32),

          // Opção Sair
          _buildOptionItem(
            icon: Icons.exit_to_app,
            label: "Sair do Aplicativo",
            isBold: true,
            onTap: () {
              // Lógica para sair do aplicativo
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "Sair do Aplicativo",
                    style: GoogleFonts.poppins(
                      color: AppTheme.pretoPrincipal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "Tem certeza que deseja sair?",
                    style: GoogleFonts.poppins(color: AppTheme.pretoPrincipal),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancelar",
                        style: GoogleFonts.poppins(
                          color: AppTheme.pretoPrincipal,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                      onPressed: () async {
                        await _authService.signOut();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProfessionalLoginPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      child: Text(
                        "Sair",
                        style: GoogleFonts.poppins(
                          color: AppTheme.brancoPrincipal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isBold = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.brancoPrincipal, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppTheme.brancoPrincipal,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
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
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardProfissional()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardsDetalhados(
                nomeProfissional: _currentProfessional?.name ?? 'Profissional',
              ),
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
