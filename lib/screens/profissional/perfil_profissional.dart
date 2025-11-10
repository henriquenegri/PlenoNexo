import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/services/professional_service.dart';
import '../../utils/app_theme.dart';
import 'dashboard_profissional.dart';
import 'dashboards_detalhados.dart';
import 'editar_informacoes.dart';

class PerfilProfissional extends StatefulWidget {
  const PerfilProfissional({Key? key}) : super(key: key);

  @override
  State<PerfilProfissional> createState() => _PerfilProfissionalState();
}

class _PerfilProfissionalState extends State<PerfilProfissional> {
  int _selectedIndex = 2;
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

                            // Card de perfil
                            _buildProfileCard(),

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

          // Ícone de notificação
          Icon(Icons.notifications, color: AppTheme.brancoPrincipal, size: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
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
          Text("Perfil", style: AppTheme.tituloPrincipal),
          const SizedBox(height: 16),

          // Opção Editar Informações
          _buildOptionItem(
            icon: Icons.edit,
            label: "Editar Informações",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarInformacoesPage(),
                ),
              );
            },
          ),

          const Divider(color: AppTheme.secondaryGreen, height: 32),

          // Opção Excluir Registro
          _buildOptionItem(
            icon: Icons.delete,
            label: "Excluir Registro",
            textColor: AppTheme.vermelho3,
            onTap: () {
              // Lógica para excluir registro
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "Excluir Registro",
                    style: GoogleFonts.montserrat(
                      color: AppTheme.vermelho3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "Esta ação não pode ser desfeita. Tem certeza que deseja excluir seu registro?",
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
                        // Implementar lógica de exclusão
                        Navigator.pop(context);
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
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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