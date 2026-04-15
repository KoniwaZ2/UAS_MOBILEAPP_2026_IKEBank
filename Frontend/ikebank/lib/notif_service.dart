import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initNotification() async {
    if (_initialized) return;

    const initSettingAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initSettingAndroid,
      iOS: initSettingIOS,
    );
    await notificationPlugin.initialize(initializationSettings);
    _initialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily notification channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String title = '',
    String body = '',
  }) async {
    if (!isInitialized) {
      await initNotification();
    }
    await notificationPlugin.show(id, title, body, notificationDetails());
  }
}
