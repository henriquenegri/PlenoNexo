import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:AURA/models/professional_model.dart';
import 'package:AURA/screens/profissional/login/login_prof.dart';
import 'package:AURA/services/auth_service.dart';
import 'package:AURA/services/professional_service.dart';
import '../../utils/app_theme.dart';
import 'dashboard_profissional.dart';
import 'dashboards_detalhados.dart';
import 'perfil_profissional.dart';
import 'package:AURA/screens/welcome/welcome_screen.dart';

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
  String _professionalName = '...';

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
        _professionalName = professional?.name ?? 'Profissional';
        _isLoading = false;
      });
    }
  }

  String get _firstName {
    if (_professionalName.isEmpty || _professionalName == "...") {
      return 'Profissional';
    }
    return _professionalName.split(' ').first;
  }

  Future<void> _deleteAccount() async {
    final professional = _currentProfessional;
    if (professional == null) return;

    try {
      // Primeiro, apaga os dados do Firestore
      await _professionalService.deleteProfessionalAccount(professional.uid);
      // Depois, apaga o usuário da autenticação
      await _authService.deleteUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sua conta foi excluída com sucesso.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        // Redireciona para a tela de login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ProfessionalLoginPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        String message = 'Ocorreu um erro ao excluir sua conta.';
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          message =
              'Esta operação é sensível e requer autenticação recente. Por favor, faça login novamente e tente de novo.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppTheme.vermelho1),
        );
      }
    }
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

          // Ícone removido
          const SizedBox.shrink(),
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

          // Opção Excluir Conta
          _buildOptionItem(
            icon: Icons.delete_forever,
            label: "Excluir Conta",
            textColor: AppTheme.vermelho3,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "Excluir Conta",
                    style: GoogleFonts.montserrat(
                      color: AppTheme.vermelho3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "Esta ação é irreversível e todos os seus dados serão perdidos. Tem certeza que deseja excluir sua conta?",
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
                        backgroundColor: AppTheme.vermelho1,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Fecha o dialog
                        _deleteAccount(); // Chama a função de exclusão
                      },
                      child: Text(
                        "Excluir",
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
                              builder: (context) => const WelcomeScreen(),
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
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? AppTheme.brancoPrincipal, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor ?? AppTheme.brancoPrincipal,
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
    return SafeArea(
      top: false,
      child: Container(
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
