import 'package:flutter/foundation.dart';

/// Information about an installed application.
@immutable
class PackageInfo {
  /// Creates a [PackageInfo].
  const PackageInfo({
    required this.packageName,
    this.appIcon,
    this.appName,
    this.version,
    this.installerStore,
  });

  /// Creates a [PackageInfo] from the map sent by the native platform.
  ///
  /// Throws if the map does not have the expected shape.
  @internal
  factory PackageInfo.fromMap(Map<Object?, Object?> map) {
    return PackageInfo(
      packageName: map['packageName']! as String,
      appIcon: map['appIcon'] as String?,
      appName: map['appName'] as String?,
      version: map['version'] as String?,
      installerStore: map['installerStore'] as String?,
    );
  }

  /// Package name of the application, e.g. `com.example.app`.
  final String packageName;

  /// Application icon as a Base64-encoded PNG.
  ///
  /// Not sent with malware detections; use `Talsec.instance.getAppIcon()`.
  final String? appIcon;

  /// User-visible name of the application.
  final String? appName;

  /// Version code of the application.
  final String? version;

  /// Package name of the store that installed the application.
  final String? installerStore;

  @override
  bool operator ==(Object other) =>
      other is PackageInfo &&
      other.packageName == packageName &&
      other.appIcon == appIcon &&
      other.appName == appName &&
      other.version == version &&
      other.installerStore == installerStore;

  @override
  int get hashCode =>
      Object.hash(packageName, appIcon, appName, version, installerStore);

  @override
  String toString() => 'PackageInfo(packageName: $packageName, '
      'appName: $appName, version: $version, installerStore: $installerStore)';
}
