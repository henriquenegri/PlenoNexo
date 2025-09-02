import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/models/user_model.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // Variáveis para guardar os dados do utilizador e o estado de loading
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 19);
    // Chamamos a função para carregar os dados quando a tela inicia
    _loadUserData();
  }

  // Nova função para buscar os dados
  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserData();
    // A verificação 'if (mounted)' garante que o widget ainda está na tela
    // antes de tentarmos atualizar o estado, evitando erros.
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  // MUDANÇA: Criamos um getter para pegar apenas o primeiro nome.
  String get _firstName {
    // Se não houver utilizador ou nome, retorna um valor padrão.
    if (_currentUser == null || _currentUser!.name.isEmpty) {
      return 'Utilizador';
    }
    // Divide o nome completo pelos espaços e pega a primeira parte.
    return _currentUser!.name.split(' ').first;
  }

  Widget _buildQuickAccessButton({
    required Widget iconWidget,
    required String label,
  }) {
    return Container(
      height: 125,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.azul9,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.corpoTextoBranco.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/img/logoPlenoNexo.svg',
                            height: 50,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // MUDANÇA: Usamos o nosso novo getter para o primeiro nome.
                              Text(
                                'Olá, $_firstName',
                                style: AppTheme.tituloPrincipalPreto.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: AppTheme.pretoPrincipal,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.azul13.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: AppTheme.brancoPrincipal,
                                size: 28,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Acesso Rápido',
                        style: AppTheme.tituloPrincipalNegrito.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: AppTheme.azul12,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickAccessButton(
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/iconePessoaCaderno.svg',
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.brancoPrincipal,
                                    BlendMode.srcIn,
                                  ),
                                  height: 45,
                                ),
                                label: 'Marcar\nConsulta',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAccessButton(
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/iconeDente.svg',
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.brancoPrincipal,
                                    BlendMode.srcIn,
                                  ),
                                  height: 45,
                                ),
                                label: 'Marcar\nDentista',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAccessButton(
                                iconWidget: SvgPicture.asset(
                                  'assets/icons/iconeMedalha.svg',
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.brancoPrincipal,
                                    BlendMode.srcIn,
                                  ),
                                  height: 45,
                                ),
                                label: 'Avaliar\nConsultas',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.azul12,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Data da Próxima Consulta',
                              style: AppTheme.tituloPrincipalBrancoNegrito
                                  .copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.brancoPrincipal,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TableCalendar(
                                locale: 'pt_BR',
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: CalendarFormat.month,
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: AppTheme.tituloPrincipal
                                      .copyWith(fontSize: 16),
                                ),
                                calendarStyle: CalendarStyle(
                                  selectedDecoration: BoxDecoration(
                                    color: AppTheme.vermelho1,
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: AppTheme.azul5,
                                    shape: BoxShape.circle,
                                  ),
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
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: AppTheme.pretoPrincipal.withOpacity(0.6),
        selectedItemColor: AppTheme.azul9,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
                AppTheme.pretoPrincipal.withOpacity(0.6),
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/iconeBatimentoCardiaco.svg',
              height: 24,
              colorFilter: ColorFilter.mode(AppTheme.azul9, BlendMode.srcIn),
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
