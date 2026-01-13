import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';

class HiveService {
  static const String boxName = 'medicines';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicineAdapter());
    await Hive.openBox<Medicine>(boxName);
  }

  static Box<Medicine> getBox() {
    return Hive.box<Medicine>(boxName);
  }

  static Future<void> addMedicine(Medicine medicine) async {
    final box = getBox();
    await box.put(medicine.id, medicine);
  }

  static Future<void> deleteMedicine(String id) async {
    final box = getBox();
    await box.delete(id);
  }

  static List<Medicine> getMedicines() {
    final box = getBox();
    return box.values.toList();
  }
}
