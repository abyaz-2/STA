import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import '../models/subscription.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Notification channel IDs
  static const String _channelId = 'subscription_reminders';
  static const String _channelName = 'Subscription Reminders';
  static const String _channelDesc =
      'Notifies you before a subscription renews';

  // Reminder offsets: 7, 3, 1 day before + 0 = day of billing
  static const List<int> _reminderOffsets = [7, 3, 1, 0];

  // ─── Init ────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    tzData.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);

    // Ask for POST_NOTIFICATIONS permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ─── Schedule ────────────────────────────────────────────────────────────

  /// Schedules push-style local notifications for [sub].
  ///
  /// Fires on the day(s) that are ≥ [sub.reminderDaysBefore] days before
  /// [sub.nextBillingDate], at 09:00 local time on that day.
  ///
  /// Example: reminderDaysBefore = 3 → schedules notifications 7 days and
  /// 3 days before (all offsets ≥ 3 that are still in the future).
  static Future<void> scheduleRenewalReminder(Subscription sub) async {
    // Cancel any existing notifications for this subscription first
    await cancelAllReminders(sub.id);

    final now = DateTime.now();

    for (final offsetDays in _reminderOffsets) {
      // Day-of (0) is always scheduled regardless of reminderDaysBefore.
      // For other offsets, only schedule if offset <= reminderDaysBefore.
      if (offsetDays != 0 && offsetDays > sub.reminderDaysBefore) continue;

      // Compute the reminder date: billing date minus offsetDays at 09:00
      final reminderDate = DateTime(
        sub.nextBillingDate.year,
        sub.nextBillingDate.month,
        sub.nextBillingDate.day,
        9, // 9 AM
        0,
      ).subtract(Duration(days: offsetDays - 0));

      // Skip if in the past
      if (reminderDate.isBefore(now)) continue;

      final tzDate = tz.TZDateTime.from(reminderDate, tz.local);

      // Unique ID per subscription + offset (avoids collisions)
      final notifId = _notifId(sub.id, offsetDays);

      final title = offsetDays == 0
          ? '🚨 ${sub.name} is charging TODAY'
          : '💳 ${sub.name} renews in $offsetDays day${offsetDays == 1 ? '' : 's'}';
      final body = _buildBody(sub, offsetDays);

      await _plugin.zonedSchedule(
        notifId,
        title,
        body,
        tzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(body),
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(
          '[NotificationService] Scheduled "${ sub.name}" reminder: '
          '$offsetDays day(s) before (fires $reminderDate)');
    }
  }

  // ─── Cancel ──────────────────────────────────────────────────────────────

  /// Cancels all reminder notifications for a given subscription [id].
  static Future<void> cancelAllReminders(String id) async {
    for (final offset in _reminderOffsets) {
      await _plugin.cancel(_notifId(id, offset));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Unique integer ID per subscription + offset day combo.
  static int _notifId(String subId, int offsetDays) =>
      (subId + '_$offsetDays').hashCode.abs() % 100000;

  static String _buildBody(Subscription sub, int days) {
    final dueStr =
        '${sub.nextBillingDate.day}/${sub.nextBillingDate.month}/${sub.nextBillingDate.year}';
    final amtStr = '₹${sub.amount.toStringAsFixed(2)}';
    if (days == 0) {
      return '🚨 $amtStr is being charged TODAY ($dueStr). Check your account!';
    }
    if (days == 1) {
      return '$amtStr will be charged tomorrow ($dueStr). Make sure your payment method is ready!';
    }
    return '$amtStr will be charged in $days days ($dueStr). Time to review your subscription.';
  }
}

