// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AndroidConfig _$AndroidConfigFromJson(Map<String, dynamic> json) =>
    AndroidConfig(
      packageName: json['packageName'] as String,
      signingCertHashes: (json['signingCertHashes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supportedStores: (json['supportedStores'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      malwareConfig: json['malwareConfig'] == null
          ? null
          : MalwareConfig.fromJson(
              json['malwareConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AndroidConfigToJson(AndroidConfig instance) {
  final val = <String, dynamic>{
    'packageName': instance.packageName,
    'signingCertHashes': instance.signingCertHashes,
    'supportedStores': instance.supportedStores,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('malwareConfig', instance.malwareConfig);
  return val;
}
