# Medicine Reminder

A comprehensive Flutter application designed to help users manage their medication schedules with timely notifications and reminders.

**Note**: Some devices apply system-level battery optimization or background execution policies that may delay or block notifications. Allowing background activity improves reminder reliability.

**Important**: These limitations are controlled by the operating system and are not related to the application logic.


## Project Overview

Medicine Reminder is a cross-platform mobile application built with Flutter that allows users to:
- Add and manage medications with dosage information
- Set specific times for medication reminders
- Receive reliable notifications even when the app is in the background
- Store medication data locally using Hive database
- Enjoy a clean, intuitive Material Design 3 interface
##  Screenshot
<img width="709" height="1600" alt="image" src="https://github.com/user-attachments/assets/82bcb662-f039-442f-8fb0-a121ced5abe0" />

<img width="709" height="1600" alt="image" src="https://github.com/user-attachments/assets/a3f813b9-fd66-4223-831b-79295e420136" />


##  Architecture

The application follows a clean architecture pattern with the following structure:

### Core Components

- **Models**: `Medicine` class with Hive serialization for local storage
- **Providers**: State management using Provider pattern
- **Services**: Background services for notifications, alarms, and data persistence
- **Screens**: UI components for home and medication management

### Key Features

- **Local Data Storage**: Uses Hive for fast, reliable local database
- **Background Notifications**: Implements `flutter_local_notifications` with foreground service
- **Alarm Management**: `android_alarm_manager_plus` for reliable background scheduling
- **Permission Handling**: Comprehensive permission management for notifications
- **Cross-Platform**: Supports Android, iOS, Web, Windows, macOS, and Linux

##  Technology Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Provider 6.1.2
- **Database**: Hive 2.2.3 (local NoSQL)
- **Notifications**: flutter_local_notifications 18.0.1
- **Background Processing**: android_alarm_manager_plus 4.0.3
- **Utilities**: 
  - intl 0.19.0 (date formatting)
  - uuid 4.5.1 (unique identifiers)
  - path_provider 2.1.5 (file system access)
  - permission_handler 11.3.0 (permissions)

##  Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0
  provider: ^6.1.2
  intl: ^0.19.0
  uuid: ^4.5.1
  path_provider: ^2.1.5
  permission_handler: ^11.3.0
  android_alarm_manager_plus: ^4.0.3
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.14
  flutter_lints: ^5.0.0
```

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK compatible with Flutter version
- Android Studio / VS Code with Flutter extensions
- For Android: Android SDK (API level 21+)
- For iOS: Xcode 14.0+ (macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medicine_reminder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

##  Configuration

### Android Setup
1. Open `android/app/src/main/AndroidManifest.xml`
2. Ensure notification permissions are properly configured
3. Configure foreground service permissions for Android 10+

### iOS Setup
1. Open `ios/Runner/Info.plist`
2. Add notification permissions
3. Configure background modes for notifications

## Usage

### Adding Medications
1. Tap the floating action button (+) on the home screen
2. Enter medication name and dosage
3. Select the time for the reminder
4. Save to schedule notifications

### Managing Medications
- View all scheduled medications on the home screen
- Tap on any medication to view details
- Delete medications by swiping or using the delete option

### Testing Notifications
- Use the notification test button in the app bar
- Verify permissions are granted for reliable notifications

## Running the Application

### Development Mode
```bash
flutter run --debug
```

### Release Mode
```bash
flutter run --release
```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

##  Key Features Deep Dive

### Notification System
- **Foreground Service**: Maintains app lifecycle for reliable notifications
- **Periodic Checks**: Ensures notification service remains active
- **Permission Handling**: Graceful fallback when permissions are denied
- **Multiple Channels**: Different notification types for better user experience

### Data Persistence
- **Hive Integration**: Fast, type-safe local storage
- **Automatic Serialization**: Code generation for model classes
- **Offline Support**: Full functionality without internet connection

### Background Processing
- **Alarm Scheduling**: Reliable background alarm management
- **Service Resilience**: Handles device-specific background limitations
- **Cross-Platform**: Different strategies for Android and iOS

## Troubleshooting

### Common Issues

1. **Notifications Not Working**
   - Check notification permissions in device settings
   - Ensure foreground service is running (Android)
   - Verify alarm scheduling permissions

2. **Build Issues**
   - Run `flutter clean` and `flutter pub get`
   - Regenerate Hive files with build_runner
   - Check platform-specific configurations

3. **Background Service Issues**
   - Check battery optimization settings (Android)
   - Verify background app refresh settings (iOS)
   - Ensure proper permissions are granted
   - **Note**: Some devices apply system-level battery optimization or background execution policies that may delay or block notifications. Allowing background activity improves reminder reliability.
   - **Important**: These limitations are controlled by the operating system and are not related to the application logic.

## License

This project is licensed under the GPL-3.0 license - see the LICENSE file for details.

##  Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**Built with using Flutter**

