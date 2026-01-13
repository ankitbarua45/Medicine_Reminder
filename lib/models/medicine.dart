import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final DateTime time; // We will use the time component of this DateTime

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
  });
}
