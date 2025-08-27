import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 19);
  }

  // A função agora aceita um Widget genérico para o ícone.
  Widget _buildQuickAccessButton({
    required Widget iconWidget,
    required String label,
  }) {
    return Container(
      width: 110, // Adicionando uma largura para melhor alinhamento
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.azul9,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Usamos o widget do ícone diretamente aqui
          iconWidget,
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.corpoTextoBranco.copyWith(fontSize: 12),
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
    const String userName = "Leandro";

    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CABEÇALHO ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $userName',
                        style: AppTheme.tituloPrincipalPreto.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(color: AppTheme.pretoPrincipal),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.pretoPrincipal,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // --- ACESSO RÁPIDO ---
            Text(
              'Acesso Rápido',
              style: AppTheme.tituloPrincipalNegrito.copyWith(fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppTheme.azul12,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // CORREÇÃO: Todas as chamadas agora usam 'iconWidget' e 'label'.
                        _buildQuickAccessButton(
                          iconWidget: SvgPicture.asset(
                            'assets/icons/iconePessoaCaderno.svg',
                            colorFilter: ColorFilter.mode(
                              AppTheme.brancoPrincipal,
                              BlendMode.srcIn,
                            ),
                            height: 30,
                          ),
                          label: 'Marcar\nConsulta',
                        ),
                        _buildQuickAccessButton(
                          iconWidget: SvgPicture.asset(
                            'assets/icons/iconeDente.svg',
                            colorFilter: ColorFilter.mode(
                              AppTheme.brancoPrincipal,
                              BlendMode.srcIn,
                            ),
                            height: 30,
                          ),
                          label: 'Marcar\nDentista',
                        ),
                        _buildQuickAccessButton(
                          iconWidget: SvgPicture.asset(
                            'assets/icons/iconeMedalha.svg',
                            colorFilter: ColorFilter.mode(
                              AppTheme.brancoPrincipal,
                              BlendMode.srcIn,
                            ),
                            height: 30,
                          ),
                          label: 'Avaliar\nConsultas',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CALENDÁRIO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Data da Próxima Consulta',
                style: AppTheme.tituloPrincipalPreto.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.brancoPrincipal,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.pretoPrincipal,
                      blurRadius: 5,
                      offset: const Offset(0, 0.2),
                    ),
                  ],
                ),
                child: TableCalendar(
                  locale: 'pt_BR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: AppTheme.tituloPrincipal.copyWith(
                      fontSize: 16,
                    ),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: AppTheme.azul1,
        onTap: (index) {},
      ),
    );
  }
}
