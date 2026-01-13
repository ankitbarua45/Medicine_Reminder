import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medicine_provider.dart';
import '../services/notification_service.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load medicines when screen initializes
    Future.microtask(() =>
        Provider.of<MedicineProvider>(context, listen: false).loadMedicines());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notification',
            onPressed: () async {
              // Test notification to verify permissions
              await NotificationService.showImmediateNotification(
                id: 999,
                title: 'Test Notification',
                body: 'If you see this, notifications are working! 🎉',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Permission Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Enable Alarms & Reminders'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'For notifications to work when the app is closed, you need to:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text('1. Open Android Settings'),
                        Text('2. Go to Apps > Medicine Reminder'),
                        Text('3. Tap "Notifications"'),
                        Text('4. Enable "All notifications"'),
                        SizedBox(height: 12),
                        Text('5. Go back and tap "Alarms & reminders"'),
                        Text('6. Enable "Allow setting alarms and reminders"'),
                        SizedBox(height: 12),
                        Text(
                          'Also disable battery optimization:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Settings > Battery > Battery optimization'),
                        Text('Find Medicine Reminder and set to "Don\'t optimize"'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          if (provider.medicines.isEmpty) {
            return const Center(
              child: Text(
                'No medicines added yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.medicines.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final medicine = provider.medicines[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.medical_services, color: Colors.teal),
                  ),
                  title: Text(
                    medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${medicine.dosage} • ${DateFormat.jm().format(medicine.time)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      // Confirm deletion
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Medicine'),
                          content: const Text(
                              'Are you sure you want to delete this reminder?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.deleteMedicine(medicine.id);
                                Navigator.pop(ctx);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicineScreen(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
