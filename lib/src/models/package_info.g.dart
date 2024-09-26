// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageInfo _$PackageInfoFromJson(Map<String, dynamic> json) => PackageInfo(
      packageName: json['packageName'] as String,
      appIcon: json['appIcon'] as String?,
      version: json['version'] as String?,
      appName: json['appName'] as String?,
      installationSource: json['installationSource'] as String?,
    );

Map<String, dynamic> _$PackageInfoToJson(PackageInfo instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'appIcon': instance.appIcon,
      'appName': instance.appName,
      'version': instance.version,
      'installationSource': instance.installationSource,
    };
