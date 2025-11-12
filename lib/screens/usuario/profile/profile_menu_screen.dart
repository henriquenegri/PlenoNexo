import 'package:firebase_auth/firebase_auth.dart'; // Importe para tratar exceções
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/screens/usuario/home/home_screem_user.dart';
import 'package:plenonexo/screens/usuario/profile/profile_edit_screen.dart';
import 'package:plenonexo/screens/usuario/rating/professional_rating_screen.dart';
import 'package:plenonexo/screens/welcome/welcome_screen.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/services/user_service.dart';
import 'package:flutter_svg/svg.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  String _getFirstName() {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    return _currentUser!.name.split(' ').first;
  }

  // MÉTODO TRANSFORMADO: De _logout para _deleteAccount
  Future<void> _deleteAccount() async {
    // Garante que o utilizador está carregado
    if (_currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Utilizador não carregado. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final uid = _currentUser!.uid;

    try {
      // 1. Apaga o documento do Firestore
      await _userService.deleteUserAccount(uid);

      // 2. Apaga o utilizador do Firebase Authentication
      //    (currentUserAuth vem do seu AuthService)
      await _authService.currentUserAuth?.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Color(0xFF5E8D6B),
          ),
        );

        // Navega para a tela de boas-vindas
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erro ao excluir conta: $e';
        // Erro comum: O utilizador precisa de ter feito login recentemente
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          errorMessage =
              'Esta operação é sensível. Por favor, faça logout e login novamente antes de excluir a conta.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  // DIÁLOGO ATUALIZADO: para refletir a exclusão
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A475E),
          title: Text(
            'Excluir Conta', // MUDADO
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            // MUDADO
            'Tem certeza que deseja EXCLUIR sua conta? Esta ação é permanente e não pode ser desfeita.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(); // MUDADO (chamando a nova função)
              },
              child: Text(
                'Confirmar Exclusão', // MUDADO
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFFC54B4B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header (sem alterações)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2A475E),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset('assets/img/PlenoNexo.png', height: 60),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFirstName(),
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A475E),
                        ),
                      ),
                      Text(
                        DateTime.now().toString().split(' ')[0],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2A475E).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A475E).withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Perfil',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Options List
                      Expanded(
                        child: Column(
                          children: [
                            // Edit Information Option (sem alterações)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileEditScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Editar Informações',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            InkWell(
                              onTap: _showDeleteAccountDialog,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC54B4B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Deletar Conta',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: const Color(0xFF2A475E).withOpacity(0.6),
        selectedItemColor: const Color(0xFF2A475E),
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const UserHomeScreen()),
                (route) => false,
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessionalRatingScreen(),
                ),
              );
              break;
            case 2:
              // Already on profile menu screen
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/iconeBatimentoCardiaco.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                const Color(0xFF2A475E).withOpacity(0.6),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/iconeBatimentoCardiaco.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                const Color(0xFF2A475E),
                BlendMode.srcIn,
              ),
            ),
            label: 'Consultas',
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
