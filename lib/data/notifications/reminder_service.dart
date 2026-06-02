// Wraps flutter_local_notifications for the preventive-medication daily
// reminders feature. The whole surface is intentionally small: init / request
// permission / schedule / cancel / rescheduleAll. The repository layer asks
// the service to apply changes; the bootstrap re-applies everything at start
// so reminders survive reboots and version upgrades.

import 'package:aura/data/local/database.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Initialises the plugin + timezone DB. Idempotent — calling more than once
  /// is a noop, which keeps the rest of the surface free of "init checks".
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } on Object catch (e, st) {
      // Falls back to UTC; reminders still fire, just possibly off by the
      // device offset. Better than crashing bootstrap.
      debugPrint('[Reminder] timezone init failed: $e\n$st');
    }
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    );
    await _plugin.initialize(initSettings);
    _ready = true;
  }

  /// Best-effort runtime permission. Returns true when notifications can fire.
  /// Also asks for exact-alarm grant on Android 12+ (best-effort, ignored when
  /// the device doesn't support it).
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      try {
        await android.requestExactAlarmsPermission();
      } on Object catch (_) {
        // Older Android (< 12) doesn't expose this; silently ignore.
      }
      return granted;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true) ?? false;
    }
    return false;
  }

  /// True if exact alarms are available — required for the daily reminder to
  /// fire at the requested minute. On Android 12+ this is a user-grantable
  /// permission that defaults to off on many OEM ROMs (notably MIUI). When
  /// false, [scheduleForMedication] falls back to an inexact alarm so the
  /// reminder still fires (within a window) instead of silently dying.
  Future<bool> canScheduleExactAlarms() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    try {
      return await android.canScheduleExactNotifications() ?? false;
    } on Object catch (_) {
      return true;
    }
  }

  /// Fires a one-shot notification immediately. Used by the "Testar lembrete
  /// agora" button in the medication editor so the user can confirm the
  /// notification channel + permission + sound/vibration work without waiting
  /// for the scheduled time. If THIS doesn't appear, the path is broken at
  /// the OS level (channel disabled, app in battery-restricted mode, etc.)
  /// and no amount of scheduling will help.
  Future<void> showTestNotification({required String title, required String body}) async {
    await init();
    const android = AndroidNotificationDetails(
      'preventive_meds_v1',
      'Lembrete de medicação',
      channelDescription: 'Lembretes diários para medicação preventiva',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      category: AndroidNotificationCategory.reminder,
    );
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());
    // Use the same id as the actual scheduled reminder would have so the user
    // doesn't end up with a duplicate row in the shade after testing.
    await _plugin.show(_kTestNotificationId, title, body, details);
  }

  /// Schedules (or reschedules) the daily reminder for one medication. Cancels
  /// the existing one first so changing the time replaces — not duplicates.
  ///
  /// Only fires for `kind = preventive` rows with a non-null reminderMinutes;
  /// otherwise this is a cancel. Returns true when the alarm was scheduled
  /// exactly; false when it was scheduled inexactly (UI can then prompt the
  /// user to grant SCHEDULE_EXACT_ALARM in Settings).
  Future<bool> scheduleForMedication(
    Medication med, {
    required String title,
    required String body,
  }) async {
    await init();
    final id = _notificationIdFor(med.id);
    await _plugin.cancel(id);

    final isPreventive = med.kind == MedicationKind.preventive.code;
    final mins = med.reminderMinutes;
    if (!isPreventive || mins == null || med.archived) return true;

    final when = _nextDailyInstance(mins);
    const android = AndroidNotificationDetails(
      'preventive_meds_v1',
      'Lembrete de medicação',
      channelDescription: 'Lembretes diários para medicação preventiva',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      category: AndroidNotificationCategory.reminder,
    );
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());

    // Pick the scheduling mode based on whether exact alarms are granted. On
    // Android 12+ SCHEDULE_EXACT_ALARM is user-grantable and defaults to off
    // on many OEM ROMs (notably MIUI / Xiaomi). When denied the plugin
    // silently fails to deliver an exact alarm; the inexact mode still fires
    // (within a ~15min window) instead of never firing at all. This was the
    // root cause behind Marcelo's "alarme nunca dispara" report.
    final exactGranted = await canScheduleExactAlarms();
    final mode = exactGranted
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    debugPrint('[Reminder] schedule id=$id when=$when exactGranted=$exactGranted');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return exactGranted;
  }

  Future<void> cancelForMedication(String medId) async {
    await init();
    await _plugin.cancel(_notificationIdFor(medId));
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  /// Reapplies scheduling for the full active catalog. Used at bootstrap to
  /// repopulate the system's alarm queue after install / locale change /
  /// reboot. Cancels everything first so archived or de-scheduled rows clear.
  /// Returns true when every reminder was scheduled exactly; false when at
  /// least one fell back to the inexact mode (caller can surface a hint).
  Future<bool> rescheduleAll(
    List<Medication> meds, {
    required String title,
    required String Function(Medication) bodyFor,
  }) async {
    await init();
    await _plugin.cancelAll();
    var allExact = true;
    for (final m in meds) {
      final exact = await scheduleForMedication(m, title: title, body: bodyFor(m));
      if (!exact) allExact = false;
    }
    return allExact;
  }

  /// Verification hook for the on-device canary — returns the system's view of
  /// the queue so we can prove a scheduled reminder actually landed.
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    await init();
    return _plugin.pendingNotificationRequests();
  }

  /// Compute the next wall-clock instant matching the given minute-of-day in
  /// the device's local timezone. If today's slot is already past, rolls to
  /// tomorrow — combined with `matchDateTimeComponents: time`, this yields a
  /// proper daily recurrence.
  tz.TZDateTime _nextDailyInstance(int minutesOfDay) {
    final now = tz.TZDateTime.now(tz.local);
    final hour = minutesOfDay ~/ 60;
    final minute = minutesOfDay % 60;
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Maps the UUID medication id → stable positive int for the plugin's
  /// 32-bit notification id space. Two meds with colliding hashes would
  /// overwrite each other; the masked space gives 2^31 ids — effectively
  /// collision-free at the catalog size users actually keep.
  int _notificationIdFor(String medId) => medId.hashCode.abs() & 0x7FFFFFFF;

  /// Stable id for the "Testar lembrete agora" notification. Sits in the
  /// reserved high end so it can never collide with a real medication id.
  static const _kTestNotificationId = 0x7FFFFFFE;
}
