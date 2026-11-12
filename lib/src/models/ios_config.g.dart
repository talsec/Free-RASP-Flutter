// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ios_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IOSConfig _$IOSConfigFromJson(Map<String, dynamic> json) => IOSConfig(
      appBundleIds: (json['appBundleIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      appTeamId: json['appTeamId'] as String,
    );

Map<String, dynamic> _$IOSConfigToJson(IOSConfig instance) => <String, dynamic>{
      'appBundleIds': instance.appBundleIds,
      'appTeamId': instance.appTeamId,
    };
