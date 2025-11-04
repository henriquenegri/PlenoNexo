import 'package:flutter/material.dart';
import 'package:plenonexo/screens/profissional/login/login_prof.dart';
import 'package:plenonexo/screens/usuario/login/login_page.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String userType;

  const ForgotPasswordScreen({super.key, required this.userType});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final (success, message) = await _authService.resetPassword(
      email: _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    final snackBar = SnackBar(
      content: Text(
        success
            ? 'Link para redefinição de senha enviado para o seu email.'
            : message ?? 'Ocorreu um erro.',
      ),
      backgroundColor: success ? Colors.green : Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (success) {
      // Aguarda um pouco para o usuário ler a mensagem e então redireciona
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          // Navegação explícita baseada no tipo de usuário
          if (widget.userType == 'professional') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const ProfessionalLoginPage(),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const UserLoginPage()),
              (route) => false,
            );
          }
        }
      });
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
            child: Form(
              key: _formKey,
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
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Image.asset('assets/img/PlenoNexo.png', height: 200),
                  const SizedBox(height: 8),
                  Text('PlenoNexo', style: AppTheme.tituloPrincipalPreto),
                  const SizedBox(height: 40),
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
                            Text(
                              'Redefinir Senha',
                              style: AppTheme.tituloPrincipal,
                            ),
                            const SizedBox(height: 2),
                            Divider(
                              color: AppTheme.brancoPrincipal,
                              thickness: 1,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        Text(
                          'Insira o seu email para enviarmos um link de redefinição de senha.',
                          style: AppTheme.corpoTextoBranco,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),
                        Text('Email', style: AppTheme.corpoTextoBranco),
                        const SizedBox(height: 8),
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
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Por favor, insira um email válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _sendResetLink,
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
                                  'ENVIAR LINK',
                                  style: AppTheme.textoBotaoBranco,
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
      ),
    );
  }
}
