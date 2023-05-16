// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talsec_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TalsecConfig _$TalsecConfigFromJson(Map<String, dynamic> json) => TalsecConfig(
      watcherMail: json['watcherMail'] as String,
      isProd: json['isProd'] as bool? ?? true,
      androidConfig: json['androidConfig'] == null
          ? null
          : AndroidConfig.fromJson(
              json['androidConfig'] as Map<String, dynamic>,
            ),
      iosConfig: json['iosConfig'] == null
          ? null
          : IOSConfig.fromJson(json['iosConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TalsecConfigToJson(TalsecConfig instance) =>
    <String, dynamic>{
      'androidConfig': instance.androidConfig?.toJson(),
      'iosConfig': instance.iosConfig?.toJson(),
      'watcherMail': instance.watcherMail,
      'isProd': instance.isProd,
    };
