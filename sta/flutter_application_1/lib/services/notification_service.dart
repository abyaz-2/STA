import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import '../models/subscription.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzData.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> scheduleRenewalReminder(Subscription sub) async {
    // Spec: notification_date = next_billing_date - 1 day
    final scheduledDate = sub.nextBillingDate.subtract(const Duration(days: 1));
    
    // If it's already in the past, don't schedule
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      sub.id.hashCode,
      'Upcoming Renewal: ${sub.name}',
      'Your ${sub.name} subscription of ₹${sub.amount.toStringAsFixed(2)} is renewing tomorrow!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'renewal_channel',
          'Subscription Renewals',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder(String id) async {
    await _notificationsPlugin.cancel(id.hashCode);
  }
}
