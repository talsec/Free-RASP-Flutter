import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/talsec_app.dart';

void main() {
  const String packageName = 'packageName';
  const String signingHash = 'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=';

  const String appBundleId = 'appBundleId';
  const String appTeamId = 'appTeamId';

  const String watcherMail = 'john@example.com';

  final AndroidConfig androidConfig = AndroidConfig(
    expectedPackageName: packageName,
    expectedSigningCertificateHash: signingHash,
  );

  const IOSconfig iosConfig = IOSconfig(
    appBundleId: appBundleId,
    appTeamId: appTeamId,
  );

  test('Provide configuration for each platform', () {
    expect(
        () => TalsecConfig(
            androidConfig: androidConfig,
            iosConfig: null,
            watcherMail: watcherMail),
        returnsNormally);

    expect(
        () => const TalsecConfig(
            androidConfig: null,
            iosConfig: iosConfig,
            watcherMail: watcherMail),
        returnsNormally);
  });

  test('Provide no configuration at all', () {
    expect(
        () => TalsecConfig(
            androidConfig: null, iosConfig: null, watcherMail: watcherMail),
        throwsAssertionError);
  });

  test('Provide no watcher mail', () {
    expect(
        () => TalsecConfig(
            androidConfig: androidConfig,
            iosConfig: iosConfig,
            watcherMail: null),
        throwsAssertionError);

    expect(
        () => TalsecConfig(
            androidConfig: androidConfig, iosConfig: null, watcherMail: null),
        throwsAssertionError);

    expect(
        () => TalsecConfig(
            androidConfig: null, iosConfig: iosConfig, watcherMail: null),
        throwsAssertionError);
  });
}
