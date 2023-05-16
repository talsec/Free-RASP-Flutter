import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

void main() {
  const packageName = 'packageName';
  const signingHashes = <String>[
    'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0='
  ];

  const appBundleIds = ['appBundleId'];
  const appTeamId = 'appTeamId';

  const watcherMail = 'john@example.com';

  final androidConfig = AndroidConfig(
    packageName: packageName,
    signingCertHashes: signingHashes,
  );

  final iosConfig = IOSConfig(
    bundleIds: appBundleIds,
    teamId: appTeamId,
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
      () => TalsecConfig(
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
      returnsNormally,
    );
  });
}
