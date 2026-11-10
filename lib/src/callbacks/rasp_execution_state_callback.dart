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
    this.onCriticalChecksFinished,
    this.onPostponedChecksFinished,
  });

  /// Callback invoked when all standard security checks are completed.
  ///
  /// On Android, this is invoked after the fast checks are completed, while
  /// the postponed checks still run. Use [onPostponedChecksFinished] to know
  /// when the initial evaluation has fully ended.
  final VoidCallback? onAllChecksFinished;

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
