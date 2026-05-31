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

  /// Schedules (or reschedules) the daily reminder for one medication. Cancels
  /// the existing one first so changing the time replaces — not duplicates.
  ///
  /// Only fires for `kind = preventive` rows with a non-null reminderMinutes;
  /// otherwise this is a cancel.
  Future<void> scheduleForMedication(
    Medication med, {
    required String title,
    required String body,
  }) async {
    await init();
    final id = _notificationIdFor(med.id);
    await _plugin.cancel(id);

    final isPreventive = med.kind == MedicationKind.preventive.code;
    final mins = med.reminderMinutes;
    if (!isPreventive || mins == null || med.archived) return;

    final when = _nextDailyInstance(mins);
    const android = AndroidNotificationDetails(
      'preventive_meds_v1',
      'Lembrete de medicação',
      channelDescription: 'Lembretes diários para medicação preventiva',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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
  Future<void> rescheduleAll(
    List<Medication> meds, {
    required String title,
    required String Function(Medication) bodyFor,
  }) async {
    await init();
    await _plugin.cancelAll();
    for (final m in meds) {
      await scheduleForMedication(m, title: title, body: bodyFor(m));
    }
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
}
