import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/talsec_app.dart';

void main() {
  final TalsecConfig config = TalsecConfig(
    androidConfig: AndroidConfig(
      expectedPackageName: 'PACKAGE_NAME',
      expectedSigningCertificateHash:
          'AKoRuyLMM91E7lX/Zqp3u4jMmd0A7hH/Iqozu0TMVd0=',
    ),
    iosConfig: const IOSconfig(
      appBundleId: 'BUNDLE_ID',
      appTeamId: 'TEAM_ID',
    ),
    watcherMail: 'john@example.com',
  );
  const TalsecCallback callback = TalsecCallback();

  test('Passing null values', () {
    expect(() => TalsecApp(config: null, callback: callback),
        throwsAssertionError);
    expect(
        () => TalsecApp(config: config, callback: null), throwsAssertionError);
  });

  test('Passing empty objects', () {
    expect(
        () => TalsecApp(
            config: TalsecConfig(watcherMail: null), callback: callback),
        throwsAssertionError);

    // Callback CAN be unimplemented but at least [TalsecCallback] has to be provided.
    expect(() => TalsecApp(config: config, callback: const TalsecCallback()),
        returnsNormally);
  });
}
