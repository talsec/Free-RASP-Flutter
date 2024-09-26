import 'package:json_annotation/json_annotation.dart';

part 'package_info.g.dart';

@JsonSerializable()
class PackageInfo {
  const PackageInfo({
    required this.packageName,
    this.appIcon,
    this.version,
    this.appName,
    this.installationSource,
  });

  final String packageName;
  final String? appIcon;
  final String? appName;
  final String? version;
  final String? installationSource;

  factory PackageInfo.fromJson(Map<String, dynamic> json) =>
      _$PackageInfoFromJson(json);
}

