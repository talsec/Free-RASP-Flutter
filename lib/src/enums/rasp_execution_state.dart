/// Represents the state of the RASP (Runtime Application Self-Protection)
/// execution.
enum RaspExecutionState {
  /// The fast (standard) security checks have been completed.
  ///
  /// The postponed checks may still run afterwards.
  fastChecksFinished,

  /// The critical security checks have been completed, before the
  /// non-critical checks.
  criticalChecksFinished,

  /// The postponed security checks have been completed, which ends the
  /// initial evaluation.
  postponedChecksFinished,
}

/// Extensions for [RaspExecutionState].
extension RaspExecutionStateX on RaspExecutionState {
  /// Converts an integer value to a [RaspExecutionState].
  static RaspExecutionState fromInt(int value) {
    switch (value) {
      case 187429:
        return RaspExecutionState.fastChecksFinished;
      case 614702:
        return RaspExecutionState.criticalChecksFinished;
      case 952318:
        return RaspExecutionState.postponedChecksFinished;
      default:
        throw ArgumentError('Unknown execution state code: $value');
    }
  }
}
