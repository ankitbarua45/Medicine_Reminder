import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/alarm_service.dart';
import 'providers/medicine_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  await HiveService.init();
  await NotificationService.init();
  await AlarmService.init();
  
  // Request permissions - this will show permission dialogs
  final permissionGranted = await NotificationService.requestPermissions();
  print('Notification permissions granted: $permissionGranted');
  
  // Start Foreground Service to keep app alive on aggressive devices
  try {
    await NotificationService.startForegroundService();
    print(' Foreground Service started successfully');

    // DEBUG: Timer to check if Dart stays alive
    /*
    Timer.periodic(const Duration(minutes: 1), (timer) {
      NotificationService.showDebugNotification(
        'App is alive! ${DateTime.now().toString().substring(11, 19)}'
      );
    });
    */
    
  } catch (e) {
    print(' Failed to start Foreground Service: $e');
  }
  
  if (!permissionGranted) {
    print(' Warning: Notification permissions not granted. Notifications may not work.');
  }

  // After services are initialized, reschedule all existing alarms
  try {
    // Load medicines and reschedule alarms
    final medicines = HiveService.getMedicines();
    for (var medicine in medicines) {
      final notificationId = medicine.id.hashCode;
      final title = 'Time for your meds!';
      final body = 'Take ${medicine.name} (${medicine.dosage})';
      
      await AlarmService.scheduleAlarm(
        id: notificationId,
        title: title,
        body: body,
        scheduledTime: medicine.time,
      );
    }
    print(' Rescheduled ${medicines.length} alarms');
    
    // Start periodic service checks to maintain background presence
    NotificationService.startPeriodicServiceCheck();
  } catch (e) {
    print(' Error rescheduling alarms: $e');
  }

  runApp(const MedicineReminderApp());
}

class MedicineReminderApp extends StatelessWidget {
  const MedicineReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicineProvider(),
      child: MaterialApp(
        title: 'Medicine Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.teal,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.teal,
          ).copyWith(
            secondary: Colors.orange,
            // Ensure primary is teal
            primary: Colors.teal,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}