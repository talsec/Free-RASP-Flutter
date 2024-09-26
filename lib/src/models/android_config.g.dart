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
          const <String>[],
      blocklistedPackageNames:
          (json['blocklistedPackageNames'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const <String>[],
      blocklistedHashes: (json['blocklistedHashes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      blocklistedPermissions: (json['blocklistedPermissions'] as List<dynamic>?)
              ?.map(
                  (e) => (e as List<dynamic>).map((e) => e as String).toList())
              .toList() ??
          const <List<String>>[[]],
      whitelistedInstallationSources:
          (json['whitelistedInstallationSources'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const <String>[],
    );

Map<String, dynamic> _$AndroidConfigToJson(AndroidConfig instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'signingCertHashes': instance.signingCertHashes,
      'supportedStores': instance.supportedStores,
      'blocklistedPackageNames': instance.blocklistedPackageNames,
      'blocklistedHashes': instance.blocklistedHashes,
      'blocklistedPermissions': instance.blocklistedPermissions,
      'whitelistedInstallationSources': instance.whitelistedInstallationSources,
    };
