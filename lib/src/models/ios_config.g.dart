// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ios_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IOSConfig _$IOSConfigFromJson(Map<String, dynamic> json) => IOSConfig(
      bundleIds:
          (json['bundleIds'] as List<dynamic>).map((e) => e as String).toList(),
      teamId: json['teamId'] as String,
    );

Map<String, dynamic> _$IOSConfigToJson(IOSConfig instance) => <String, dynamic>{
      'bundleIds': instance.bundleIds,
      'teamId': instance.teamId,
    };
