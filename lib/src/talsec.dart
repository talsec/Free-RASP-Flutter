import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/callbacks/rasp_execution_state_callback.dart';
import 'package:freerasp/src/errors/external_id_failure_exception.dart';
import 'package:freerasp/src/errors/malware_failure_exception.dart';
import 'package:freerasp/src/generated/rasp_execution_state.g.dart' as pigeon;
import 'package:freerasp/src/generated/talsec_pigeon_api.g.dart' as pigeon;

/// A class which maintains all security related operations.
///
/// To get started, you can obtain the singleton instance of [Talsec] by
/// calling the [instance] getter. Once you have a reference to the Talsec
/// singleton, you can use it to access the various methods and streams
/// provided by the class.
///
/// ```dart
/// Talsec.instance;
/// ```
///
/// The freeRASP communicates with the Talsec
/// security system using a combination of [MethodChannel]s and [EventChannel]s.
///
/// Note that the Talsec singleton is initialized **lazily**, so it won't be
/// created until it's actually needed. This means that the first time you call
/// the [instance] getter, there may be a short delay while the Talsec
/// singleton is initialized. However, subsequent calls to the instance getter
/// will return the same singleton instance without any additional delay.
class Talsec {
  /// Private constructor for internal and testing purposes.
  @visibleForTesting
  Talsec.private(this.methodChannel, this.eventChannel);

  /// Named channel used to communicate with platform plugins.
  ///
  /// When threat is detected on platform side, [int] is sent which is then
  /// transformed into [Threat] using [ThreatX.fromInt].
  static const EventChannel _eventChannel =
      EventChannel('talsec.app/freerasp/events');

  /// Named channel used to communicate with platform plugins.
  ///
  /// Transforms data and function calls such as [start].
  static const MethodChannel _methodChannel =
      MethodChannel('talsec.app/freerasp/methods');

  /// Private [Talsec] variable which holds current instance of class.
  static final _instance = Talsec.private(_methodChannel, _eventChannel);

  /// Initialize Talsec lazily/obtain current instance of Talsec.
  static Talsec get instance => _instance;

  /// [MethodChannel] used to interact with native platform.
  @visibleForTesting
  late final MethodChannel methodChannel;

  /// [EventChannel] used to receive Threats from the native platform.
  @visibleForTesting
  late final EventChannel eventChannel;

  StreamSubscription<Threat>? _streamSubscription;

  Stream<Threat>? _onThreatDetected;

  /// Returns a broadcast stream. When security is compromised
  /// [onThreatDetected] receives what type of Threat caused it.
  ///
  /// To receive updates about threats, listen to the stream:
  ///
  /// ```dart
  /// final subscription = Talsec.instance.onThreatDetected.listen((threat) {
  ///   // Handle threat
  /// });
  /// ```
  ///
  /// When you're finished listening for threats, don't forget to cancel stream:
  ///
  /// ```dart
  /// subscription.cancel();
  /// ```
  ///
  /// **Implementation note:**
  ///
  /// [onThreatDetected] is internally used by [attachListener] which turns
  /// stream events into function callbacks. While [onThreatDetected] is a
  /// broadcast stream (and hence can have a multiple receivers) it is not
  /// recommended to use both approaches at the same time.
  Stream<Threat> get onThreatDetected {
    if (_onThreatDetected != null) {
      return _onThreatDetected!;
    }

    _onThreatDetected = eventChannel
        .receiveBroadcastStream()
        .cast<int>()
        .map(ThreatX.fromInt)
        .handleError(_handleStreamError);

    return _onThreatDetected!;
  }

  /// Starts freeRASP with configuration provided in [config].
  Future<void> start(TalsecConfig config) {
    _checkConfig(config);
    return methodChannel.invokeMethod(
      'start',
      {'config': jsonEncode(config.toJson())},
    );
  }

  /// Adds [packageName] to the whitelist.
  ///
  /// Once added, the package will be excluded from the list of blocklisted
  /// packages and won't appear in the list of suspicious applications in
  /// the future detections.
  ///
  /// **Adding package is one-way process** - to remove the package from the
  /// whitelist, you need to remove application data or reinstall the
  /// application.
  Future<void> addToWhitelist(String packageName) async {
    if (!Platform.isAndroid) {
      throw UnimplementedError(
        'Platform is not supported: $defaultTargetPlatform}',
      );
    }

    return methodChannel.invokeMethod(
      'addToWhitelist',
      {'packageName': packageName},
    );
  }

  /// Prevents the screen from being captured.
  ///
  /// This method secures current application screen, preventing screenshots
  /// and screen recording. This protection is passive - instead of actively
  /// blocking capture attempts, the captured content to appears black.
  ///
  /// **Limitation:** Behavior may vary across devices and Android
  /// manufacturers.
  ///
  Future<void> blockScreenCapture({required bool enabled}) async {
    try {
      await methodChannel
          .invokeMethod('blockScreenCapture', {'enable': enabled});
    } on PlatformException catch (e) {
      throw Exception('Failed to call block screen capture: ${e.message}');
    }
  }

