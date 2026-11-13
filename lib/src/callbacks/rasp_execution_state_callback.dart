import 'package:freerasp/src/typedefs.dart';

/// A callback class that handles RASP (Runtime Application Self-Protection)
/// execution state events.
///
/// Example usage:
/// ```dart
/// final callback = RaspExecutionStateCallback(
///   onFastChecksFinished: () {
///     print('Fast security checks have been completed');
///     // Update UI or perform additional actions
///   },
/// );
///
/// Talsec.instance.attachExecutionStateListener(callback);
/// ```
class RaspExecutionStateCallback {
  /// Creates a new [RaspExecutionStateCallback] instance.
  ///
  /// The [onFastChecksFinished] callback will be invoked when the fast
  /// security checks have been completed by the native security engine.
  RaspExecutionStateCallback({
    this.onFastChecksFinished,
    this.onCriticalChecksFinished,
    this.onPostponedChecksFinished,
  });

  /// Callback invoked when the fast (standard) security checks are completed.
  ///
  /// On Android, the postponed checks may still run afterwards; use
  /// [onPostponedChecksFinished] to know when the initial evaluation has fully
  /// ended. On iOS, this is invoked when all security checks are completed.
  final VoidCallback? onFastChecksFinished;

  /// Callback invoked when the critical security checks are completed,
  /// before the non-critical checks.
  ///
  /// Android only
  final VoidCallback? onCriticalChecksFinished;

  /// Callback invoked when the postponed security checks are completed,
  /// which ends the initial evaluation.
  ///
  /// Android only
  final VoidCallback? onPostponedChecksFinished;
}
