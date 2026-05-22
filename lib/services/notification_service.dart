import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb) return; // Not supported on web
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      // Fetch native device local timezone and configure tz.local location
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('🌍 [NotificationService] Huso horario del dispositivo detectado y configurado: $timeZoneName');

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
      );

      // Request notification permissions for Android 13+ (API 33+)
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
      debugPrint('🔔 [NotificationService] Inicializado correctamente.');
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Error al inicializar: $e');
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    await init();

    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      debugPrint('📅 [NotificationService] Programando notificación - ID: $id, Hora: $hour:$minute, Título: "$title"');
      debugPrint('📅 [NotificationService] Fecha y hora local programada: ${scheduledDate.toLocal()} (Timezone local)');

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'meditation_reminders',
        'Recordatorios de Meditación',
        channelDescription: 'Canal para alertas de rutina de meditación',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('✅ [NotificationService] ¡Notificación agendada exitosamente en el sistema nativo!');
    } catch (e) {
      debugPrint('❌ [NotificationService] Error al programar la notificación: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    try {
      debugPrint('🚫 [NotificationService] Cancelando notificación con ID: $id');
      await _notificationsPlugin.cancel(id);
      debugPrint('✅ [NotificationService] Notificación $id cancelada correctamente.');
    } catch (e) {
      debugPrint('❌ [NotificationService] Error al cancelar la notificación: $e');
    }
  }

  /// Triggers a notification immediately
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    await init();

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Canal de Prueba',
        channelDescription: 'Canal para pruebas rápidas de notificaciones',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
      );
      debugPrint('✅ [NotificationService] ¡Notificación inmediata mostrada exitosamente!');
    } catch (e) {
      debugPrint('❌ [NotificationService] Error al mostrar notificación inmediata: $e');
    }
  }

  /// Schedules a notification to fire after a specified number of seconds
  Future<void> showDelayedNotification({
    required int id,
    required String title,
    required String body,
    required int seconds,
  }) async {
    if (kIsWeb) return;
    await init();

    try {
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

      debugPrint('📅 [NotificationService] Programando notificación retrasada para dentro de $seconds segundos (${scheduledDate.toLocal()})');

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Canal de Prueba',
        channelDescription: 'Canal para pruebas rápidas de notificaciones',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ [NotificationService] ¡Notificación retrasada agendada!');
    } catch (e) {
      debugPrint('❌ [NotificationService] Error al programar notificación retrasada: $e');
    }
  }
}
