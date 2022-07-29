import 'dart:io';

import 'package:flutter/services.dart';

import './talsec_callback.dart';
import './talsec_config.dart';

export './talsec_callback.dart';
export './talsec_config.dart';

/// Wrapper of general config and general callbacks.
///
/// Sends and receive data from native side, decides which callbacks should be called.
class TalsecApp {
  late TalsecConfig _config;
  late TalsecCallback _callback;

  /// Constructor checks whether [config] and [callback] are provided.
  /// Both arguments are MANDATORY. Callback can be provided just as empty
  /// [TalsecCallback] object.
  TalsecApp({
    required final TalsecConfig? config,
    required final TalsecCallback? callback,
  }) : assert(config != null && callback != null,
            'config and callback cannot be null') {
    _config = config!;
    _callback = callback!;
  }

  /// [EventChannel] used to receive Threats from the native platform.
  static const EventChannel _channel =
      EventChannel('plugins.aheaditec.com/events');

  /// [MethodChannel] used to interact with native platform.
  static const MethodChannel _configChannel =
      MethodChannel('plugins.aheaditec.com/config');

  /// Prepares necessary infrastructure to communicate with
  /// native side and launches Talsec on native to check
  /// device for threats.
  void start() {
    /// Android device
    final AndroidConfig? androidConfig = _config.androidConfig;
    final IOSconfig? iosConfig = _config.iosConfig;

    if (Platform.isAndroid && androidConfig != null) {
      _configChannel.invokeListMethod<void>('setConfig', <String, dynamic>{
        'expectedPackageName': androidConfig.expectedPackageName,
        'expectedSigningCertificateHash':
            androidConfig.expectedSigningCertificateHash,
        'watcherMail': _config.watcherMail,
        'supportedAlternativeStores': androidConfig.supportedAlternativeStores
      });
    }

    /// iOS device
    else if (Platform.isIOS && iosConfig != null) {
      _configChannel.invokeListMethod<void>('setConfig', <String, String?>{
        'appBundleId': iosConfig.appBundleId,
        'appTeamId': iosConfig.appTeamId,
        'watcherMail': _config.watcherMail,
      });
    } else {
      throw MissingPluginException(
          '${Platform.isAndroid ? "androidConfig" : "IOSconfig"} is not provided.');
    }

    /// Listen to changes from native side
    _setListener(_channel);
  }

  /// Receive different events from native side
  void _setListener(final EventChannel channel) {
    channel.receiveBroadcastStream().listen((final dynamic event) {
      switch (event) {

        /// Android: Event received when device is rooted
        case "onRootDetected":
          _callback.androidCallback?.onRootDetected?.call();
          break;

        /// Android & iOS: Event received when app is running in debug mode
        case "onDebuggerDetected":
          _callback.onDebuggerDetected?.call();
          break;

        /// Android: Event received when app is running on emulator
        case "onEmulatorDetected":
          _callback.androidCallback?.onEmulatorDetected?.call();
          break;

        /// Android: Event received when app code integrity is disturbed
        case "onTamperDetected":
          _callback.androidCallback?.onTamperDetected?.call();
          break;

        /// Android: Event received when hooking framework is present or used
        case "onHookDetected":
          _callback.androidCallback?.onHookDetected?.call();
          break;

        case 'onDeviceBindingDetected':
          _callback.androidCallback?.onDeviceBindingDetected?.call();
          break;

        case 'onUntrustedInstallationSourceDetected':
          _callback.androidCallback?.onUntrustedInstallationDetected?.call();
          break;

        /// iOS: Event received when app signature does not match expected one
        case "onSignatureDetected":
          _callback.iosCallback?.onSignatureDetected?.call();
          break;

        /// iOS: Event received when jailbreak on device is detected
        case "onJailbreakDetected":
          _callback.iosCallback?.onJailbreakDetected?.call();
          break;

        /// iOS: Event received when app is manipulated on runtime
        case "onRuntimeManipulationDetected":
          _callback.iosCallback?.onRuntimeManipulationDetected?.call();
          break;

        /// iOS: Event received when device is not protected by passcode
        case "onPasscodeDetected":
          _callback.iosCallback?.onPasscodeDetected?.call();
          break;

        case "onPasscodeChangeDetected":
          break;

        /// iOS: Event received when app is running on simulator
        case "onSimulatorDetected":
          _callback.iosCallback?.onSimulatorDetected?.call();
          break;

        /// iOS: Event received when secure enclave layer is missing
        case "onMissingSecureEnclaveDetected":
          _callback.iosCallback?.onMissingSecureEnclaveDetected?.call();
          break;

        /// iOS: Event received when device was changed since last check
        case "onDeviceChangeDetected":
          _callback.iosCallback?.onDeviceChangeDetected?.call();
          break;

        /// iOS: Event received when device id was detected
        case "onDeviceIdDetected":
          _callback.iosCallback?.onDeviceIdDetected?.call();
          break;

        /// iOS: Event received when installation from unofficial store was
        /// detected
        case "onUnofficialStoreDetected":
          _callback.iosCallback?.onUnofficialStoreDetected?.call();
          break;
      }
    });
  }
}
