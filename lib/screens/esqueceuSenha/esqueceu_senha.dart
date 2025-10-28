import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plenonexo/utils/app_theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                // --- BOTÃO DE VOLTAR ---
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

                // --- LOGO E NOME DO APP ---
                SvgPicture.asset('assets/img/NeuroConecta.svg', height: 200),
                const SizedBox(height: 8),
                Text('PlenoNexo', style: AppTheme.tituloPrincipalPreto),
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
                      // --- TÍTULO "Alterar Senha" ---
                      Column(
                        children: [
                          Text(
                            'Alterar Senha',
                            style: AppTheme.tituloPrincipal,
                          ),
                          const SizedBox(height: 2),
                          Divider(
                            color: AppTheme.brancoPrincipal,
                            thickness: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),

                      // --- CAMPOS E BOTÕES ---
                      Text('Email', style: AppTheme.corpoTextoBranco),
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

                      Text('Nova Senha', style: AppTheme.corpoTextoBranco),
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
                      const SizedBox(height: 16),

                      Text(
                        'Confirme a Nova Senha',
                        style: AppTheme.corpoTextoBranco,
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
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () {
                          print('Lógica para trocar a senha...');
                          // TODO: Adicionar lógica de validação e chamada de API
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.azul9,
                          foregroundColor: AppTheme.brancoPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'TROCAR SENHA',
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
    );
  }
}
