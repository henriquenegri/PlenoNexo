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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- LOGO E NOME DO APP ---
            SvgPicture.asset(
              'assets/img/logoPlenoNexo.svg', // Certifique-se que o caminho está correto
              height:
                  150, // Aumentei um pouco o logo para preencher melhor o espaço
            ),
            const SizedBox(height: 8),
            Text(
              'PlenoNexo',
              textAlign: TextAlign.center,
              // Usando o estilo de tipografia que definimos
              style: AppTheme.tituloPrincipalNegrito,
            ),
            const SizedBox(height: 40),

            // --- CONTAINER COM OS BOTÕES DE ESCOLHA ---
            // CORREÇÃO: Envolvemos o Padding com o widget Expanded.
            // Isto força o Container a ocupar todo o espaço vertical restante.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  // A altura do container agora é definida pelo Expanded.
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0, // Um padding vertical base
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
                            style: AppTheme.tituloPrincipal, // Estilo do tema
                          ),
                          const SizedBox(
                            height: 2,
                          ), // Espaço reduzido para alinhar com a linha
                          Divider(
                            color: AppTheme.brancoPrincipal.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ],
                      ),

                      // O Spacer agora funciona porque o seu pai (Column -> Container -> Expanded)
                      // tem uma altura bem definida.
                      const Spacer(),

                      // --- BOTÃO PARA FLUXO DO USUÁRIO ---
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserLoginPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          side: BorderSide(color: AppTheme.azul9, width: 2),
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

                      const SizedBox(height: 24.0),

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
                    ],
                  ),
                ),
              ),
            ),
            // Removemos o Spacer de fora, pois o Expanded já faz o trabalho
            // de preencher o espaço de forma mais controlada.
            const SizedBox(
              height: 40,
            ), // Adicionamos um espaço fixo em baixo para respirar
          ],
        ),
      ),
    );
  }
}
