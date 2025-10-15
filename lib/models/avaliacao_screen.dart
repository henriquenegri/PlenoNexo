import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plenonexo/models/agendamento_model.dart';
import 'package:plenonexo/models/professional_model.dart';
import 'package:plenonexo/services/auth_service.dart';
import 'package:plenonexo/services/review_service.dart';
import 'package:plenonexo/utils/app_theme.dart';

class AvaliacaoScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final ProfessionalModel professional;

  const AvaliacaoScreen({
    super.key,
    required this.appointment,
    required this.professional,
  });

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  final _reviewController = TextEditingController();
  final _reviewService = ReviewService();
  final _authService = AuthService();
  double _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma nota.')),
      );
      return;
    }

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _reviewService.submitReview(
        professionalId: widget.professional.uid,
        patientId: currentUser.uid,
        appointmentId: widget.appointment.id,
        rating: _rating,
        reviewText: _reviewController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação enviada com sucesso!')),
        );
        // Fecha a tela de avaliação e a tela anterior (detalhes do agendamento)
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao enviar avaliação: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Consulta'),
        backgroundColor: AppTheme.azul13,
        foregroundColor: AppTheme.brancoPrincipal,
      ),
      backgroundColor: AppTheme.brancoPrincipal,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Como foi sua consulta com ${widget.professional.name}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.pretoPrincipal,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: AppTheme.verde13),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Deixe um comentário (opcional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.azul13,
                foregroundColor: AppTheme.brancoPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar Avaliação'),
            ),
          ],
        ),
      ),
    );
  }
}
