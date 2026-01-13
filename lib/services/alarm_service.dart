import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'notification_service.dart';

class AlarmService {
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
    debugPrint('AlarmService initialized');
  }

  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Calculate time for next occurrence
      final now = DateTime.now();
      var alarmTime = scheduledTime;

      if (alarmTime.isBefore(now)) {
        // If the scheduled time is in the past, schedule for tomorrow
        alarmTime = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day, scheduledTime.hour, scheduledTime.minute);
        alarmTime = alarmTime.add(const Duration(days: 1));
      }

      // Schedule using Android AlarmManager (oneShotAt is reliable)
      await AndroidAlarmManager.oneShotAt(
        alarmTime,
        id,
        alarmCallback, // Use top-level function
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {'title': title, 'body': body, 'id': id},
      );

      debugPrint('Alarm scheduled via AlarmManager for $alarmTime');
      
      // Also schedule via flutter_local_notifications as a backup
      try {
        await NotificationService.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
        );
        debugPrint('Backup notification scheduled via flutter_local_notifications');
      } catch (e) {
        debugPrint('Could not schedule backup notification: $e');
      }
    } catch (e) {
      debugPrint(' Error scheduling alarm: $e');
    }
  }

  static Future<void> cancelAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
  }
  
  static Future<void> rescheduleAllAlarms(List<Map<String, dynamic>> alarms) async {
    for (var alarm in alarms) {
      await scheduleAlarm(
        id: alarm['id'],
        title: alarm['title'],
        body: alarm['body'],
        scheduledTime: alarm['scheduledTime'],
      );
    }
  }
}

// Top-level function for background execution
@pragma('vm:entry-point')
Future<void> alarmCallback(int id, Map<String, dynamic>? params) async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint(' Alarm callback triggered for ID: $id');

  if (params != null) {
    final title = params['title'] as String? ?? 'Medicine Reminder';
    final body = params['body'] as String? ?? 'Time to take your medicine!';
    final notificationId = params['id'] as int? ?? id;

    try {
      // Use hybrid notification approach for better reliability
      await NotificationService.showHybridNotification(
        id: notificationId,
        title: title,
        body: body,
      );
      debugPrint(
        'Notification displayed from background for ID: $notificationId',
      );
    } catch (e, st) {
      debugPrint(' Failed to display notification in background: $e');
      debugPrint(st.toString());
      
      // As a last resort, try to initialize and then show with hybrid approach
      try {
        await NotificationService.init();
        await NotificationService.showHybridNotification(
          id: notificationId,
          title: title,
          body: body,
        );
      } catch (retryError, retrySt) {
        debugPrint(' Retry also failed: $retryError');
        debugPrint(retrySt.toString());
        
        // Final fallback: try to schedule a near-future notification
        try {
          // Schedule notification for 10 seconds from now as a last resort
          final futureTime = DateTime.now().add(const Duration(seconds: 10));
          await NotificationService.scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledTime: futureTime,
          );
          debugPrint('Scheduled immediate fallback notification');
        } catch (finalError, finalSt) {
          debugPrint(' Final fallback also failed: $finalError');
          debugPrint(finalSt.toString());
        }
      }
    }
  } else {
    debugPrint(' No params provided to alarm callback for ID: $id');
  }
}
