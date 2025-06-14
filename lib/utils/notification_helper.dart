import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../data/repositories/debt_repository.dart';

class NotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'debt_channel';
  static const _channelName = 'Debt Notifications';
  static const _channelDescription = 'Notifications for upcoming debt payments';

  static Future<void> init() async {
    tz.initializeTimeZones();
    // Set the local timezone to Asia/Karachi (Pakistan)
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    // Create notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
          ),
        );
  }

  static Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Debug method to show immediate notification
  static Future<void> showTestNotification() async {
    await _plugin.show(
      0,
      'Test Notification',
      'This is a test notification to verify the notification system is working.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<int> scheduleDueDebtNotifications() async {
    final debts = await DebtRepository().fetchDebts();
    final now = tz.TZDateTime.now(tz.local);
    int scheduledCount = 0;

    // Cancel all existing notifications first
    await _plugin.cancelAll();

    for (final debt in debts) {
      // Convert the debt due date to local timezone
      final due = tz.TZDateTime.from(debt.dueDate, tz.local);
      final daysUntilDue = due.difference(now).inDays;

      // Debug print
      print('Debt: ${debt.person}');
      print('Due date (UTC): ${debt.dueDate}');
      print('Due date (Local): $due');
      print('Current time (Local): $now');
      print('Days until due: $daysUntilDue');

      // Schedule notification for debts due within 1 day
      if (daysUntilDue <= 1 && due.isAfter(now)) {
        // Schedule notification for the actual due time
        await NotificationHelper.scheduleNotification(
          id: debt.id.hashCode,
          title: debt.isLoan ? 'Loan Due Soon' : 'Debt Due Soon',
          body:
              'Payment with ${debt.person} is due on ${due.toLocal().toString().split(' ')[0]}.',
          dateTime: due,
        );
        scheduledCount++;
        print('Scheduled notification for debt: ${debt.person}');
      } else {
        print('Not scheduling notification for debt: ${debt.person}');
        print(
            'Reason: ${daysUntilDue <= 1 ? "Due date is not in the future" : "Due date is more than 1 day away"}');
      }
    }

    return scheduledCount;
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    // Convert the input DateTime to TZDateTime in local timezone
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    print('Scheduling notification for: $scheduledDate');
    print('Current time: ${tz.TZDateTime.now(tz.local)}');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
