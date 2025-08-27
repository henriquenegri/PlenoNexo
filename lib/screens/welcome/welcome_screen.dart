import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/screens/profissional/login/login_prof.dart';
import 'package:plenonexo/screens/usuario/login/login_page.dart';
import 'package:plenonexo/utils/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        // Usamos um Padding geral para a tela não ficar colada nas bordas
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- LOGO E NOME DO APP ---
              SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 200),
              const SizedBox(height: 8),
              Text(
                'PlenoNexo',
                textAlign: TextAlign.center,
                style: AppTheme.tituloPrincipalPreto,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.azul13,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- TÍTULO "SEJA BEM-VINDO" ---
                      Column(
                        children: [
                          Text(
                            'SEJA BEM-VINDO',
                            style: AppTheme.tituloPrincipal,
                          ),
                          const SizedBox(height: 2),
                          Divider(
                            color: AppTheme.brancoPrincipal,
                            thickness: 1,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // --- BOTÃO PARA FLUXO DO USUÁRIO ---
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserLoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.azul9,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Busco um profissional para mim ou para alguém que apoio',
                          textAlign: TextAlign.center,
                          style: AppTheme.textoBotaoBranco.copyWith(
                            color: AppTheme.brancoPrincipal,
                          ),
                        ),
                      ),

                      // MUDANÇA 3: Aumentamos o espaço entre os botões.
                      const SizedBox(height: 50.0),

                      // --- BOTÃO PARA FLUXO DO PROFISSIONAL ---
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProfessionalLoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.verde13,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Sou um profissional e quero oferecer meus serviços',
                          textAlign: TextAlign.center,
                          style: AppTheme.textoBotaoBranco,
                        ),
                      ),
                      const SizedBox(height: 70.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
