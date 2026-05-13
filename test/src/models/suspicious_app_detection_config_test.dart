import 'package:flutter_test/flutter_test.dart';
import 'package:freerasp/freerasp.dart';

void main() {
  group('MalwareScanScope', () {
    test('Should create MalwareScanScope instance with required field only',
        () {
      const scope = MalwareScanScope(scanScope: ScopeType.sideloadedOnly);

      expect(scope, isA<MalwareScanScope>());
      expect(scope.scanScope, ScopeType.sideloadedOnly);
      expect(scope.trustedInstallSources, isNull);
    });

    test('Should create MalwareScanScope instance with all fields', () {
      const scope = MalwareScanScope(
        scanScope: ScopeType.all,
        trustedInstallSources: ['com.android.vending'],
      );

      expect(scope.scanScope, ScopeType.all);
      expect(scope.trustedInstallSources, ['com.android.vending']);
    });

    test('Should convert MalwareScanScope to JSON', () {
      const scope = MalwareScanScope(
        scanScope: ScopeType.sideloadedAndOem,
        trustedInstallSources: ['com.android.vending'],
      );

      final json = scope.toJson();

      expect(json['scanScope'], 'SIDELOADED_AND_OEM');
      expect(json['trustedInstallSources'], ['com.android.vending']);
    });

    test('Should omit trustedInstallSources from JSON when null', () {
      const scope = MalwareScanScope(scanScope: ScopeType.sideloadedOnly);

      final json = scope.toJson();

      expect(json.containsKey('trustedInstallSources'), isFalse);
    });

    test('Should create MalwareScanScope instance from JSON', () {
      final json = {
        'scanScope': 'SIDELOADED_AND_SYSTEM_EXCLUDE_OEM',
        'trustedInstallSources': ['com.android.vending'],
      };

      final scope = MalwareScanScope.fromJson(json);

      expect(scope.scanScope, ScopeType.sideloadedAndSystemExcludeOem);
      expect(scope.trustedInstallSources, ['com.android.vending']);
    });

    test('Should create MalwareScanScope instance from JSON without optional',
        () {
      final json = {'scanScope': 'ALL'};

      final scope = MalwareScanScope.fromJson(json);

      expect(scope.scanScope, ScopeType.all);
      expect(scope.trustedInstallSources, isNull);
    });
  });

  group('SuspiciousAppDetectionConfig', () {
    test('Should create instance with defaults when no args provided', () {
      const config = SuspiciousAppDetectionConfig();

      expect(config.packageNames, isNull);
      expect(config.hashes, isNull);
      expect(config.requestedPermissions, isNull);
      expect(config.grantedPermissions, isNull);
      expect(config.malwareScanScope.scanScope, ScopeType.sideloadedOnly);
      expect(config.malwareScanScope.trustedInstallSources, isNull);
      expect(config.reasonMode, ReasonMode.highestConfidence);
    });

    test('Should create instance with all fields populated', () {
      const config = SuspiciousAppDetectionConfig(
        packageNames: ['com.malware.app'],
        hashes: ['abc123'],
        requestedPermissions: [
          ['android.permission.CAMERA'],
        ],
        grantedPermissions: [
          ['android.permission.READ_SMS'],
        ],
        malwareScanScope: MalwareScanScope(scanScope: ScopeType.all),
        reasonMode: ReasonMode.all,
      );

      expect(config.packageNames, ['com.malware.app']);
      expect(config.hashes, ['abc123']);
      expect(config.requestedPermissions, [
        ['android.permission.CAMERA'],
      ]);
      expect(config.grantedPermissions, [
        ['android.permission.READ_SMS'],
      ]);
      expect(config.malwareScanScope.scanScope, ScopeType.all);
      expect(config.reasonMode, ReasonMode.all);
    });

    test('Should always serialize defaults to JSON', () {
      const config = SuspiciousAppDetectionConfig();

      final json = config.toJson();

      expect(json['malwareScanScope'], isA<Map<String, dynamic>>());
      expect(
        (json['malwareScanScope'] as Map<String, dynamic>)['scanScope'],
        'SIDELOADED_ONLY',
      );
      expect(json['reasonMode'], 'HIGHEST_CONFIDENCE');
      expect(json.containsKey('packageNames'), isFalse);
      expect(json.containsKey('hashes'), isFalse);
      expect(json.containsKey('requestedPermissions'), isFalse);
      expect(json.containsKey('grantedPermissions'), isFalse);
    });

    test('Should convert SuspiciousAppDetectionConfig to JSON', () {
      const config = SuspiciousAppDetectionConfig(
        packageNames: ['com.malware.app'],
        hashes: ['abc123'],
        requestedPermissions: [
          ['android.permission.CAMERA'],
        ],
        grantedPermissions: [
          ['android.permission.READ_SMS', 'android.permission.READ_CONTACTS'],
        ],
        malwareScanScope: MalwareScanScope(
          scanScope: ScopeType.sideloadedAndSystemAndOem,
          trustedInstallSources: ['com.android.vending'],
        ),
        reasonMode: ReasonMode.all,
      );

      final json = config.toJson();

      expect(json['packageNames'], ['com.malware.app']);
      expect(json['hashes'], ['abc123']);
      expect(json['requestedPermissions'], [
        ['android.permission.CAMERA'],
      ]);
      expect(json['grantedPermissions'], [
        ['android.permission.READ_SMS', 'android.permission.READ_CONTACTS'],
      ]);
      expect(
        (json['malwareScanScope'] as Map<String, dynamic>)['scanScope'],
        'SIDELOADED_AND_SYSTEM_AND_OEM',
      );
      expect(json['reasonMode'], 'ALL');
    });

    test('Should create from JSON applying defaults for missing fields', () {
      final config = SuspiciousAppDetectionConfig.fromJson({});

      expect(config.packageNames, isNull);
      expect(config.malwareScanScope.scanScope, ScopeType.sideloadedOnly);
      expect(config.reasonMode, ReasonMode.highestConfidence);
    });

    test('Should create SuspiciousAppDetectionConfig from JSON', () {
      final json = {
        'packageNames': ['com.malware.app'],
        'hashes': ['abc123'],
        'requestedPermissions': [
          ['android.permission.CAMERA'],
        ],
        'grantedPermissions': [
          ['android.permission.READ_SMS'],
        ],
        'malwareScanScope': {
          'scanScope': 'SIDELOADED_AND_OEM',
          'trustedInstallSources': ['com.android.vending'],
        },
        'reasonMode': 'ALL',
      };

      final config = SuspiciousAppDetectionConfig.fromJson(json);

      expect(config.packageNames, ['com.malware.app']);
      expect(config.hashes, ['abc123']);
      expect(config.requestedPermissions, [
        ['android.permission.CAMERA'],
      ]);
      expect(config.grantedPermissions, [
        ['android.permission.READ_SMS'],
      ]);
      expect(config.malwareScanScope.scanScope, ScopeType.sideloadedAndOem);
      expect(
        config.malwareScanScope.trustedInstallSources,
        ['com.android.vending'],
      );
      expect(config.reasonMode, ReasonMode.all);
    });

    test('Should round-trip through JSON without loss', () {
      const original = SuspiciousAppDetectionConfig(
        packageNames: ['com.malware.app'],
        hashes: ['abc123'],
        malwareScanScope: MalwareScanScope(
          scanScope: ScopeType.sideloadedAndSystemExcludeOem,
        ),
        reasonMode: ReasonMode.all,
      );

      final restored = SuspiciousAppDetectionConfig.fromJson(original.toJson());

      expect(restored.packageNames, original.packageNames);
      expect(restored.hashes, original.hashes);
      expect(
        restored.malwareScanScope.scanScope,
        original.malwareScanScope.scanScope,
      );
      expect(restored.reasonMode, original.reasonMode);
    });
  });

  group('ScopeType', () {
    test('Should map every value to its wire format string', () {
      const expected = {
        ScopeType.sideloadedOnly: 'SIDELOADED_ONLY',
        ScopeType.sideloadedAndSystemExcludeOem:
            'SIDELOADED_AND_SYSTEM_EXCLUDE_OEM',
        ScopeType.sideloadedAndOem: 'SIDELOADED_AND_OEM',
        ScopeType.sideloadedAndSystemAndOem: 'SIDELOADED_AND_SYSTEM_AND_OEM',
        ScopeType.all: 'ALL',
      };

      for (final entry in expected.entries) {
        final json = MalwareScanScope(scanScope: entry.key).toJson();
        expect(json['scanScope'], entry.value);

        final restored = MalwareScanScope.fromJson({'scanScope': entry.value});
        expect(restored.scanScope, entry.key);
      }
    });
  });

  group('ReasonMode', () {
    test('Should map every value to its wire format string', () {
      const expected = {
        ReasonMode.all: 'ALL',
        ReasonMode.highestConfidence: 'HIGHEST_CONFIDENCE',
      };

      for (final entry in expected.entries) {
        final json =
            SuspiciousAppDetectionConfig(reasonMode: entry.key).toJson();
        expect(json['reasonMode'], entry.value);

        final restored = SuspiciousAppDetectionConfig.fromJson({
          'malwareScanScope': {'scanScope': 'SIDELOADED_ONLY'},
          'reasonMode': entry.value,
        });
        expect(restored.reasonMode, entry.key);
      }
    });
  });
}
