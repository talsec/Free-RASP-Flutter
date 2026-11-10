/// Represents the state of the RASP (Runtime Application Self-Protection)
/// execution.
enum RaspExecutionState {
  /// All standard security checks have been completed.
  ///
  /// On Android, this is triggered after the fast checks are completed, while
  /// the postponed checks still run.
  allChecksFinished,

  /// The critical security checks have been completed, before the
  /// non-critical checks.
  ///
  /// Android only
  criticalChecksFinished,

  /// The postponed security checks have been completed, which ends the
  /// initial evaluation.
  ///
  /// Android only
  postponedChecksFinished,
}

/// Extensions for [RaspExecutionState].
extension RaspExecutionStateX on RaspExecutionState {
  /// Converts an integer value to a [RaspExecutionState].
  static RaspExecutionState fromInt(int value) {
    switch (value) {
      case 187429:
        return RaspExecutionState.allChecksFinished;
      case 614702:
        return RaspExecutionState.criticalChecksFinished;
      case 952318:
        return RaspExecutionState.postponedChecksFinished;
      default:
        throw ArgumentError('Unknown execution state code: $value');
    }
  }
}
