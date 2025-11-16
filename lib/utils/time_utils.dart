import 'package:intl/intl.dart';

class BrazilTime {
  static const Duration _brOffset = Duration(hours: -3);

  static DateTime toBrazil(DateTime dt) {
    // Assume timestamps salvos em UTC; converte para fuso de São Paulo (UTC-3)
    return dt.toUtc().add(_brOffset);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('HH:mm').format(toBrazil(dt));
  }

  static String formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(toBrazil(dt));
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat("dd/MM/yyyy 'às' HH:mm").format(toBrazil(dt));
  }
}