import 'package:freerasp/src/models/package_info.dart';
import 'package:meta/meta.dart';

/// An application reported by the malware detection.
@immutable
class SuspiciousAppInfo {
  /// Creates a [SuspiciousAppInfo].
  const SuspiciousAppInfo({
    required this.packageInfo,
    required this.reasons,
    this.permissions,
  });

  /// Creates a [SuspiciousAppInfo] from the map sent by the native platform.
  ///
  /// Throws if the map does not have the expected shape.
  @internal
  factory SuspiciousAppInfo.fromMap(Map<Object?, Object?> map) {
    return SuspiciousAppInfo(
      packageInfo:
          PackageInfo.fromMap(map['packageInfo']! as Map<Object?, Object?>),
      reasons: (map['reasons']! as List<Object?>).cast<String>().toList(),
      permissions:
          (map['permissions'] as List<Object?>?)?.cast<String>().toList(),
    );
  }

  /// The application that was reported.
  final PackageInfo packageInfo;

  /// Why the application was reported, e.g. `blacklist` or `permission`.
  final List<String> reasons;

  /// Permissions of the application that caused the report, if any.
  final List<String>? permissions;

  @override
  bool operator ==(Object other) =>
      other is SuspiciousAppInfo &&
      other.packageInfo == packageInfo &&
      _listEquals(other.reasons, reasons) &&
      _listEquals(other.permissions, permissions);

  @override
  int get hashCode => Object.hash(
        packageInfo,
        Object.hashAll(reasons),
        permissions == null ? null : Object.hashAll(permissions!),
      );

  @override
  String toString() => 'SuspiciousAppInfo(packageInfo: $packageInfo, '
      'reasons: $reasons, permissions: $permissions)';
}

bool _listEquals(List<String>? a, List<String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
