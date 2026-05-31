import 'package:aura/data/notifications/reminder_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Process-wide singleton — the plugin keeps its own scheduling queue, so
/// constructing more than one instance would double-fire reminders.
final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService());
