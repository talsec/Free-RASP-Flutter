import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/talsec_app.dart';

void main() {
  const packageName = 'packageName';
  const signingHashes = <String>[
    'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='
  ];

  const appBundleId = 'appBundleId';
  const appTeamId = 'appTeamId';

  const watcherMail = 'john@example.com';

  final androidConfig = AndroidConfig(
    expectedPackageName: packageName,
    expectedSigningCertificateHashes: signingHashes,
  );

  final iosConfig = IOSconfig(
    appBundleId: appBundleId,
    appTeamId: appTeamId,
  );

  test('Provide configuration for each platform', () {
    expect(
      () => TalsecConfig(
        androidConfig: androidConfig,
        watcherMail: watcherMail,
      ),
      returnsNormally,
    );

    expect(
      () =>  TalsecConfig(
        iosConfig: iosConfig,
        watcherMail: watcherMail,
      ),
      returnsNormally,
    );
  });

  test('Provide no configuration at all', () {
    expect(
      () => TalsecConfig(
        watcherMail: watcherMail,
      ),
      throwsAssertionError,
    );
  });

  test('Provide no watcher mail', () {
    expect(
      () => TalsecConfig(
        androidConfig: androidConfig,
        iosConfig: iosConfig,
        watcherMail: null,
      ),
      throwsAssertionError,
    );

    expect(
      () => TalsecConfig(
        androidConfig: androidConfig,
        watcherMail: null,
      ),
      throwsAssertionError,
    );

    expect(
      () => TalsecConfig(
        iosConfig: iosConfig,
        watcherMail: null,
      ),
      throwsAssertionError,
    );
  });
}
