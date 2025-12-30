# freeRASP Example App

This example application demonstrates how to use the freeRASP plugin to protect your Flutter application from various security threats.

## Features

The example app showcases the following freeRASP capabilities:

### Security Status Monitoring
- Real-time security status display showing overall device security
- Visual indicators for secure and compromised states
- Categorized threat detection (App Integrity, Device Security, Runtime Status)

### Threat Detection
The app monitors and displays various security threats including:
- **App Integrity**: App signature verification, obfuscation, unofficial stores, simulator detection, device binding, multi-instance detection
- **Device Security**: Root/jailbreak detection, hooks, secure hardware availability, developer mode, debugger attachment, passcode protection, ADB status, VPN detection
- **Runtime Status**: Screenshot and screen recording detection

### Screen Capture Blocking
- Toggle to enable/disable screen capture blocking
- Prevents screenshots and screen recordings when enabled
- Real-time status indicator

### External ID Management
- Set a custom external ID to enrich security logs
- Useful for uniquely identifying devices in your backend
- Stored via `Talsec.instance.storeExternalId()`

### Malware Detection
- Automatic detection of suspicious apps
- Alert cards showing detected malware
- Detailed view of suspicious applications with app icons and reasons

## Project Structure

```
lib/
├── app/
│   └── app.dart              # Main app widget with theme configuration
├── config/
│   └── talsec_config.dart    # Shared Talsec configuration
├── main.dart                 # App entry point with Talsec initialization
├── models/
│   ├── security_check.dart   # Security check model
│   ├── security_state.dart   # Security state management
│   └── setting_item.dart    # Settings item model
├── providers/
│   ├── external_id_provider.dart      # External ID state management
│   ├── screen_capture_notifier.dart   # Screen capture blocking logic
│   ├── screen_capture_provider.dart   # Screen capture provider
│   ├── security_controller.dart       # Main security monitoring controller
│   └── security_controller_provider.dart # Security controller provider
├── screens/
│   ├── security_screen.dart           # Main security dashboard
│   └── suspicious_apps_screen.dart    # Suspicious apps detail view
├── theme/
│   └── app_theme.dart                 # App theme configuration
└── widgets/
    ├── category_section.dart          # Threat category display
    ├── list_item_card.dart            # Reusable list item widget
    ├── malware_alert_card.dart        # Malware detection alert
    ├── section.dart                   # Section wrapper widget
    ├── security_status_card.dart      # Security status display
    └── settings_section.dart          # Settings section widget
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Setup

1. Clone the repository and navigate to the example directory:
   ```bash
   cd example
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Talsec:
   - Open `lib/config/talsec_config.dart`
   - Update the configuration with your app's details:
     - Android package name
     - Signing certificate hashes
     - Supported app stores
     - iOS bundle IDs and team ID
     - Watcher email address

4. Run the app:
   ```bash
   flutter run
   ```

## Configuration

The Talsec configuration is centralized in `lib/config/talsec_config.dart`. You need to customize:

- **Android Config**:
  - `packageName`: Your app's package name
  - `signingCertHashes`: SHA-256 hashes of your signing certificates
  - `supportedStores`: List of supported app stores
  - `malwareConfig`: Malware detection settings

- **iOS Config**:
  - `bundleIds`: Your app's bundle identifiers
  - `teamId`: Your Apple Developer team ID

- **General**:
  - `watcherMail`: Email for security notifications
  - `isProd`: Set to `true` for production, `false` for development

## Usage Examples

### Monitoring Security Threats

The app automatically monitors threats through the `SecurityController`. Threats are detected via:
- Stream subscription to `Talsec.instance.onThreatDetected`
- Threat callback listeners for malware detection

### Blocking Screen Capture

```dart
// Toggle screen capture blocking
await ref.read(screenCaptureProvider.notifier).toggle();
```

### Setting External ID

```dart
// Set external ID for log enrichment
await ref.read(externalIdProvider.notifier).setExternalId('device-123');
```

## Architecture

The app uses:
- **Riverpod** for state management
- **Material Design 3** with dynamic color theming
- **Provider pattern** for security monitoring
- **Reactive UI** that updates automatically when threats are detected

## Resources

- [freeRASP Documentation](https://github.com/talsec/freerasp)
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
