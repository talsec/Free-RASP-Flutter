import 'package:freerasp/src/typedefs.dart';

/// A callback class that handles RASP (Runtime Application Self-Protection)
/// execution state events.
///
/// Example usage:
/// ```dart
/// final callback = RaspExecutionStateCallback(
///   onAllChecksFinished: () {
///     print('All security checks have been completed');
///     // Update UI or perform additional actions
///   },
/// );
///
/// Talsec.instance.attachExecutionStateListener(callback);
/// ```
class RaspExecutionStateCallback {
  /// Creates a new [RaspExecutionStateCallback] instance.
  ///
  /// The [onAllChecksFinished] callback will be invoked when all security
  /// checks have been completed by the native security engine.
  RaspExecutionStateCallback({
    this.onAllChecksFinished,
  });

  /// Callback invoked when all security checks are completed.
  final VoidCallback? onAllChecksFinished;
}
