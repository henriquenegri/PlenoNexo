import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/utils/app_theme.dart';
// TODO: Adicionar imports para as telas de cadastro e esqueci a senha do profissional

class ProfessionalLoginPage extends StatelessWidget {
  const ProfessionalLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.brancoPrincipal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                // TODO: Adicionar seu SvgPicture aqui
                SvgPicture.asset('assets/img/logoPlenoNexo.svg', height: 200),
                const Text(
                  'PlenoNexo',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pretoPrincipal,
                  ),
                ),
                const SizedBox(height: 40),

                // --- CONTAINER DO FORMULÁRIO ---
                Container(
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
                      // --- TÍTULO "Fazer Login" ---
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppTheme.brancoPrincipal),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Fazer Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppTheme.brancoPrincipal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),

                      // --- CAMPOS E BOTÕES ---
                      const Text(
                        'Email',
                        style: TextStyle(color: AppTheme.brancoPrincipal),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.brancoPrincipal,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Senha',
                        style: TextStyle(color: AppTheme.brancoPrincipal),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.brancoPrincipal,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            print(
                              'Navegar para a tela de esqueci a senha do PROFISSIONAL',
                            );
                            // Navigator.push(... ForgotPasswordScreen(userType: UserType.professional) ...)
                          },
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(color: AppTheme.brancoPrincipal),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () {
                          print(
                            'Lógica de login para PROFISSIONAL. Navegando para o Dashboard do Profissional...',
                          );
                          // Navigator.pushReplacement(... ProfessionalDashboardScreen ...)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.azul9,
                          foregroundColor: AppTheme.brancoPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'REALIZAR LOGIN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Ainda não tem conta? ',
                            style: TextStyle(color: AppTheme.brancoPrincipal),
                          ),
                          TextButton(
                            onPressed: () {
                              print(
                                'Navegando para a tela de cadastro de PROFISSIONAL.',
                              );
                              // Navigator.push(... ProfessionalRegistrationScreen ...)
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'CRIAR CONTA',
                              style: TextStyle(
                                color: AppTheme.brancoPrincipal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