  /// Checks status of screen capture protection.
  ///
  /// For more details about screen capture protection, see the
  /// [blockScreenCapture] method.
  ///
  /// Returns `true` if screen capture protection is active, `false` otherwise.
  ///
  Future<bool> isScreenCaptureBlocked() async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('isScreenCaptureBlocked');

      if (result is! bool) {
        throw const TalsecException(message: 'Screen capture state failed.');
      }

      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to check screen capture state: ${e.message}');
    }
  }

  /// Sends given [data] to the backend. Each call overwrites data stored in
  /// the backend.
  ///
  /// Throws a [ExternalIdFailureException] when storing failed.
  Future<void> storeExternalId(String data) async {
    try {
      await methodChannel.invokeMethod<void>('storeExternalId', {'data': data});
    } on PlatformException catch (e) {
      throw ExternalIdFailureException.fromPlatformException(e);
    }
  }

  void _checkConfig(TalsecConfig config) {
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (config.androidConfig == null) {
          throw const ConfigurationException(
            message: 'Android config is required for Android platform',
          );
        }
      case TargetPlatform.iOS:
        if (config.iosConfig == null) {
          throw const ConfigurationException(
            message: 'iOS config is required for iOS platform',
          );
        }
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnimplementedError('Platform is not supported');
    }
  }

  /// Attaches instance of [ThreatCallback] to Talsec. If [ThreatCallback] is
  /// already attached, current one will be detached and replaced with
  /// [callback].
  ///
  /// When invoked, functions starts listening to [onThreatDetected] and turns
  /// stream events into function callbacks of [ThreatCallback].
  ///
  /// When threat is detected, respective callback of [ThreatCallback] is
  /// invoked.
  Future<void> attachListener(ThreatCallback callback) async {
    pigeon.TalsecPigeonApi.setUp(callback);

    await detachListener();
    _streamSubscription ??= onThreatDetected.listen((event) {
      switch (event) {
        case Threat.hooks:
          callback.onHooks?.call();
        case Threat.debug:
          callback.onDebug?.call();
        case Threat.passcode:
          callback.onPasscode?.call();
        case Threat.deviceId:
          callback.onDeviceID?.call();
        case Threat.simulator:
          callback.onSimulator?.call();
        case Threat.appIntegrity:
          callback.onAppIntegrity?.call();
        case Threat.obfuscationIssues:
          callback.onObfuscationIssues?.call();
        case Threat.deviceBinding:
          callback.onDeviceBinding?.call();
        case Threat.unofficialStore:
          callback.onUnofficialStore?.call();
        case Threat.privilegedAccess:
          callback.onPrivilegedAccess?.call();
        case Threat.secureHardwareNotAvailable:
          callback.onSecureHardwareNotAvailable?.call();
        case Threat.systemVPN:
          callback.onSystemVPN?.call();
        case Threat.devMode:
          callback.onDevMode?.call();
        case Threat.adbEnabled:
          callback.onADBEnabled?.call();
        case Threat.screenshot:
          callback.onScreenshot?.call();
        case Threat.screenRecording:
          callback.onScreenRecording?.call();
        case Threat.multiInstance:
          callback.onMultiInstance?.call();
        case Threat.unsecureWiFi:
          callback.onUnsecureWiFi?.call();
        case Threat.timeSpoofing:
          callback.onTimeSpoofing?.call();
        case Threat.locationSpoofing:
          callback.onLocationSpoofing?.call();
      }
    });
  }

  /// Removes instance of latest [ThreatCallback]. Also cancels
  /// [StreamSubscription] for that [ThreatCallback].
  ///
  /// If no callback was attached earlier, it has no effect.
  Future<void> detachListener() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void _handleStreamError(Object error) {
    if (error is PlatformException) {
      throw TalsecException.fromPlatformException(error);
    }
    // For any other type of error, rethrow it.
    // ignore: only_throw_errors
    throw error;
  }

  void attachExecutionStateListener(RaspExecutionStateCallback callback) {
    pigeon.RaspExecutionState.setUp(callback);
  }

  void detachExecutionStateListener() {
    pigeon.RaspExecutionState.setUp(null);
  }

  /// Retrieves the app icon for the given [packageName] as base64 string.
  ///
  /// Throws a [TalsecException] with error message description if
  /// the app with given package name couldn't be obtained.
  Future<String> getAppIcon(String packageName) async {
    if (!Platform.isAndroid) {
      throw UnimplementedError(
        'Platform is not supported: $defaultTargetPlatform}',
      );
    }

    try {
      return await _getAppIcon(packageName);
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
    }
  }

  Future<String> _getAppIcon(String packageName) async {
    final args = {'packageName': packageName};
    final result = await methodChannel.invokeMethod<String>('getAppIcon', args);

    if (result is! String) {
      throw const MalwareFailureException(message: 'Malware App icon is null.');
    }

    return result;
  }
}
