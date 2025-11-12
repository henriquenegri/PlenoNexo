import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/screens/usuario/home/home_screem_user.dart';
import 'package:plenonexo/screens/usuario/profile/profile_menu_screen.dart';
import 'package:plenonexo/screens/usuario/rating/professional_rating_screen.dart';
import 'package:plenonexo/screens/welcome/welcome_screen.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/services/user_service.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
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
    setState(() {
      _currentUser = user;
    });
  }

  String _getFirstName() {
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    return _currentUser!.name.split(' ').first;
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        // Navigate to welcome screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A475E),
          title: Text(
            'Sair do Aplicativo',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            'Tem certeza que deseja sair do aplicativo?',
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
                _logout();
              },
              child: Text(
                'Confirmar',
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
            // Header
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
                          color: const Color(
                            0xFF2A475E,
                          ).withAlpha((255 * 0.7).round()),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF2A475E,
                      ).withAlpha((255 * 0.9).round()),
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
                        'Opções',
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
                            // Profile Option
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileMenuScreen(),
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
                                  color: Colors.white.withAlpha(
                                    (255 * 0.1).round(),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(
                                      (255 * 0.2).round(),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Perfil',
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

                            // Logout Option
                            InkWell(
                              onTap: _showLogoutDialog,
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
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Sair do Aplicativo',
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
        unselectedItemColor: const Color(
          0xFF2A475E,
        ).withAlpha((255 * 0.6).round()),
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
              // Already on options screen
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
