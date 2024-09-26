import 'package:freerasp/src/models/package_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suspicious_app_info.g.dart';

@JsonSerializable()
class SuspiciousAppInfo {
  const SuspiciousAppInfo({
    required this.packageInfo,
    required this.reason,
  });

  final PackageInfo packageInfo;
  final String reason;

  factory SuspiciousAppInfo.fromJson(Map<String, dynamic> json) =>
      _$SuspiciousAppInfoFromJson(json);
}
