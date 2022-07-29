import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/ios/ios_config.dart';

void main() {
  IOSconfig createConfiguration(
      final String? appBundleId, final String? appTeamId) {
    return IOSconfig(appBundleId: appBundleId, appTeamId: appTeamId);
  }

  const String appBundleId = 'appBundleId';
  const String appTeamId = 'appTeamId';

  test('Object should be created', () {
    expect(() => createConfiguration(appBundleId, appTeamId), isNotNull);
  });

  test('Object should not be created', () {
    expect(() => createConfiguration(null, appTeamId), throwsAssertionError);
    expect(() => createConfiguration(appBundleId, null), throwsAssertionError);
    expect(() => createConfiguration(null, null), throwsAssertionError);
  });
}
