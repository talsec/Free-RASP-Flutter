import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freerasp/freerasp.dart';

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

  void _checkConfig(TalsecConfig config) {
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (config.androidConfig == null) {
          throw const ConfigurationException(
            message: 'Android config is required for Android platform',
          );
        }
        break;
      case TargetPlatform.iOS:
        if (config.iosConfig == null) {
          throw const ConfigurationException(
            message: 'iOS config is required for iOS platform',
          );
        }
        break;
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
  void attachListener(ThreatCallback callback) {
    detachListener();
    _streamSubscription ??= onThreatDetected.listen((event) {
      switch (event) {
        case Threat.hooks:
          callback.onHooks?.call();
          break;
        case Threat.debug:
          callback.onDebug?.call();
          break;
        case Threat.passcode:
          callback.onPasscode?.call();
          break;
        case Threat.deviceId:
          callback.onDeviceID?.call();
          break;
        case Threat.simulator:
          callback.onSimulator?.call();
          break;
        case Threat.appIntegrity:
          callback.onAppIntegrity?.call();
          break;
        case Threat.obfuscationIssues:
          callback.onObfuscationIssues?.call();
          break;
        case Threat.deviceBinding:
          callback.onDeviceBinding?.call();
          break;
        case Threat.unofficialStore:
          callback.onUnofficialStore?.call();
          break;
        case Threat.privilegedAccess:
          callback.onPrivilegedAccess?.call();
          break;
        case Threat.secureHardwareNotAvailable:
          callback.onSecureHardwareNotAvailable?.call();
          break;
        case Threat.systemVPN:
          callback.onSystemVPN?.call();
          break;
        case Threat.devMode:
          callback.onDevMode?.call();
          break;
      }
    });

    methodChannel.setMethodCallHandler((call) {
      if (call.method == "onScreenCaptureDetected") {
        final value = call.arguments as int;

        callback.onScreenCaptureDetected?.call(CaptureType.fromInt(value));
      }
    });
  }

  /// Removes instance of latest [ThreatCallback]. Also cancels
  /// [StreamSubscription] for that [ThreatCallback].
  ///
  /// If no callback was attached earlier, it has no effect.
  void detachListener() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void _handleStreamError(Object error) {
    if (error is PlatformException) {
      throw TalsecException.fromPlatformException(error);
    }
    // ignore: only_throw_errors
    throw error;
  }
}
