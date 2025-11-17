import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(initSettings);

    // Solicitar permissões onde necessário (Android 13+ e iOS)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Inicializar timezone para uso com zonedSchedule
    tzdata.initializeTimeZones();
    // Tentativa simples de inferência usando nome/offset local
    final inferred = _inferLocalIanaTimezone();
    tz.setLocalLocation(tz.getLocation(inferred ?? 'America/Sao_Paulo'));
  }

  String? _inferLocalIanaTimezone() {
    // Observação: Dart expõe apenas abreviações/offset. Mapeamos casos comuns.
    final name = DateTime.now().timeZoneName.toUpperCase();
    final offset = DateTime.now().timeZoneOffset;
    // Brasil (BRT/BRST) ou offset -03:00
    if (name.contains('BRT') || name.contains('BRST') || offset.inHours == -3) {
      return 'America/Sao_Paulo';
    }
    // GMT-03
    if (name.contains('GMT-3')) {
      return 'America/Sao_Paulo';
    }
    // Você pode expandir com outros mapeamentos se necessário
    return null; // retorna null para usar fallback padrão
  }

  Future<void> scheduleAppointmentReminders({
    required DateTime appointmentDateTime,
    required String professionalName,
  }) async {
    // Ajuste usando timezone local via tz
    final appointmentLocal = appointmentDateTime.toLocal();
    final dayBefore = appointmentLocal.subtract(const Duration(days: 1));
    final thirtyMinutesBefore =
        appointmentLocal.subtract(const Duration(minutes: 30));

    const androidDetails = AndroidNotificationDetails(
      'appointments_channel',
      'Lembretes de Consultas',
      channelDescription: 'Notificações de confirmação e lembretes de consultas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // IDs básicos derivados do timestamp (para evitar colisão)
    final baseId = appointmentLocal.millisecondsSinceEpoch ~/ 1000;

    // Lembrete 1 dia antes
    if (dayBefore.isAfter(DateTime.now())) {
      await _safeZonedSchedule(
        id: baseId + 1,
        title: 'Lembrete de consulta',
        body: 'Você tem consulta amanhã com $professionalName.',
        when: tz.TZDateTime.from(dayBefore, tz.local),
        details: details,
      );
    }

    // Lembrete 30 minutos antes
    if (thirtyMinutesBefore.isAfter(DateTime.now())) {
      await _safeZonedSchedule(
        id: baseId + 2,
        title: 'Lembrete de consulta',
        body: 'Sua consulta com $professionalName começa em 30 minutos.',
        when: tz.TZDateTime.from(thirtyMinutesBefore, tz.local),
        details: details,
      );
    }
  }

  Future<void> showImmediateConfirmation({
    required String professionalName,
    required DateTime appointmentDateTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointments_channel',
      'Lembretes de Consultas',
      channelDescription: 'Notificações de confirmação e lembretes de consultas',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final local = appointmentDateTime.toLocal();
    final formatted = '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} às '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Consulta agendada',
      'Sua consulta com $professionalName foi agendada para $formatted.',
      details,
    );
  }

  // Tenta agendar com modo EXATO; se não for permitido, usa INEXATO como fallback
  Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required NotificationDetails details,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        // Fallback para inexacto quando a permissão de alarmes exatos não está concedida
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          when,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        rethrow;
      }
    }
  }
}