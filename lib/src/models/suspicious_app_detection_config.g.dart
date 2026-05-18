// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suspicious_app_detection_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$ScopeTypeEnumMap = {
  ScopeType.sideloadedOnly: 'SIDELOADED_ONLY',
  ScopeType.sideloadedAndSystemExcludeOem: 'SIDELOADED_AND_SYSTEM_EXCLUDE_OEM',
  ScopeType.sideloadedAndOem: 'SIDELOADED_AND_OEM',
  ScopeType.sideloadedAndSystemAndOem: 'SIDELOADED_AND_SYSTEM_AND_OEM',
  ScopeType.all: 'ALL',
};

const _$ReasonModeEnumMap = {
  ReasonMode.all: 'ALL',
  ReasonMode.highestConfidence: 'HIGHEST_CONFIDENCE',
};

ScanScope _$ScanScopeFromJson(Map<String, dynamic> json) => ScanScope(
      scanScope: $enumDecode(_$ScopeTypeEnumMap, json['scanScope']),
      trustedInstallSources: (json['trustedInstallSources'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ScanScopeToJson(ScanScope instance) {
  final val = <String, dynamic>{
    'scanScope': _$ScopeTypeEnumMap[instance.scanScope]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('trustedInstallSources', instance.trustedInstallSources);
  return val;
}

SuspiciousAppDetectionConfig _$SuspiciousAppDetectionConfigFromJson(
        Map<String, dynamic> json) =>
    SuspiciousAppDetectionConfig(
      packageNames: (json['packageNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      hashes:
          (json['hashes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      requestedPermissions: (json['requestedPermissions'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>).map((e) => e as String).toList(),
          )
          .toList(),
      grantedPermissions: (json['grantedPermissions'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>).map((e) => e as String).toList(),
          )
          .toList(),
      scanScope: json['scanScope'] == null
          ? const ScanScope(scanScope: ScopeType.sideloadedOnly)
          : ScanScope.fromJson(json['scanScope'] as Map<String, dynamic>),
      reasonMode:
          $enumDecodeNullable(_$ReasonModeEnumMap, json['reasonMode']) ??
              ReasonMode.highestConfidence,
    );

Map<String, dynamic> _$SuspiciousAppDetectionConfigToJson(
    SuspiciousAppDetectionConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('packageNames', instance.packageNames);
  writeNotNull('hashes', instance.hashes);
  writeNotNull('requestedPermissions', instance.requestedPermissions);
  writeNotNull('grantedPermissions', instance.grantedPermissions);
  val['scanScope'] = instance.scanScope.toJson();
  val['reasonMode'] = _$ReasonModeEnumMap[instance.reasonMode]!;
  return val;
}
