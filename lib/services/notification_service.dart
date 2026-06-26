import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../app/router.dart';

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

      // iOS Categories setup for action buttons
      final List<DarwinNotificationCategory> categories = [
        DarwinNotificationCategory(
          'rest_reminder_category',
          actions: [
            DarwinNotificationAction.plain(
              'iniciar_descanso',
              'INICIAR DESCANSO DE 30 MINUTOS',
              options: {
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'recordar_tarde',
              'RECUÉRDAMELO MÁS TARDE',
            ),
          ],
        )
      ];

      final DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: categories,
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationResponse(response);
        },
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

  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint('🔔 [NotificationService] Interacción con notificación recibida: ${response.actionId}');
    
    if (response.actionId == 'iniciar_descanso') {
      try {
        appRouter.push('/rest_timer');
      } catch (e) {
        debugPrint('❌ [NotificationService] Error al navegar a rest_timer: $e');
      }
    } else if (response.actionId == 'recordar_tarde') {
      showDelayedNotification(
        id: 9999, // Unique ID for snooze reminder
        title: 'Es hora de tomar un descanso',
        body: '¿Listo para desconectarte? Te lo recordamos ahora.',
        seconds: 1800, // 30 minutes
        isRestReminder: true,
      );
    } else {
      // User tapped the notification itself
      try {
        appRouter.push('/alarm');
      } catch (e) {
        debugPrint('❌ [NotificationService] Error al abrir la pantalla de alarma: $e');
      }
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
      debugPrint('📅 [NotificationService] Fecha y hora local programada: ${scheduledDate.toLocal()}');

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'sleep_alarms',
        'Alarmas de Sueño',
        channelDescription: 'Canal para recordatorios y alarmas de despertador',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
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
      debugPrint('✅ [NotificationService] ¡Alarma de sueño programada nativamente!');
    } catch (e) {
      debugPrint('❌ [NotificationService] Error al programar la notificación: $e');
    }
  }

  Future<void> scheduleRestReminder({
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

      debugPrint('📅 [NotificationService] Programando recordatorio de descanso - ID: $id, Hora: $hour:$minute');

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'rest_reminders',
        'Recordatorios de Descanso',
        channelDescription: 'Canal para alertas de descanso de 30 minutos',
        importance: Importance.max,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(
            'iniciar_descanso',
            'INICIAR DESCANSO DE 30 MINUTOS',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'recordar_tarde',
            'RECUÉRDAMELO MÁS TARDE',
          ),
        ],
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'rest_reminder_category',
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
      debugPrint('✅ [NotificationService] Recordatorio de descanso programado exitosamente!');
    } catch (e) {
      debugPrint('❌ [NotificationService] Error al programar recordatorio de descanso: $e');
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
    bool isRestReminder = false,
  }) async {
    if (kIsWeb) return;
    await init();

    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        isRestReminder ? 'rest_reminders' : 'test_channel',
        isRestReminder ? 'Recordatorios de Descanso' : 'Canal de Prueba',
        channelDescription: isRestReminder
            ? 'Canal para alertas de descanso de 30 minutos'
            : 'Canal para pruebas rápidas de notificaciones',
        importance: Importance.max,
        priority: Priority.high,
        actions: isRestReminder
            ? const [
                AndroidNotificationAction(
                  'iniciar_descanso',
                  'INICIAR DESCANSO DE 30 MINUTOS',
                  showsUserInterface: true,
                ),
                AndroidNotificationAction(
                  'recordar_tarde',
                  'RECUÉRDAMELO MÁS TARDE',
                ),
              ]
            : null,
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: isRestReminder ? 'rest_reminder_category' : null,
      );

      final NotificationDetails platformDetails = NotificationDetails(
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
    bool isRestReminder = false,
  }) async {
    if (kIsWeb) return;
    await init();

    try {
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

      debugPrint('📅 [NotificationService] Programando notificación retrasada para dentro de $seconds segundos');

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        isRestReminder ? 'rest_reminders' : 'test_channel',
        isRestReminder ? 'Recordatorios de Descanso' : 'Canal de Prueba',
        channelDescription: isRestReminder
            ? 'Canal para alertas de descanso de 30 minutos'
            : 'Canal para pruebas rápidas de notificaciones',
        importance: Importance.max,
        priority: Priority.high,
        actions: isRestReminder
            ? const [
                AndroidNotificationAction(
                  'iniciar_descanso',
                  'INICIAR DESCANSO DE 30 MINUTOS',
                  showsUserInterface: true,
                ),
                AndroidNotificationAction(
                  'recordar_tarde',
                  'RECUÉRDAMELO MÁS TARDE',
                ),
              ]
            : null,
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: isRestReminder ? 'rest_reminder_category' : null,
      );

      final NotificationDetails platformDetails = NotificationDetails(
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
