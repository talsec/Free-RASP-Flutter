// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suspicious_app_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuspiciousAppInfo _$SuspiciousAppInfoFromJson(Map<String, dynamic> json) =>
    SuspiciousAppInfo(
      packageInfo:
          PackageInfo.fromJson(json['packageInfo'] as Map<String, dynamic>),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$SuspiciousAppInfoToJson(SuspiciousAppInfo instance) =>
    <String, dynamic>{
      'packageInfo': instance.packageInfo,
      'reason': instance.reason,
    };
