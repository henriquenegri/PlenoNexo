import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/screens/esqueceuSenha/esqueceu_senha.dart';
import 'package:plenonexo/screens/usuario/cadastro/cadastrar_usuario.dart';
import 'package:plenonexo/screens/usuario/home/home_screem_user.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/utils/app_theme.dart';
import 'package:plenonexo/screens/welcome/welcome_screen.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final AuthService _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // MUDANÇA 5: Função que contém toda a lógica de login
  Future<void> _signIn() async {
    // Validação simples
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha o email e a senha.'),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      expectedRole: 'patient',
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (result == null) {
      // Sucesso!
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        );
      }
    } else {
      // Erro
      if (mounted) {
        // Mostra a mensagem de erro que veio do Firebase
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

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
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppTheme.pretoPrincipal,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
                SvgPicture.asset('assets/img/NeuroConecta.svg', height: 200),
                const SizedBox(height: 8),
                Text('PlenoNexo', style: AppTheme.tituloPrincipalPreto),
                const SizedBox(height: 25),
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
                      Column(
                        children: [
                          Text('Fazer Login', style: AppTheme.tituloPrincipal),
                          const SizedBox(height: 2),
                          Divider(
                            color: AppTheme.brancoPrincipal.withAlpha(128),
                            thickness: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),
                      Text('Email', style: AppTheme.corpoTextoBranco),
                      const SizedBox(height: 8),
                      // MUDANÇA 6: Conectamos o controller ao TextFormField
                      TextFormField(
                        controller: _emailController,
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
                      Text('Senha', style: AppTheme.corpoTextoBranco),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(userType: 'patient'),
                              ),
                            );
                          },
                          child: Text(
                            'Esqueci minha senha',
                            style: AppTheme.corpoTextoClaro,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        // MUDANÇA 7: O botão agora chama a nossa função de lógica
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.azul9,
                          foregroundColor: AppTheme.brancoPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'REALIZAR LOGIN',
                                style: AppTheme.textoBotaoBranco,
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ainda não tem conta? ',
                            style: AppTheme.corpoTextoClaro,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CadastrarUsuario(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'CRIAR CONTA',
                              style: AppTheme.textoBotaoBranco.copyWith(
                                color: AppTheme.brancoPrincipal,
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
