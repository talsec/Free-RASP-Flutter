import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp/src/generated/talsec_pigeon_api.g.dart' as pigeon;

/// Creates a [Talsec] instance that communicates over the given channels.
///
/// For tests of this package only; it is not exported from
/// `package:freerasp/freerasp.dart`.
@visibleForTesting
Talsec createTalsecForTesting(
  MethodChannel methodChannel,
  EventChannel eventChannel,
  EventChannel executionStateChannel,
) =>
    Talsec._(methodChannel, eventChannel, executionStateChannel);

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
  Talsec._(
    this._methodChannel,
    this._eventChannel,
    this._executionStateChannel,
  );

  /// Named channel used to communicate with platform plugins.
  ///
  /// When threat is detected on platform side, [int] is sent which is then
  /// transformed into [Threat] using [ThreatX.fromInt].
  static const EventChannel _defaultEventChannel =
      EventChannel('talsec.app/freerasp/events');

  /// Named channel used to communicate with platform plugins.
  ///
  /// Transforms data and function calls such as [start].
  static const MethodChannel _defaultMethodChannel =
      MethodChannel('talsec.app/freerasp/methods');

  /// Named channel used to communicate with platform plugins.
  ///
  /// Stream of execution state events.
  static const EventChannel _defaultExecutionStateChannel =
      EventChannel('talsec.app/freerasp/execution_state');

  /// Private [Talsec] variable which holds current instance of class.
  static final _instance = Talsec._(
    _defaultMethodChannel,
    _defaultEventChannel,
    _defaultExecutionStateChannel,
  );

  /// Initialize Talsec lazily/obtain current instance of Talsec.
  static Talsec get instance => _instance;

  /// [MethodChannel] used to interact with native platform.
  final MethodChannel _methodChannel;

  /// [EventChannel] used to receive Threats from the native platform.
  final EventChannel _eventChannel;

  /// [EventChannel] used to receive execution state events from the native
  /// platform.
  final EventChannel _executionStateChannel;

  StreamSubscription<Threat>? _streamSubscription;
  StreamSubscription<RaspExecutionState>? _executionStateSubscription;

  Stream<Threat>? _onThreatDetected;
  Stream<RaspExecutionState>? _onRaspExecutionState;

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

    _onThreatDetected = _eventChannel
        .receiveBroadcastStream()
        .cast<int>()
        .map((code) => _decodeOrAbort(code, ThreatX.fromInt))
        .handleError(_handleStreamError);

    return _onThreatDetected!;
  }

  /// Returns a broadcast stream. When RASP execution state changes
  /// [onRaspExecutionState] receives what state it is.
  Stream<RaspExecutionState> get onRaspExecutionState {
    if (_onRaspExecutionState != null) {
      return _onRaspExecutionState!;
    }

    _onRaspExecutionState = _executionStateChannel
        .receiveBroadcastStream()
        .cast<int>()
        .map((code) => _decodeOrAbort(code, RaspExecutionStateX.fromInt))
        .handleError(_handleStreamError);

    return _onRaspExecutionState!;
  }

  /// Starts freeRASP with configuration provided in [config].
  ///
  /// Throws a [ConfigurationException] when the config for the current
  /// platform is missing, or a [TalsecException] when the start fails.
  Future<void> start(TalsecConfig config) async {
    _checkConfig(config);
    try {
      await _methodChannel.invokeMethod<void>(
        'start',
        {'config': jsonEncode(config.toJson())},
      );
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
    }
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
    _checkAndroid();
    try {
      await _methodChannel.invokeMethod<void>(
        'addToWhitelist',
        {'packageName': packageName},
      );
    } on PlatformException catch (e) {
      throw MalwareFailureException.fromPlatformException(e);
    }
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
      await _methodChannel
          .invokeMethod('blockScreenCapture', {'enable': enabled});
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
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
          await _methodChannel.invokeMethod<bool>('isScreenCaptureBlocked');

      if (result is! bool) {
        throw const TalsecException(message: 'Screen capture state failed.');
      }

      return result;
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
    }
  }

  /// Prevents accessibility services from reading or controlling the current
  /// application screen.
  ///
  /// Accessibility services are commonly abused by malware to read screen
  /// content and perform actions on behalf of the user.
  ///
  /// Android only
  Future<void> blockScreenControl({required bool enabled}) async {
    _checkAndroid();
    try {
      await _methodChannel
          .invokeMethod<void>('blockScreenControl', {'enable': enabled});
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
    }
  }

  /// Checks status of screen control protection.
  ///
  /// For more details about screen control protection, see the
  /// [blockScreenControl] method.
  ///
  /// Returns `true` if screen control protection is active, `false`
  /// otherwise.
  ///
  /// Android only
  Future<bool> isScreenControlBlocked() {
    _checkAndroid();
    return _invokeBoolMethod('isScreenControlBlocked');
  }

  /// Hides overlay windows of other applications over the current application
  /// screen.
  ///
  /// Requires Android 12 (API 31) or newer and the
  /// `android.permission.HIDE_OVERLAY_WINDOWS` permission in the app's
  /// `AndroidManifest.xml`.
  ///
  /// Returns `true` if the request was applied, `false` otherwise (e.g. on an
  /// older Android version or when the permission is missing).
  ///
  /// Android only
  Future<bool> blockOverlayWindows({required bool enabled}) {
    _checkAndroid();
    return _invokeBoolMethod('blockOverlayWindows', {'enable': enabled});
  }

  /// Checks whether overlay windows of other applications are hidden over the
  /// current application screen.
  ///
  /// For more details, see the [blockOverlayWindows] method.
  ///
  /// Android only
  Future<bool> isOverlayWindowsBlocked() {
    _checkAndroid();
    return _invokeBoolMethod('isOverlayWindowsBlocked');
  }

  /// Starts the ongoing call detection (cellular and VoIP calls) for the
  /// current application screen.
  ///
  /// Call state changes are reported through [ThreatCallback.onOngoingCall].
  /// If a call is already in progress when the detection starts, it is
  /// reported as [CallState.ongoing].
  ///
  /// Android only
  Future<void> startOngoingCallDetection() async {
    _checkAndroid();
    try {
      await _methodChannel.invokeMethod<void>('startOngoingCallDetection');
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
    }
  }

  /// Stops the ongoing call detection started by [startOngoingCallDetection].
  ///
  /// Android only
  Future<void> stopOngoingCallDetection() async {
    _checkAndroid();
    try {
      await _methodChannel.invokeMethod<void>('stopOngoingCallDetection');
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
    }
  }

  Future<bool> _invokeBoolMethod(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(method, arguments);

      if (result is! bool) {
        throw TalsecException(message: '$method returned no result.');
      }

      return result;
    } on PlatformException catch (e) {
      throw TalsecException.fromPlatformException(e);
    }
  }

  void _checkAndroid() {
    if (!Platform.isAndroid) {
      throw UnsupportedPlatformException(
        message: 'Platform is not supported: $defaultTargetPlatform',
      );
    }
  }

  /// Sends given [data] to the backend. Each call overwrites data stored in
  /// the backend.
  ///
  /// Throws a [ExternalIdFailureException] when storing failed.
  Future<void> storeExternalId(String data) async {
    try {
      await _methodChannel
          .invokeMethod<void>('storeExternalId', {'data': data});
    } on PlatformException catch (e) {
      throw ExternalIdFailureException.fromPlatformException(e);
    }
  }

  /// Removes the external ID.
  ///
  /// Throws a [ExternalIdFailureException] when removing failed.
  Future<void> removeExternalId() async {
    try {
      await _methodChannel.invokeMethod<void>('removeExternalId');
    } on PlatformException catch (e) {
      throw ExternalIdFailureException.fromPlatformException(e);
    }
  }

  void _checkConfig(TalsecConfig config) {
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
        throw UnsupportedPlatformException(
          message: 'Platform is not supported: $defaultTargetPlatform',
        );
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
        case Threat.deviceID:
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
          callback.onAdbEnabled?.call();
        case Threat.screenshot:
          callback.onScreenshot?.call();
        case Threat.screenRecording:
          callback.onScreenRecording?.call();
        case Threat.multiInstance:
          callback.onMultiInstance?.call();
        case Threat.unsecureWifi:
          callback.onUnsecureWifi?.call();
        case Threat.timeSpoofing:
          callback.onTimeSpoofing?.call();
        case Threat.locationSpoofing:
          callback.onLocationSpoofing?.call();
        case Threat.automation:
          callback.onAutomation?.call();
        case Threat.bootloader:
          callback.onBootloader?.call();
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

  /// Decodes a [code] received from the native platform.
  ///
  /// An unknown code means that the communication with the native platform was
  /// tampered with, so the app is terminated, like in the other freeRASP
  /// plugins.
  static T _decodeOrAbort<T>(int code, T Function(int) decode) {
    try {
      return decode(code);
      // fromInt reports an unknown code with an ArgumentError.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      exit(127);
    }
  }

  void _handleStreamError(Object error) {
    if (error is PlatformException) {
      throw TalsecException.fromPlatformException(error);
    }
    // For any other type of error, rethrow it.
    // ignore: only_throw_errors
    throw error;
  }

  /// Attaches instance of [RaspExecutionStateCallback] to Talsec.
  Future<void> attachExecutionStateListener(
    RaspExecutionStateCallback callback,
  ) async {
    await detachExecutionStateListener();
    _executionStateSubscription ??= onRaspExecutionState.listen((event) {
      switch (event) {
        case RaspExecutionState.fastChecksFinished:
          callback.onFastChecksFinished?.call();
        case RaspExecutionState.criticalChecksFinished:
          callback.onCriticalChecksFinished?.call();
        case RaspExecutionState.postponedChecksFinished:
          callback.onPostponedChecksFinished?.call();
      }
    });
  }

  /// Detaches instance of latest [RaspExecutionStateCallback].
  Future<void> detachExecutionStateListener() async {
    await _executionStateSubscription?.cancel();
    _executionStateSubscription = null;
  }

  /// Retrieves the app icon for the given [packageName] as base64 string.
  ///
  /// Throws a [TalsecException] with error message description if
  /// the app with given package name couldn't be obtained.
  Future<String> getAppIcon(String packageName) async {
    _checkAndroid();
    try {
      return await _getAppIcon(packageName);
    } on PlatformException catch (e) {
      throw MalwareFailureException.fromPlatformException(e);
    }
  }

  Future<String> _getAppIcon(String packageName) async {
    final args = {'packageName': packageName};
    final result = await _methodChannel.invokeMethod<String>(
      'getAppIcon',
      args,
    );

    if (result is! String) {
      throw const MalwareFailureException(message: 'Malware App icon is null.');
    }

    return result;
  }
}
