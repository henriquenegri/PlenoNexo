class I18nUtils {
  /// Normaliza mensagens de motivo de cancelamento para português,
  /// cobrindo entradas antigas em inglês no banco.
  static String localizeCancellationReason(String reason) {
    final lower = reason.toLowerCase();

    // Profissional
    if (lower.contains('cancelled by professional')) {
      return reason.replaceFirst(
        RegExp('(?i)cancelled by professional'),
        'Cancelado pelo profissional',
      );
    }

    // Paciente
    if (lower.contains('cancelled by patient')) {
      return reason.replaceFirst(
        RegExp('(?i)cancelled by patient'),
        'Cancelado pelo paciente',
      );
    }

    // Já em português ou outro formato livre: retorna como está
    return reason;
  }
}