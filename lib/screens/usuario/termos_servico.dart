import 'package:flutter/material.dart';
import 'package:AURA/utils/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Serviço'),
        backgroundColor: AppTheme.azul13,
        foregroundColor: AppTheme.brancoPrincipal,
      ),
      backgroundColor: AppTheme.brancoPrincipal,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle('1. Introdução'),
            _SectionText(
              'Este documento descreve os termos de uso do aplicativo PlenoNexo. Ao utilizar o serviço, você concorda com estes termos e políticas associadas.',
            ),
            _SectionTitle('2. Coleta e uso de dados'),
            _SectionText(
              'Coletamos dados pessoais e de uso para fornecer e melhorar o serviço. O tratamento segue a legislação aplicável e nossa Política de Privacidade.',
            ),
            _SectionTitle('3. Responsabilidades do usuário'),
            _SectionText(
              'Você se compromete a fornecer informações verdadeiras, manter sua conta segura e usar o serviço de forma adequada.',
            ),
            _SectionTitle('4. Agendamentos e avaliações'),
            _SectionText(
              'Agendamentos e avaliações devem seguir as regras da plataforma. Abusos podem resultar em suspensão de acesso.',
            ),
            _SectionTitle('5. Limitação de responsabilidade'),
            _SectionText(
              'O serviço é fornecido “como está”. Não nos responsabilizamos por indisponibilidade, perdas indiretas ou uso indevido por terceiros.',
            ),
            _SectionTitle('6. Contato'),
            _SectionText(
              'Para dúvidas sobre estes termos, entre em contato pelo suporte informado no aplicativo.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.pretoPrincipal,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: AppTheme.pretoPrincipal, fontSize: 14),
    );
  }
}
