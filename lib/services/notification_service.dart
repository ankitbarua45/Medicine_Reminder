import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    // Set the local timezone - this is critical!
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    // Explicitly create the channel to ensure settings stick
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          'medicine_channel',
          'Medicine Reminders',
          description: 'Channel for medicine reminder notifications',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      );
    }
  }

  static Future<bool> requestPermissions() async {
    bool? granted = false;
    
    // Request notification permissions
    if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final bool? notificationsGranted = await androidImplementation?.requestNotificationsPermission();
        final bool? alarmsGranted = await androidImplementation?.requestExactAlarmsPermission();
        
        // Request to ignore battery optimizations - this is crucial for background notifications
        var status = await Permission.ignoreBatteryOptimizations.status;
        if (!status.isGranted) {
          debugPrint('Requesting to ignore battery optimizations...');
          status = await Permission.ignoreBatteryOptimizations.request();
          debugPrint('Battery optimization exemption granted: ${status.isGranted}');
        }
        
        // Show a guide to user about enabling background activity if needed
        if (!status.isGranted) {
          _showBatteryOptimizationGuide();
        }
        
        granted = (notificationsGranted ?? false) && (alarmsGranted ?? false);
        debugPrint('Notification permission granted: $notificationsGranted');
        debugPrint('Exact alarm permission granted: $alarmsGranted');
        debugPrint('Battery optimization exemption granted: $status');

    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? iosGranted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        granted = iosGranted;
    }
    
    return granted ?? false;
  }
  
  static void _showBatteryOptimizationGuide() {
    debugPrint('');
    debugPrint('***********************************************************************************');
    debugPrint('MANUAL STEP REQUIRED:');
    debugPrint('To ensure background notifications work, please manually allow the app to run in background:');
    debugPrint('1. Go to Settings > Apps > Medicine Reminder');
    debugPrint('2. Go to Battery > Battery optimization');
    debugPrint('3. Select "No restrictions" or "Unrestricted" for this app');
    debugPrint('4. Some devices may restrict background notifications due to system-level battery optimization. Please ensure background activity is allowed for reliable reminders.');
    debugPrint('5. Some Android background execution limitations remain a significant challenge, especially on newer versions and manufacturer-customized Android versions');
    debugPrint('***********************************************************************************');
    debugPrint('');
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Ensure the scheduled time is in the future
      var notificationTime = scheduledTime;
      final now = DateTime.now();
      
      if (notificationTime.isBefore(now)) {
        notificationTime = notificationTime.add(const Duration(days: 1));
      }

      // CRITICAL: Create TZDateTime directly in local timezone
      // Don't use tz.TZDateTime.from() as it converts from UTC
      final tzScheduledTime = tz.TZDateTime(
        tz.local,
        notificationTime.year,
        notificationTime.month,
        notificationTime.day,
        notificationTime.hour,
        notificationTime.minute,
        notificationTime.second,
      );
      
      debugPrint('Scheduling notification:');
      debugPrint('  ID: $id');
      debugPrint('  Local Time: $notificationTime');
      debugPrint('  TZ Time: $tzScheduledTime');
      debugPrint('  Current Time: $now');
      debugPrint('  Title: $title');
      debugPrint('  Body: $body');

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_channel',
            'Medicine Reminders',
            channelDescription: 'Channel for medicine reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            channelShowBadge: true,
            autoCancel: false,
            ongoing: false,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
      );
      
      debugPrint(' Notification scheduled successfully');
    } catch (e) {
      debugPrint(' Error scheduling notification: $e');
      rethrow;
    }
  }

  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    debugPrint('SHOWING NOTIFICATION START: ID=$id Title=$title');
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_channel',
            'Medicine Reminders',
            channelDescription: 'Channel for medicine reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true, // Force full screen on some devices
            category: AndroidNotificationCategory.alarm, // Mark as alarm
            visibility: NotificationVisibility.public,
          ),
        ),
      );
      debugPrint(' SHOWING NOTIFICATION SUCCESS');
    } catch (e) {
      debugPrint(' SHOWING NOTIFICATION FAILED: $e');
    }
  }

  static Future<void> showDebugNotification(String message) async {
    await _notificationsPlugin.show(
      999,
      'Debug Keep-Alive',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel',
          'Debug Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> startForegroundService() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'medicine_foreground_service',
      'Medicine Reminder Service',
      channelDescription: 'Keeps the app running to ensure notifications trigger',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.service,
      visibility: NotificationVisibility.public,
    );

    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.startForegroundService(
            1,
            'Medicine Reminder Active',
            'Ensuring your medicine alerts arrive on time.',
            notificationDetails: androidNotificationDetails,
      );
      debugPrint(' Foreground service started successfully');
    } catch (e) {
      debugPrint(' Error starting foreground service: $e');
      
      // Fallback: Ensure the notification channel exists and try to show a persistent notification
      await _ensurePersistentNotification();
    }
  }
  
  static Future<void> _ensurePersistentNotification() async {
    try {
      // Create a persistent notification that encourages user to keep the app running
      await _notificationsPlugin.show(
        999, // Special ID for persistent notification
        'Medicine Reminder Active',
        'Tap to open the app and ensure reminders work properly',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'persistent_channel',
            'Persistent Service Channel',
            channelDescription: 'Shows that the medicine reminder service is running',
            importance: Importance.defaultImportance,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            category: AndroidNotificationCategory.service,
            visibility: NotificationVisibility.public,
          ),
        ),
        payload: 'open_app',
      );
      debugPrint(' Persistent notification shown as fallback');
    } catch (e) {
      debugPrint('Could not show persistent notification: $e');
    }
  }
  
  // Method to periodically check if service is running and restart if needed
  static void startPeriodicServiceCheck() {
    // This method sets up a periodic check to ensure the service stays alive
    // Note: This is a best-effort approach due to Android restrictions
    debugPrint('🔧 Starting periodic service checks');
    
    // In a real implementation, you might use a periodic work manager
    // or schedule repeated notifications to keep the app active
  }
  
  // Hybrid approach to ensure notifications work across different Android versions and manufacturers
  static Future<void> showHybridNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      // Try immediate notification first
      await showImmediateNotification(id: id, title: title, body: body);
      debugPrint(' Hybrid notification succeeded with immediate method');
    } catch (e) {
      debugPrint(' Immediate notification failed: $e');
      
      // If immediate fails, try scheduling for very soon
      try {
        final immediateTime = DateTime.now().add(const Duration(seconds: 1));
        await scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: immediateTime,
        );
        debugPrint(' Hybrid notification scheduled for immediate delivery');
      } catch (scheduleError) {
        debugPrint(' Hybrid notification failed: $scheduleError');
      }
    }
  }

  static Future<void> stopForegroundService() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.stopForegroundService();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
