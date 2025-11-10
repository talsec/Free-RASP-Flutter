// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talsec_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TalsecConfig _$TalsecConfigFromJson(Map<String, dynamic> json) => TalsecConfig(
      watcherMail: json['watcherMail'] as String,
      isProd: json['isProd'] as bool? ?? true,
      killOnBypass: json['killOnBypass'] as bool? ?? false,
      androidConfig: json['androidConfig'] == null
          ? null
          : AndroidConfig.fromJson(
              json['androidConfig'] as Map<String, dynamic>),
      iosConfig: json['iosConfig'] == null
          ? null
          : IOSConfig.fromJson(json['iosConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TalsecConfigToJson(TalsecConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('androidConfig', instance.androidConfig?.toJson());
  writeNotNull('iosConfig', instance.iosConfig?.toJson());
  val['watcherMail'] = instance.watcherMail;
  val['isProd'] = instance.isProd;
  val['killOnBypass'] = instance.killOnBypass;
  return val;
}
