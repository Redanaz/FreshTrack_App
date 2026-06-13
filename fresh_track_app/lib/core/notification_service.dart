import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Placeholder handler for background actions
  print('Background notification action tapped: ${notificationResponse.actionId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Placeholder handler for foreground actions
        print('Foreground notification action tapped: ${notificationResponse.actionId}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> scheduleExpiryAlert(String id, String itemName, DateTime expiryDate) async {
    // Schedule for 2 days before expiry at 9:00 AM
    final scheduledDate = expiryDate.subtract(const Duration(days: 2));
    final alertTime = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, 9, 0);

    if (alertTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id.hashCode,
      'Expiry Alert! 🍎',
      '$itemName is expiring in 2 days. Use it soon!',
      tz.TZDateTime.from(alertTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel', 
          'Expiry Alerts', 
          importance: Importance.max,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('snooze', 'Snooze'),
            AndroidNotificationAction('ate_it', 'I ate this'),
          ],
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showImmediateExpiryAlert(String id, String itemName, int daysLeft) async {
    String title = '';
    String body = '';

    if (daysLeft == 1) {
      title = '🕐 Expiring Soon!';
      body = '$itemName expires TOMORROW. Use it now!';
    } else if (daysLeft == 2) {
      title = '🕐 Expiring Soon!';
      body = '$itemName expires in 2 days. Use it soon!';
    } else if (daysLeft <= 0) {
      title = '⚠️ Expiry Alert!';
      body = '$itemName has already expired! Please check your inventory.';
    } else {
      return;
    }

    await _notifications.show(
      id.hashCode + 1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel',
          'Expiry Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}