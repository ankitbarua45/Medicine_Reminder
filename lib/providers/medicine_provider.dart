import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> _medicines = [];

  List<Medicine> get medicines => _medicines;

  void loadMedicines() {
    _medicines = HiveService.getMedicines();
    _sortMedicines();
    notifyListeners();
  }

  void _sortMedicines() {
    _medicines.sort((a, b) {
      // Compare only time components (hour and minute)
      final aTime = a.time.hour * 60 + a.time.minute;
      final bTime = b.time.hour * 60 + b.time.minute;
      return aTime.compareTo(bTime);
    });
  }

  Future<void> addMedicine({
    required String name,
    required String dosage,
    required DateTime time, // This DateTime contains the scheduled time
  }) async {
    final String id = const Uuid().v4();
    final newMedicine = Medicine(
      id: id,
      name: name,
      dosage: dosage,
      time: time,
    );

    await HiveService.addMedicine(newMedicine);

    final notificationId = id.hashCode;
    final title = 'Time for your meds!';
    final body = 'Take $name ($dosage)';

    // Schedule via AlarmManager (primary method for background execution)
    await AlarmService.scheduleAlarm(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: time,
    );
    
    // flutter_local_notifications serves as backup
    // (Already handled inside AlarmService now)

    loadMedicines();
  }

  Future<void> deleteMedicine(String id) async {
    await HiveService.deleteMedicine(id);
    final notificationId = id.hashCode;
    await NotificationService.cancelNotification(notificationId);
    await AlarmService.cancelAlarm(notificationId);
    loadMedicines();
  }
  
  List<Map<String, dynamic>> getAllScheduledAlarms() {
    List<Map<String, dynamic>> alarms = [];
    for (var medicine in _medicines) {
      final notificationId = medicine.id.hashCode;
      final title = 'Time for your meds!';
      final body = 'Take ${medicine.name} (${medicine.dosage})';
      
      alarms.add({
        'id': notificationId,
        'title': title,
        'body': body,
        'scheduledTime': medicine.time,
      });
    }
    return alarms;
  }
}
